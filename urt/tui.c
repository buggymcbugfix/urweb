/* tui.c -- inline terminal widgets for urt.  See tui.h for the shape.
 *
 * C99, termios and nothing else.  Build with the screens that use it:
 *
 *   cc -std=c99 -Wall -Wextra -o tui-demo urt/tui.c urt/tui-demo.c
 */

/* POSIX 2008 with the XSI extensions, and on macOS the BSD ones too,
 * which its headers hide once a strict level is asked for (mkdtemp is
 * one).  _DARWIN_C_SOURCE means nothing anywhere else. */
#define _POSIX_C_SOURCE 200809L
#define _DARWIN_C_SOURCE
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#include "tui.h"

/* ---------------------------------------------------------------- keys */

/* Keys as read from the terminal.  Nothing outside this file sees them. */
enum keyname { K_NONE, K_UP, K_DOWN, K_LEFT, K_RIGHT, K_ENTER, K_ESC, K_BACKSPACE,
               K_SPACE, K_TAB, K_EOF, K_OTHER, K_CHAR };
struct key { enum keyname k; char c; };

/* Which keys mean what, in which modes, and how a footer names them.  The
 * one place bindings live.  For a key, the first matching row counts. */
#define LIST  (1u << M_LIST)
#define TEXT  (1u << M_TEXT)
#define CHECK (1u << M_CHECK)
#define S_KEY (-1)                              /* label: the key's own character */

static const struct binding {
    struct key key; unsigned modes; enum action action; int label;
} bindings[] = {
    { { K_UP, 0 },        LIST | CHECK,        A_UP,         S_UP },
    { { K_CHAR, 'k' },    LIST | CHECK,        A_UP,         S_KEY },
    { { K_DOWN, 0 },      LIST | CHECK,        A_DOWN,       S_DOWN },
    { { K_CHAR, 'j' },    LIST | CHECK,        A_DOWN,       S_KEY },
    { { K_ENTER, 0 },     LIST | TEXT,         A_CONFIRM,    S_ENTER },
    { { K_ENTER, 0 },     CHECK,               A_SAVE,       S_ENTER },
    { { K_SPACE, 0 },     CHECK,               A_TOGGLE,     S_SPACE },
    { { K_CHAR, 'a' },    CHECK,               A_TOGGLE_ALL, S_KEY },
    { { K_ESC, 0 },       LIST | TEXT | CHECK, A_BACK,       S_ESC },
    { { K_BACKSPACE, 0 }, TEXT,                A_ERASE,      S_KEY },
};
#define NBINDINGS (sizeof bindings / sizeof bindings[0])

/* The action a key stands for in a mode: its row in the table, or typing
 * in M_TEXT, or nothing. */
static enum action action_for(struct key k, enum mode m) {
    size_t i;
    if (k.k == K_EOF) {
        return A_QUIT;
    }
    for (i = 0; i < NBINDINGS; i++) {
        if (bindings[i].key.k == k.k && bindings[i].key.c == k.c && (bindings[i].modes & (1u << m))) {
            return bindings[i].action;
        }
    }
    if (m == M_TEXT && (k.k == K_CHAR || k.k == K_SPACE)) {
        return A_TYPE;
    }
    return A_NONE;
}

/* How a footer names an action in a mode: the label of its first row. */
static const char *label_for(enum action a, enum mode m) {
    static char one[2];
    size_t i;
    for (i = 0; i < NBINDINGS; i++) {
        if (bindings[i].action == a && (bindings[i].modes & (1u << m))) {
            if (bindings[i].label != S_KEY) {
                return tui_sym((enum sym) bindings[i].label);
            }
            one[0] = bindings[i].key.c; one[1] = 0;
            return one;
        }
    }
    return "?";
}

/* ------------------------------------------------------------ terminal */

int tui_rows = 10;
const char *TUI_ITALIC = "\033[3m", *TUI_GREY = "\033[38;5;245m", *TUI_BOLD = "\033[1m", *TUI_RESET = "\033[0m";

static struct termios saved;
static int have_saved = 0, scripted = 0, unicode = 1;
static char *script = NULL, *script_pos = NULL;

/* A symbol, as the terminal can show it. */
const char *tui_sym(enum sym s) {
    static const char *const uni[] = { "\xe2\x86\x91", "\xe2\x86\x93", "\xe2\x8f\x8e", "esc", "space", "\xc2\xb7", ">" };
    static const char *const asc[] = { "^", "v", "enter", "esc", "space", "-", ">" };
    return (unicode ? uni : asc)[s];
}

/* Whether the locale can show UTF-8, unless TUI_ASCII says not to try. */
static int want_unicode(void) {
    const char *lang, *ascii = getenv("TUI_ASCII");
    if (ascii && *ascii && strcmp(ascii, "0")) {
        return 0;
    }
    lang = getenv("LC_ALL");
    if (!lang || !*lang) {
        lang = getenv("LC_CTYPE");
    }
    if (!lang || !*lang) {
        lang = getenv("LANG");
    }
    if (!lang) {
        return 0;
    }
    return strstr(lang, "UTF-8") || strstr(lang, "utf-8") || strstr(lang, "UTF8") || strstr(lang, "utf8");
}

/* The terminal as it was, and the cursor back on. */
void tui_close(void) {
    if (!have_saved) {
        return;
    }
    printf("\033[?25h");
    fflush(stdout);
    tcsetattr(STDIN_FILENO, TCSANOW, &saved);
    have_saved = 0;
}

/* Restore the terminal, then die of the signal as we would have. */
static void on_signal(int sig) {
    tui_close();
    signal(sig, SIG_DFL);
    raise(sig);
}

/* Raw mode: no echo, no line buffering.  ISIG stays, so ^C is still
 * SIGINT and on_signal cleans up.  Or, with TUI_KEYS, scripted input and
 * plain frames. */
int tui_open(void) {
    struct termios raw;
    const char *keys = getenv("TUI_KEYS"), *rows = getenv("TUI_ROWS");
    if (rows && atoi(rows) >= 3) {
        tui_rows = atoi(rows);
    }
    unicode = want_unicode();
    if (keys && *keys) {
        scripted = 1;
        script = script_pos = strdup(keys);
        TUI_ITALIC = TUI_GREY = TUI_BOLD = TUI_RESET = "";
        return 0;
    }
    if (!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO)) {
        return -1;
    }
    if (tcgetattr(STDIN_FILENO, &saved) < 0) {
        return -1;
    }
    raw = saved;
    raw.c_lflag &= ~(ECHO | ICANON);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    if (tcsetattr(STDIN_FILENO, TCSANOW, &raw) < 0) {
        return -1;
    }
    have_saved = 1;
    atexit(tui_close);
    signal(SIGINT, on_signal);
    signal(SIGTERM, on_signal);
    printf("\033[?25l");
    return 0;
}

/* The next key of the script: a name (up, down, enter, esc, backspace,
 * space, eof) or a character, separated by spaces. */
static struct key scripted_key(void) {
    struct key k = { K_EOF, 0 };
    char *tok;
    while (*script_pos == ' ') {
        script_pos++;
    }
    if (!*script_pos) {
        return k;
    }
    tok = script_pos;
    while (*script_pos && *script_pos != ' ') {
        script_pos++;
    }
    if (*script_pos) {
        *script_pos++ = 0;
    }
    if (!strcmp(tok, "up")) {
        k.k = K_UP;
    } else if (!strcmp(tok, "down")) {
        k.k = K_DOWN;
    } else if (!strcmp(tok, "enter")) {
        k.k = K_ENTER;
    } else if (!strcmp(tok, "esc")) {
        k.k = K_ESC;
    } else if (!strcmp(tok, "backspace")) {
        k.k = K_BACKSPACE;
    } else if (!strcmp(tok, "space")) {
        k.k = K_SPACE;
    } else if (!strcmp(tok, "eof")) {
        k.k = K_EOF;
    } else {
        k.k = K_CHAR;
        k.c = tok[0];
    }
    return k;
}

/* One key from the terminal.  Arrows arrive as ESC [ A; a lone ESC is one
 * that nothing follows within 100 ms. */
static struct key tui_key(void) {
    struct key k = { K_NONE, 0 };
    unsigned char c;
    if (scripted) {
        return scripted_key();
    }
    if (read(STDIN_FILENO, &c, 1) != 1) {
        k.k = K_EOF;
        return k;
    }
    if (c == 033) {
        struct termios t, t0;
        unsigned char seq[2] = { 0, 0 };
        ssize_t n;
        tcgetattr(STDIN_FILENO, &t0);
        t = t0;
        t.c_cc[VMIN] = 0;
        t.c_cc[VTIME] = 1;
        tcsetattr(STDIN_FILENO, TCSANOW, &t);
        n = read(STDIN_FILENO, seq, 2);
        tcsetattr(STDIN_FILENO, TCSANOW, &t0);
        if (n <= 0) {
            k.k = K_ESC;
            return k;
        }
        if (n == 2 && (seq[0] == '[' || seq[0] == 'O')) {
            switch (seq[1]) {
                case 'A': k.k = K_UP; return k;
                case 'B': k.k = K_DOWN; return k;
                case 'C': k.k = K_RIGHT; return k;
                case 'D': k.k = K_LEFT; return k;
            }
        }
        k.k = K_OTHER;
        return k;
    }
    switch (c) {
        case '\n': case '\r': k.k = K_ENTER; break;
        case 127: case '\b': k.k = K_BACKSPACE; break;
        case ' ': k.k = K_SPACE; break;
        case '\t': k.k = K_TAB; break;
        default:
            if (c < 32 || c == 127) {
                k.k = K_OTHER;
            } else {
                k.k = K_CHAR;
                k.c = (char) c;
            }
    }
    return k;
}

/* The next key, as what it means here. */
enum action tui_next(enum mode m, char *c) {
    struct key k = tui_key();
    if (c) {
        *c = k.k == K_SPACE ? ' ' : k.c;
    }
    return action_for(k, m);
}

/* --------------------------------------------------------------- frame */

#define MAXLINES 64
#define LINELEN 512
static char frame[MAXLINES][LINELEN];
static int nframe = 0, height = 0, below = 0, cursor_row = -1, cursor_col = 0;

/* One more line for the frame. */
void tui_line(const char *fmt, ...) {
    va_list ap;
    if (nframe >= MAXLINES) {
        return;
    }
    va_start(ap, fmt);
    vsnprintf(frame[nframe++], LINELEN, fmt, ap);
    va_end(ap);
}

/* The real cursor goes on the last line added, at this column. */
void tui_cursor(int col) {
    cursor_row = nframe - 1;
    cursor_col = col;
}

/* Hints from actions: each named as the key that gives it in this mode. */
void tui_footer(enum mode m, const struct hint *hints) {
    char line[LINELEN] = "", key[64];
    size_t used = 0;
    int i;
    for (i = 0; hints[i].action != A_NONE; i++) {
        if (hints[i].action == A_SCROLL) {
            snprintf(key, sizeof key, "%s/%s", label_for(A_UP, m), label_for(A_DOWN, m));
        } else {
            snprintf(key, sizeof key, "%s", label_for(hints[i].action, m));
        }
        if (i) {
            used += (size_t) snprintf(line + used, sizeof line - used, " %s ", tui_sym(S_DOT));
        }
        used += (size_t) snprintf(line + used, sizeof line - used, "%s %s%s%s",
                                  key, TUI_GREY, hints[i].meaning, TUI_RESET);
    }
    tui_line("%s", "");
    tui_line("%s", line);
}

/* Print a line cut to `cols` columns, escape sequences not counted and
 * UTF-8 continuation bytes not counted either. */
static void put_cut(const char *s, int cols) {
    int seen = 0;
    while (*s) {
        if (*s == 033) {
            const char *m = strchr(s, 'm');
            if (!m) {
                break;
            }
            fwrite(s, 1, (size_t) (m - s + 1), stdout);
            s = m + 1;
            continue;
        }
        if ((*s & 0xC0) != 0x80) {
            if (seen >= cols) {
                fputs(TUI_RESET, stdout);
                return;
            }
            seen++;
        }
        putchar(*s++);
    }
}

/* The frame onto the terminal, over the previous one: back below it if the
 * cursor was left inside, up over it, clear, print.  Scripted, the frame
 * is printed plain with "--" after it. */
void tui_draw(void) {
    struct winsize ws;
    int cols = 80, i;
    if (scripted) {
        for (i = 0; i < nframe; i++) {
            puts(frame[i]);
        }
        puts("--");
        nframe = 0;
        cursor_row = -1;
        return;
    }
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_col > 0) {
        cols = ws.ws_col;
    }
    if (below) {
        printf("\033[%dB", below);
    }
    putchar('\r');
    if (height) {
        printf("\033[%dA", height);
    }
    printf("\033[J");
    for (i = 0; i < nframe; i++) {
        put_cut(frame[i], cols);
        putchar('\n');
    }
    height = nframe;
    below = 0;
    if (cursor_row >= 0) {
        below = height - cursor_row;
        printf("\033[%dA\033[%dG\033[?25h", below, cursor_col + 1);
    } else {
        printf("\033[?25l");
    }
    fflush(stdout);
    nframe = 0;
    cursor_row = -1;
}

void tui_break(void) {
    if (scripted) {
        return;
    }
    if (below) {
        printf("\033[%dB", below);
    }
    putchar('\r');
    fflush(stdout);
    height = below = 0;
    cursor_row = -1;
}

/* ---------------------------------------------------------------- list */

void list_init(struct list *l, const char *const *items, const char *const *desc, int n) {
    l->items = items;
    l->desc = desc;
    l->n = n > TUI_MAX_ITEMS ? TUI_MAX_ITEMS : n;
    l->cur = l->top = 0;
}

/* How many items fit from l->top: the box less its indicator rows. */
static int list_fit(const struct list *l) {
    int cap = tui_rows;
    if (l->top > 0) {
        cap--;
    }
    if (l->top + cap < l->n) {
        cap--;
    }
    return cap;
}

/* Move l->top so that the cursor is inside the box. */
static void list_scroll(struct list *l) {
    if (l->cur < l->top) {
        l->top = l->cur;
    }
    while (l->cur >= l->top + list_fit(l)) {
        l->top++;
    }
    /* An indicator saying "1 more" costs the row it would show. */
    if (l->top == 1) {
        l->top = 0;
        if (l->cur >= list_fit(l)) {
            l->top = 1;
        }
    }
}

int list_update(struct list *l, enum action a) {
    if (a == A_UP) {
        if (l->cur > 0) {
            l->cur--;
        }
    } else if (a == A_DOWN) {
        if (l->cur < l->n - 1) {
            l->cur++;
        }
    } else {
        return 0;
    }
    list_scroll(l);
    return 1;
}

/* The items in view, with the cursor, the boxes if any, the notes, and
 * the "N more" rows: tui_rows lines, or one per item when there are
 * fewer.  Either way the box is the same height at every key, which is
 * what drawing over the previous frame needs. */
void list_render(const struct list *l, const int *checked) {
    int cap = list_fit(l), i, row = 0, width = 0;
    int rows = l->n < tui_rows ? l->n : tui_rows;
    for (i = 0; i < l->n; i++) {
        if ((int) strlen(l->items[i]) > width) {
            width = (int) strlen(l->items[i]);
        }
    }
    if (l->top > 0) {
        tui_line("    %s%s %d more ...%s", TUI_GREY, tui_sym(S_UP), l->top, TUI_RESET);
        row++;
    }
    for (i = l->top; i < l->top + cap && i < l->n; i++, row++) {
        const char *mark = i == l->cur ? tui_sym(S_CURSOR) : " ";
        const char *box = checked ? (checked[i] ? "[x] " : "[ ] ") : "";
        if (l->desc && l->desc[i]) {
            tui_line("  %s %s%-*s    %s%s%s%s", mark, box, width, l->items[i],
                     TUI_ITALIC, TUI_GREY, l->desc[i], TUI_RESET);
        } else {
            tui_line("  %s %s%s", mark, box, l->items[i]);
        }
    }
    if (l->top + cap < l->n) {
        tui_line("    %s%s %d more ...%s", TUI_GREY, tui_sym(S_DOWN), l->n - l->top - cap, TUI_RESET);
        row++;
    }
    for (; row < rows; row++) {
        tui_line("%s", "");
    }
}

/* --------------------------------------------------------------- input */

const char TUI_NAME_CHARS[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";

void input_init(struct input *in, const char *dflt, const char *allowed) {
    in->text[0] = 0;
    in->dflt = dflt ? dflt : "";
    in->allowed = allowed;
}

/* Typing appends, if the character is allowed; erasing drops the last. */
int input_update(struct input *in, enum action a, char c) {
    size_t len = strlen(in->text);
    if (a == A_ERASE) {
        if (len) {
            in->text[len - 1] = 0;
        }
    } else if (a == A_TYPE) {
        if (in->allowed && !strchr(in->allowed, c)) {
            return 0;
        }
        if (len + 1 >= sizeof in->text) {
            return 0;
        }
        in->text[len] = c;
        in->text[len + 1] = 0;
    } else {
        return 0;
    }
    return 1;
}

/* The text, or the default while there is none. */
const char *input_value(const struct input *in) {
    return *in->text ? in->text : in->dflt;
}

/* One line, with the real cursor after what was typed. */
void input_render(const struct input *in) {
    if (*in->text) {
        tui_line("%s %s", tui_sym(S_CURSOR), in->text);
        tui_cursor(2 + (int) strlen(in->text));
    } else {
        tui_line("%s %s%s%s", tui_sym(S_CURSOR), TUI_GREY, in->dflt, TUI_RESET);
        tui_cursor(2);
    }
}

/* ----------------------------------------------------------- checklist */

void check_init(struct check *c, const char *const *items, int n, const int *on) {
    int i;
    list_init(&c->l, items, NULL, n);
    for (i = 0; i < c->l.n; i++) {
        c->on[i] = on ? on[i] : 1;
    }
    c->have_saved = 0;
}

int check_count(const struct check *c) {
    int i, n = 0;
    for (i = 0; i < c->l.n; i++) {
        n += c->on[i];
    }
    return n;
}

/* The footer's word for A_TOGGLE_ALL, which is also what it does. */
const char *check_all_label(const struct check *c) {
    int n = check_count(c);
    if (n == c->l.n) {
        return "deselect all";
    }
    if (n == 0 && c->have_saved) {
        return "restore selection";
    }
    return "select all";
}

int check_update(struct check *c, enum action a) {
    int i;
    if (a == A_TOGGLE) {
        c->on[c->l.cur] = !c->on[c->l.cur];
    } else if (a == A_TOGGLE_ALL) {
        const char *what = check_all_label(c);
        if (!strcmp(what, "deselect all")) {
            for (i = 0; i < c->l.n; i++) {
                c->on[i] = 0;
            }
        } else if (!strcmp(what, "restore selection")) {
            memcpy(c->on, c->saved, sizeof c->on);
            c->have_saved = 0;
        } else {
            if (check_count(c)) {
                memcpy(c->saved, c->on, sizeof c->on);
                c->have_saved = 1;
            }
            for (i = 0; i < c->l.n; i++) {
                c->on[i] = 1;
            }
        }
    } else {
        return list_update(&c->l, a);
    }
    return 1;
}

void check_render(const struct check *c) {
    list_render(&c->l, c->on);
}

/* tui.h -- inline terminal widgets for urt.
 *
 * A screen is drawn whole at every key: widgets render their lines into a
 * frame, the screen adds its own around them, and tui_draw replaces the
 * previous frame on the terminal.  Frames are inline, under the prompt,
 * not on an alternate screen, and every frame of a screen has the same
 * height, so replacing one is moving the cursor up and clearing.
 *
 * Screens never see keys.  They read actions (tui_next), which the binding
 * table in tui.c makes from keys according to the mode the screen is in,
 * and they name actions in footers (tui_footer), which the same table
 * turns back into key labels.  So the bindings live in one place.
 *
 * With TUI_KEYS set to a list of key names ("down down enter b a z"),
 * keys come from that instead of the terminal and every frame is printed
 * in full, plain, with a "--" line after it: a script of keystrokes then
 * gives a transcript to diff against an expected file (urt/tui-check).
 */

#ifndef URT_TUI_H
#define URT_TUI_H

/* ------------------------------------------------------------- actions */

/* What a key means.  Widgets and screens speak only in these. */
enum action {
    A_NONE,        /* a key bound to nothing here */
    A_UP,          /* cursor up */
    A_DOWN,        /* cursor down */
    A_CONFIRM,     /* take the item or the text */
    A_SAVE,        /* keep the selection and go on */
    A_BACK,        /* previous screen, or out */
    A_TOGGLE,      /* check or uncheck the item under the cursor */
    A_TOGGLE_ALL,  /* all, none, or the selection before all */
    A_TYPE,        /* a character for the input; tui_next says which */
    A_ERASE,       /* the last character */
    A_QUIT,        /* the terminal or the script is exhausted */
    A_SCROLL       /* footers only: A_UP and A_DOWN as one entry */
};

/* Where the key is read.  Typing goes to an input in M_TEXT; elsewhere a
 * letter can be a command. */
enum mode { M_LIST, M_TEXT, M_CHECK };

/* ------------------------------------------------------------ terminal */

/* Raw mode on the terminal, or scripted keys from TUI_KEYS.  Returns -1
 * when there is neither a terminal nor a script. */
int tui_open(void);

/* The terminal as it was.  Called for you at exit and on SIGINT/SIGTERM. */
void tui_close(void);

/* The next key as an action for this mode.  For A_TYPE, *c is the
 * character. */
enum action tui_next(enum mode m, char *c);

/* Symbols, in Unicode or ASCII: TUI_ASCII=1 forces ASCII, and so does a
 * locale that is not UTF-8. */
enum sym { S_UP, S_DOWN, S_ENTER, S_ESC, S_SPACE, S_DOT, S_CURSOR };
const char *tui_sym(enum sym s);

/* Rows a list box takes at most, indicators included: 10, or what
 * TUI_ROWS says, never under 3.  Every list and checklist scrolls within
 * that; a shorter one takes a row per item. */
extern int tui_rows;

/* ---------------------------------------------------------------- frame */

/* Add a line to the frame being built.  Escape sequences are fine; lines
 * are cut to the terminal's width when drawn. */
#ifdef __GNUC__
void tui_line(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
#else
void tui_line(const char *fmt, ...);
#endif

/* Put the real cursor on the line just added, at this column. */
void tui_cursor(int col);

/* Key hints for the bottom of a frame: "↑/↓ scroll · ⏎ create · esc
 * quit", from actions and what they do here.  Ends with A_NONE. */
struct hint { enum action action; const char *meaning; };
void tui_footer(enum mode m, const struct hint *hints);

/* Replace the previous frame on the terminal with this one. */
void tui_draw(void);

/* Leave the last frame where it is: what is printed next goes below it,
 * and the next frame starts below that instead of over the old one. */
void tui_break(void);

/* Styles, empty when scripted: a note is grey and italic, the name of a
 * test is bold, as everywhere in urt. */
extern const char *TUI_ITALIC, *TUI_GREY, *TUI_BOLD, *TUI_RESET;

/* -------------------------------------------------------------- widgets */

#define TUI_MAX_ITEMS 1024

/* A list with a cursor, in a box of tui_rows rows, or fewer when the list
 * is shorter; when items are hidden above or below, the first or last row
 * says how many.  desc, if not NULL, is a note after each item, in
 * italics. */
struct list { const char *const *items; const char *const *desc; int n, cur, top; };
void list_init(struct list *l, const char *const *items, const char *const *desc, int n);
int  list_update(struct list *l, enum action a);            /* 1 if it moved */
void list_render(const struct list *l, const int *checked); /* checked: NULL, or a box per item */

/* One line of text after "> ".  dflt shows greyed while nothing is typed
 * and is the value then.  allowed, if not NULL, is the set of characters
 * that can be typed; others are ignored. */
struct input { char text[256]; const char *dflt; const char *allowed; };
void input_init(struct input *in, const char *dflt, const char *allowed);
int  input_update(struct input *in, enum action a, char c);
const char *input_value(const struct input *in);
void input_render(const struct input *in);

/* What may go in a case name: [A-Za-z0-9_-]. */
extern const char TUI_NAME_CHARS[];

/* The list with a box before each item.  A_TOGGLE_ALL cycles: some on ->
 * all; all -> none; none -> what was on before all, if anything was.
 * on, if not NULL, is the initial selection, one flag per item; NULL
 * checks everything. */
struct check { struct list l; int on[TUI_MAX_ITEMS], saved[TUI_MAX_ITEMS], have_saved; };
void check_init(struct check *c, const char *const *items, int n, const int *on);
int  check_update(struct check *c, enum action a);
void check_render(const struct check *c);
const char *check_all_label(const struct check *c);   /* what A_TOGGLE_ALL would do now */
int  check_count(const struct check *c);

#endif

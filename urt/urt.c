/* urt.c -- the Ur/Web toolbox: one program, a command each for its tools.
 *
 *   urt snapshot ...     snapshot tests of the compiler (snapshot.c)
 *
 * More to come: a file watcher, migrations.  Each command is a function
 * that takes the arguments after its name, declared in commands.h.
 */

#include <stdio.h>
#include <string.h>

#include "commands.h"
#include "fs.h"
#include "report.h"

static const char usage_text[] =
    "usage: urt COMMAND [ARG...]\n"
    "\n"
    "The Ur/Web toolbox.  The commands:\n"
    "\n"
    "  snapshot     snapshot tests of the compiler: urt snapshot --help\n"
    "\n"
    "  --help, -h   this\n";

static const struct command { const char *name; int (*run)(int argc, char **argv); } commands[] = {
    { "snapshot", snapshot_main },
};

int main(int argc, char **argv) {
    size_t i;
    report_init();
    fs_set_argv0(argv[0]);
    if (argc < 2 || !strcmp(argv[1], "--help") || !strcmp(argv[1], "-h")) {
        fputs(usage_text, argc < 2 ? stderr : stdout);
        return argc < 2 ? 2 : 0;
    }
    for (i = 0; i < sizeof commands / sizeof commands[0]; i++) {
        if (!strcmp(argv[1], commands[i].name)) {
            return commands[i].run(argc - 1, argv + 1);
        }
    }
    die(fmt("no command called %s", key(argv[1])), fmt("the commands are listed by %s", cmd("urt --help")), NULL);
    return 2;
}

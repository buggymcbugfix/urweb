/* format.c -- urt format (or fmt): the Ur/Web source formatter.
 *
 * The formatter is a program of its own, urt-format, written in SML
 * against the compiler's grammar and built from src/format.  This hands
 * it the arguments after `format` as they are: the one beside this
 * program.  `urt format --help` is its usage.
 */

#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "commands.h"
#include "fs.h"
#include "report.h"

static const char program_name[] = "urt-format";

/* The formatter's path into dst; 0 when there is none. */
static int find_formatter(char *dst) {
    char dir[PATHLEN];
    if (!program_dir(dir)) {
        return 0;
    }
    pathf(dst, "%s/%s", dir, program_name);
    return can_exec(dst);
}

int format_main(int argc, char **argv) {
    char program[PATHLEN];
    (void) argc;
    if (!find_formatter(program)) {
        die(fmt("no %s beside %s", path(program_name), path("urt")),
            fmt("it is built by %s in the urt directory", cmd("make")), NULL);
    }
    argv[0] = program;
    execv(program, argv);
    die(fmt("cannot run %s: %s", path(program), strerror(errno)), NULL);
    return 2;
}

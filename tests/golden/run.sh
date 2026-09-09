#!/bin/sh


# GOLDEN TESTS
# ~~~~~~~~~~~~
#
# Run the compiler on a case and compare its output with a file.
#
# A test is a directory holding a file named 'args', at any depth below a
# family directory tests/golden/FAMILY.  The family (the first path
# component) decides how the compiler is run and what is compared; the
# families are listed at the end of this header.  The test's program is the
# nearest directory at or above it that holds a .urp file.  The compiler is
# run in the program's directory with the family's flags and the contents of
# 'args' (flags and the project name, relative to the program's directory.
# The output is then compared with the file 'expected' next to 'args'. 
# Anything else in a test's directory (a README, say) is ignored by the runner.
#
# DIRECTORY STRUCTURE
#
#   tests/golden/urp/
#   |-- README.md               every level should have a README!
#   |-- precedence/             one program, one test per command line
#   |   |-- baseline/
#   |   |   |-- README.md
#   |   |   |-- args            precedence
#   |   |   `-- expected
#   |   |-- flags/
#   |   |   |-- README.md
#   |   |   |-- args            -dbms sqlite -prefix /flag/ ... precedence
#   |   |   `-- expected
#   |   |-- precedence.ur
#   |   `-- precedence.urp
#   `-- scope/                  one program, its one test beside it
#       |-- README.md
#       |-- args                scope
#       |-- expected
#       |-- scope.ur
#       |-- scope.urp
#       |-- scopelib.ur
#       `-- scopelib.urp
#
# EXAMPLE INVOCATIONS
#
#   tests/golden/run.sh                run every test of every family
#   tests/golden/run.sh --update       overwrite every 'expected' with the current output
#   tests/golden/run.sh PATH...        only the tests below these directories: a family
#                                      name such as 'urp', a deeper directory, or an
#                                      'args' file, relative to tests/golden (or
#                                      absolute)
#
# ADDING TEST CASES
#
# To add a test, write its 'args' next to the program and run with -u: a
# missing 'expected' is created, so there is no empty file to make by hand.
# Without -u a missing 'expected' is a failure, not a pass, so that a case
# whose golden was never committed cannot slip through CI.
#
# FAMILIES
#
#   urp        urweb -stop parseJob ARGS   The parsed and merged job, the settings
#                                          that .urp directives set directly, and any
#                                          warnings or errors; stops before reading
#                                          any source file.
#   typecheck  urweb -tc ARGS              What elaboration says: type errors with
#                                          their positions, or nothing when the
#                                          program typechecks.
#   compile    urweb -stop checknest ARGS  The generated C, from every phase up
#                                          to and including C generation but
#                                          without running the C compiler; for a
#                                          program that does not compile, the
#                                          diagnostics instead.

start=$(pwd -P)
cd "$(dirname "$0")" || exit 1
here=$(pwd -P)

urweb=${URWEB:-$here/../../bin/urweb}
case $urweb in
    /*) ;;
    *) urweb=$start/$urweb ;;
esac
# The in-tree compiler needs -boot to find the library in the source tree;
# an installed one (URWEB set) must not get it.
urweb_flags=${URWEB_FLAGS-$([ -n "$URWEB" ] || echo '-boot -noEmacs')}

# ✨reproducibility✨
SOURCE_DATE_EPOCH=0
export SOURCE_DATE_EPOCH

update=
case $1 in
    -u|--update) update=1; shift ;;
esac
[ $# -gt 0 ] || set -- .

# One function per family.  Each is called in the program's directory with
# the test's arguments and prints what the golden holds.

run_urp() {
    "$urweb" $urweb_flags -stop parseJob "$@" 2>&1 \
        | sed -e '/Stopped compilation after phase parseJob$/d'
}

run_typecheck() {
    "$urweb" $urweb_flags -tc "$@" 2>&1
}
# 1. The C includes reference the build machine's absolute paths, as set by the configure script.
# 2. `urweb.js` is embedded as one string, followed by the program's own code.
#    We strip this as we don't want to bloat our golden tests
run_compile() {
    "$urweb" $urweb_flags -stop checknest "$@" 2>&1 \
        | sed -e '/Stopped compilation after phase checknest$/d' \
              -e 's|^\( *#include "\)[^"]*/\(include/urweb/[^"]*"\)|\1\2|' \
              -e 's|^\( *#include <\)/[^>]*/\([^/>]*>\)|\1\2|' \
              -e 's|^\( *static char jslib\[\] = \)"..*";$|\1"*script elided*";|'
}

failed=0
for args in $(find "$@" -name args -type f | LC_ALL=C sort); do
    args=${args#"$here"/}
    dir=$(dirname "$args")
    dir=${dir#./}
    expected=$dir/expected
    family=${dir%%/*}
    if ! type "run_$family" >/dev/null 2>&1; then
        echo "FAIL $dir (no such family: $family)" >&2
        failed=1
        continue
    fi
    prog=$dir
    while [ "$prog" != . ] && ! ls "$prog"/*.urp >/dev/null 2>&1; do
        prog=$(dirname "$prog")
    done
    [ "$prog" != . ] || prog=$dir
    dir=tests/golden/$dir # to get jump-to-file in fancy terminals
    actual=$(cd "$prog" && "run_$family" $(cat "$here/$args") \
             | sed -e "s|$here|<tests/golden>|g") # A file above the program's directory keeps its absolute path 
    if [ -n "$update" ]; then
        if [ -f "$expected" ]; then verb=updated; else verb=created; fi
        printf '%s\n' "$actual" > "$expected"
        echo "$verb $dir"
    elif [ ! -f "$expected" ]; then
        printf '%s\n' "$actual" | diff -u /dev/null -
        echo "FAIL $dir (no expected file; run tests/golden/run.sh -u $dir to create it)" >&2
        failed=1
    elif printf '%s\n' "$actual" | diff -u "$expected" -; then
        echo "ok $dir"
    else
        echo "FAIL $dir (run tests/golden/run.sh -u $dir to accept the new output)" >&2
        failed=1
    fi
done
exit $failed

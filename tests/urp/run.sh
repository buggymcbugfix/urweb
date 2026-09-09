#!/bin/sh
# Golden tests for .urp parsing.
#
# A test is a directory holding a file named 'expected', at any depth below
# tests/urp.  Its program is the nearest directory at or above it that holds a
# .urp file.  The compiler is run in the program's directory with
# '-stop parseJob' and the contents of the test's 'args' file (flags and the
# project name, relative to the program's directory; without 'args' the
# compiler runs with no project and its complaint is the expected output).
# With '-stop parseJob' it prints the parsed and merged job, the settings that
# .urp directives set directly, and any warnings or errors, then stops before
# reading any source file.  That output is compared with 'expected', with the
# absolute path of tests/urp replaced by '<tests/urp>' wherever it appears, so
# that a path shown relative in 'expected' really was printed relative.
# Anything else in a test's directory (a 'readme', say) is ignored by the
# runner.
#
# So a program can carry one test, with 'args' and 'expected' next to its .urp
# file, or several, each in its own subdirectory:
#
#   tests/urp/scope/{args,expected,scope.urp,...}
#   tests/urp/precedence/{precedence.urp,precedence.ur}
#   tests/urp/precedence/no-flags/{args,expected}     args: precedence
#   tests/urp/precedence/flags/{args,expected}        args: -dbms sqlite ... precedence
#
#   tests/urp/run.sh                 run every test
#   tests/urp/run.sh -u              overwrite every 'expected' with the current output
#   tests/urp/run.sh [-u] PATH...    only the tests below these directories (or these
#                                    'expected' files); to add a test, create an
#                                    empty 'expected' and run with -u

start=$(pwd -P)
cd "$(dirname "$0")" || exit 1
here=$(pwd -P)

urweb=${URWEB:-$here/../../bin/urweb}
case $urweb in
    /*) ;;
    *) urweb=$start/$urweb ;;
esac

update=
case $1 in
    -u|--update) update=1; shift ;;
esac
[ $# -gt 0 ] || set -- .

failed=0
for expected in $(find "$@" -name expected -type f | LC_ALL=C sort); do
    dir=$(dirname "$expected")
    dir=${dir#./}
    prog=$dir
    while [ "$prog" != . ] && ! ls "$prog"/*.urp >/dev/null 2>&1; do
        prog=$(dirname "$prog")
    done
    [ "$prog" != . ] || prog=$dir
    actual=$(cd "$prog" && "$urweb" -stop parseJob $(cat "$here/$dir/args" 2>/dev/null) 2>&1 \
             | sed -e "s|$here|<tests/urp>|g" \
                   -e '/Stopped compilation after phase parseJob$/d')
    if [ -n "$update" ]; then
        printf '%s\n' "$actual" > "$expected"
        echo "updated $dir"
    elif printf '%s\n' "$actual" | diff -u "$expected" -; then
        echo "ok $dir"
    else
        echo "FAIL $dir (run tests/urp/run.sh -u $dir to accept the new output)" >&2
        failed=1
    fi
done
exit $failed

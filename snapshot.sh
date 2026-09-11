#!/bin/sh
#
# SNAPSHOT TESTS
# ==============
#
# Run the compiler on a project and keep its output as well as some intermediate state in files,
# so that a change to the compiler shows up as a diff.
# Think of them as a _contrast agent_ that alerts us to changes.
#
# DISCLAIMER: This is a mostly vibe-coded prototype. THIS MAY EAT UR
#
#
# DESCRIPTION
# -----------
#
# A project's snapshots live beside it: next to `hello.urp` is `hello.snapshot`:
#
#   hello.ur
#   hello.urp
#   hello.snapshot/
#   |-- args                        extra flags, if any; the project is implied
#   `-- expected/
#       |-- exitcode                the compiler's exit status
#       |-- stdout.txt              what the compiler wrote to stdout
#       |-- stderr.txt              ... and to stderr
#       |-- settings.txt            -saveSettings   the parsed and merged job
#       |-- parsetree.ur            -saveParsetree  the program as parsed
#       |-- typecheck.urs           -saveTypecheck  the signatures inferred
#       |-- schema.sql              -sql            the database schema
#       |-- client.js               -saveJs         the client-side script
#       |-- endpoints.json          -endpoints      the URLs the app serves
#       `-- server.c                -saveC          the generated C
#
# One project can have several snapshots (the same program under three database backends, say)
# by putting each in a case directory of its own:
#
#   shop.snapshot/
#   |-- mysql/
#   |   |-- args                    -dbms mysql
#   |   `-- expected/
#   |       `-- schema.sql
#   |-- postgres/
#   |   `-- ...
#   `-- sqlite/
#   |   `-- ...
#
#
# USAGE
# -----
#
#   snapshot.sh [PATH...]                     update the snapshots below the given projects
#   snapshot.sh --check [PATH...]             fail on a diff (you want this in CI)
#   snapshot.sh --list [PATH...]              list the snapshot cases matching for the given path(s)
#   snapshot.sh --create [PROJECT] [CASE...]  create a new snapshot set for the given project
#
# PATH is a project (demo/alert[.urp]), a snapshot directory (shop.snapshot),
# one case of it (shop.snapshot/sqlite) or a directory to search for snapshots.
# It defaults to the current directory.
#
# With '--create', the directory, an empty 'args' and an 'expected' of empty
# artifacts, and runs nothing; fill them in with a plain run, having first
# deleted the artifacts the project has no opinion about.  With no PROJECT it takes the only .urp in the
# current directory.  Name CASEs to get the nested form.
#
# The compiler is bin/urweb unless URWEB names another, and is given
# URWEB_FLAGS if that is set.

set -u

me=${0##*/}

# ---------------------------------------------------------------- reporting

if [ -t 1 ] && [ -z "${NO_COLOR-}" ] && [ "${TERM-dumb}" != dumb ]; then
    esc=$(printf '\033')
    red=$esc'[31m' green=$esc'[32m' yellow=$esc'[33m'
    blue=$esc'[34m' bold=$esc'[1m' dim=$esc'[2m' reset=$esc'[0m'
else
    red='' green='' yellow='' blue='' bold='' dim='' reset=''
fi

# A result line: a coloured verdict, the case, and anything worth adding.
say() {
    printf '%s%s%s %s%s\n' "$1" "$2" "$reset" "$3" "$4"
}

warn() {
    printf '%s%s:%s %s\n' "$yellow" "$me" "$reset" "$*" >&2
}

# Something is wrong with the tests themselves rather than with the compiler:
# say so and stop, since carrying on would only bury it.
die() {
    printf '%s%s:%s %s\n' "$red$bold" "$me" "$reset" "$1" >&2
    shift
    for line in "$@"; do
        printf '  %s%s%s\n' "$dim" "$line" "$reset" >&2
    done
    exit 2
}

# -------------------------------------------------------------- the artifacts

# Everything the compiler can be asked to write.  For each, artifact_spec
# gives how far the compiler has to run -- a rank, and the phase it may stop
# after once that artifact is written -- and the flag that asks for it.
#
# The ranks are the only thing this script assumes about the order of the
# compiler's phases, and a run that ends without producing something it asked
# for says so rather than quietly comparing an empty file, so a reordering in
# the compiler is loud here.  The assumption would go away if the compiler
# could be told to stop once it has written everything it was asked for.
artifacts='exitcode stdout.txt stderr.txt settings.txt parsetree.ur typecheck.urs schema.sql client.js endpoints.json server.c'

artifact_spec() {
    case $1 in
        exitcode)       echo '0 parseJob -' ;;
        stdout.txt)     echo '0 parseJob -' ;;
        stderr.txt)     echo '0 parseJob -' ;;
        settings.txt)   echo '1 parseJob -saveSettings' ;;
        parsetree.ur)   echo '2 parse -saveParsetree' ;;
        typecheck.urs)  echo '3 elaborate -saveTypecheck' ;;
        schema.sql)     echo '4 sqlify -sql' ;;
        client.js)      echo '5 jscomp -saveJs' ;;
        endpoints.json) echo '6 endpoints -endpoints' ;;
        server.c)       echo '7 checknest -saveC' ;;
        *)              echo '' ;;
    esac
}

# The artifacts are written in a temporary directory, and some of them say
# where that was -- the settings dump names every file the job was given, so
# a project that keeps both settings.txt and endpoints.json would otherwise
# snapshot a path that is different on every run.  The directory goes,
# leaving the name the snapshot knows the file by.
#
# And two things in the generated C say more about the machine it was built
# on than about the program: the include paths, absolute because ./configure
# was given a prefix, and the client-side script, embedded as two string
# literals holding a hundred kilobytes of runtime and program on two lines.
# client.js keeps the half of that which is the compiler's work, in a form
# one can read.
normalise() {
    case $1 in
        server.c)
            sed -e "s|$work/||g" \
                -e 's|^\( *#include "\)[^"]*/\(include/urweb/[^"]*"\)|\1\2|' \
                -e 's|^\( *#include <\)/[^>]*/\([^/>]*>\)|\1\2|' \
                -e 's|^\( *static char jslib\[\] = \)"..*";$|\1"*runtime elided*";|' \
                -e 's|^\( *static char jsapp\[\] = \)"..*";$|\1"*script elided*";|' ;;
        *)
            sed -e "s|$work/||g" ;;
    esac
}

# ------------------------------------------------------------------ arguments

check='' create='' list=''
while [ $# -gt 0 ]; do
    case $1 in
        --check|-k) check=1; shift ;;
        --create|-c) create=1; shift; break ;;
        --list|-l) list=1; shift ;;
        --help|-h)
            sed -n '3,/^$/p' "$0" | sed -e 's/^# \{0,1\}//' -e 's/^#$//'
            exit 0 ;;
        --) shift; break ;;
        -*) die "unrecognised option '$1'" \
                "usage: $me [--check|--list] [PATH...]" \
                "       $me --create [PROJECT] [CASE...]" ;;
        *) break ;;
    esac
done

[ -z "$create" ] || [ -z "$check$list" ] || die "--create goes with neither --check nor --list"

# The compiler: beside this script by default, since that is where the build
# leaves it.  Made absolute, because the project is named relative to the
# directory we were invoked from and that is where the compiler runs.
# Listing the cases takes no compiler.
here=$(cd "$(dirname "$0")" && pwd -P) || exit 2
urweb=${URWEB:-$here/bin/urweb}
case $urweb in
    /*) ;;
    *) urweb=$(pwd -P)/$urweb ;;
esac
[ -n "$list" ] || [ -x "$urweb" ] || die "no compiler at $urweb" \
    "build one with 'make', or set URWEB to name another"

# An in-tree compiler needs -boot to find the library in the source tree; an
# installed one (URWEB set) must not get it.
urweb_flags=${URWEB_FLAGS-$([ -n "${URWEB-}" ] || echo '-boot -noEmacs')}

# The compiler stamps what it reads into what it writes -- the generated code
# serves its static files with a Last-Modified taken from the newest source it
# read -- so pin that.  Outright, rather than deferring to a value already in
# the environment, because nix-shell exports one of its own and the snapshots
# would then depend on being inside one.
SOURCE_DATE_EPOCH=0
export SOURCE_DATE_EPOCH

tmp=''
# shellcheck disable=SC2329 # called from the traps below
cleanup() {
    [ -z "$tmp" ] || rm -rf "$tmp"
}
trap cleanup EXIT
trap 'cleanup; trap - INT; kill -INT $$' INT
trap 'cleanup; exit 143' TERM

# ------------------------------------------------------------------- --create

if [ -n "$create" ]; then
    project=${1-}
    [ $# -eq 0 ] || shift

    if [ -z "$project" ]; then
        found='' count=0
        for f in ./*.urp; do
            [ -e "$f" ] || break
            found=${f#./}
            count=$((count + 1))
        done
        [ "$count" -ne 0 ] || die "no .urp file in $(pwd -P)" \
            "name the project: $me --create PROJECT"
        [ "$count" -eq 1 ] || die "$count .urp files in $(pwd -P)" \
            "name the one you mean: $me --create PROJECT"
        project=${found%.urp}
    fi
    project=${project%/}
    project=${project%.snapshot}
    project=${project%.urp}

    [ -f "$project.urp" ] || [ -f "$project.ur" ] || die \
        "no project called '$project'" \
        "expected $project.urp or $project.ur to be there"

    snap=$project.snapshot
    [ ! -e "$snap" ] || die "$snap is in the way" \
        "delete it first if you meant to start again"

    if [ $# -eq 0 ]; then
        cases=$snap
    else
        cases=''
        for c in "$@"; do
            cases="$cases $snap/$c"
        done
    fi

    for d in $cases; do
        mkdir -p "$d/expected" || exit 2
        : > "$d/args"
        for a in $artifacts; do
            : > "$d/expected/$a"
        done
        say "$blue" CREATED "$d" " (args, and $(echo "$artifacts" | wc -w) empty artifacts under expected/)"
    done
    printf '%sdelete what this project has no opinion about, then run %s to fill in the rest%s\n' \
        "$dim" "$me" "$reset"
    exit 0
fi

# ---------------------------------------------------------- finding the cases

tmp=$(mktemp -d) || die "cannot make a temporary directory"

[ $# -gt 0 ] || set -- .

: > "$tmp/snapshots"
for p in "$@"; do
    p=${p%/}
    found=''
    case $p in
        *.snapshot)
            if [ -d "$p" ]; then
                echo "$p" >> "$tmp/snapshots"
                found=1
            fi ;;
        *.snapshot/*)
            # One case of a nested snapshot, named by its directory.
            case ${p%/*} in
                *.snapshot)
                    if [ "${p##*/}" != expected ] && [ -d "$p/expected" ]; then
                        echo "$p" >> "$tmp/snapshots"
                        found=1
                    fi ;;
            esac ;;
    esac
    if [ -z "$found" ]; then
        stripped=${p%.urp}
        if [ -d "$stripped.snapshot" ]; then
            echo "$stripped.snapshot" >> "$tmp/snapshots"
            found=1
        elif [ -d "$p" ]; then
            find "$p" -type d -name '*.snapshot' | LC_ALL=C sort >> "$tmp/snapshots"
            found=1
        fi
    fi
    [ -n "$found" ] || die "nothing to test at '$p'" \
        "expected a project ($p.urp), a snapshot directory ($p.snapshot)," \
        "a case in one ($p.snapshot/CASE), or a directory to search for snapshots"
done

if [ ! -s "$tmp/snapshots" ]; then
    warn "no snapshot directories under $*"
    exit 0
fi

# GNU diff labels its two sides for us; without that the header names a
# temporary file, which is only confusing.
if diff -u --label a --label b /dev/null /dev/null >/dev/null 2>&1; then
    labels=1
else
    labels=''
fi

show_diff() {
    if [ -n "$labels" ]; then
        diff -u --label "$1" --label "$1 (now)" "$1" "$2"
    else
        diff -u "$1" "$2"
    fi
}

# -------------------------------------------------------------------- running

# Wall-clock time, in tenths of a second, for saying how long a run took.
# date's %N is a GNU extension; where it is missing, whole seconds have to do.
case $(date +%s%N 2>/dev/null) in
    *[!0-9]*|'') tenths() { echo $(( $(date +%s) * 10 )); } ;;
    *) tenths() { echo $(( $(date +%s%N) / 100000000 )); } ;;
esac

# "1.2s" for the result line, or nothing when the run was quick.
took() {
    [ "$1" -gt 10 ] || return 0
    printf ' %s%d.%ds%s' "$dim" $(( $1 / 10 )) $(( $1 % 10 )) "$reset"
}

failed=0
n_cases=0 n_ok=0 n_bad=0 n_changed=0 n_skipped=0 n_nonzero=0
started=$(tenths)
work=$tmp/work

run_case() {
    case_dir=$1
    project=$2
    want_dir=$case_dir/expected

    rm -rf "$work"
    mkdir -p "$work" || exit 2

    # What this case asks for, and how far the compiler has to go for it.
    find "$want_dir" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; \
        | LC_ALL=C sort > "$tmp/entries" || exit 2
    : > "$tmp/want"
    flags='' maxrank=0 stop=parseJob
    while read -r a; do
        [ -n "$a" ] || continue
        spec=$(artifact_spec "$a")
        [ -n "$spec" ] || die "$want_dir/$a is not something the compiler produces" \
            "the artifacts are: $artifacts" \
            "delete that file, or correct its name"
        rank=${spec%% *}
        rest=${spec#* }
        phase=${rest%% *}
        flag=${rest#* }
        echo "$a" >> "$tmp/want"
        [ "$flag" = - ] || flags="$flags $flag $work/$a"
        if [ "$rank" -gt "$maxrank" ]; then
            maxrank=$rank
            stop=$phase
        fi
    done < "$tmp/entries"

    if [ ! -s "$tmp/want" ]; then
        warn "$want_dir asks for nothing; '$me --create' shows what there is to ask for"
        n_skipped=$((n_skipped + 1))
        return 0
    fi
    n_cases=$((n_cases + 1))

    extra=''
    [ ! -f "$case_dir/args" ] || extra=$(cat "$case_dir/args")

    # How far to run.  A case whose own args say that is left to it.
    case " $extra " in
        *' -stop '*|*' -stopQuiet '*|*' -tc '*) ;;
        *) flags="$flags -stopQuiet $stop" ;;
    esac

    t0=$(tenths)
    # shellcheck disable=SC2086 # the flags and the case's own args are lists
    "$urweb" $urweb_flags $flags $extra "$project" \
        > "$work/stdout.txt" 2> "$work/stderr.txt"
    status=$?
    elapsed=$(( $(tenths) - t0 ))
    echo "$status" > "$work/exitcode"

    # What was asked for and not written.  After a failed run that is to be
    # expected, and the result line names them so that an empty artifact
    # can be told from one the compiler never got to.  If the compiler was
    # content and still did not write something, the fault is here rather
    # than in the program under test.
    missing=''
    while read -r a; do
        spec=$(artifact_spec "$a")
        rest=${spec#* }
        [ "${rest#* }" != - ] || continue
        [ ! -f "$work/$a" ] || continue
        [ "$status" -ne 0 ] || die "urweb was asked for $a, exited 0, and wrote no such file" \
            "it was stopped after '$stop', which this runner takes to be late enough" \
            "if the compiler's phases have moved, artifact_spec in $me needs to know"
        missing="${missing:+$missing, }$a"
    done < "$tmp/want"

    # The compiler's exit status and how long it took, after the verdict.
    note=''
    if [ "$status" -ne 0 ]; then
        n_nonzero=$((n_nonzero + 1))
        note=" ${yellow}exit $status$reset"
        [ -z "$missing" ] || note="$note, not written: $missing"
    fi
    note="$note$(took "$elapsed")"

    bad='' changed=''
    while read -r a; do
        [ -f "$work/$a" ] || : > "$work/$a"
        normalise "$a" < "$work/$a" > "$work/$a.now" || exit 2
        if [ -n "$check" ]; then
            if ! show_diff "$want_dir/$a" "$work/$a.now"; then
                bad="${bad:+$bad, }$a"
            fi
        else
            cmp -s "$want_dir/$a" "$work/$a.now" || changed="${changed:+$changed, }$a"
            cp "$work/$a.now" "$want_dir/$a" || exit 2
        fi
    done < "$tmp/want"

    if [ -n "$check" ]; then
        if [ -z "$bad" ]; then
            say "$green" 'ok' "$case_dir" "$note"
            n_ok=$((n_ok + 1))
        else
            say "$red" 'FAIL' "$case_dir" " ($bad)$note"
            n_bad=$((n_bad + 1))
            failed=1
        fi
    elif [ -n "$changed" ]; then
        say "$yellow" 'UPDATED' "$case_dir" " ($changed)$note"
        n_changed=$((n_changed + 1))
    else
        say "$green" 'ok' "$case_dir" "$note"
        n_ok=$((n_ok + 1))
    fi
}

# One line for all of it, once the last case has had its say.
summary() {
    s=''
    [ "$n_ok" -eq 0 ] || s="${s:+$s, }$green$n_ok ok$reset"
    [ "$n_bad" -eq 0 ] || s="${s:+$s, }$red$n_bad FAIL$reset"
    [ "$n_changed" -eq 0 ] || s="${s:+$s, }$yellow$n_changed updated$reset"
    [ "$n_skipped" -eq 0 ] || s="${s:+$s, }$n_skipped asking for nothing"
    [ "$n_nonzero" -eq 0 ] || s="$s; $n_nonzero with non-zero exit"
    elapsed=$(( $(tenths) - started ))
    printf '%s%d case%s%s: %s, in %d.%ds\n' "$bold" "$n_cases" "$([ "$n_cases" -eq 1 ] || echo s)" "$reset" \
        "$s" $(( elapsed / 10 )) $(( elapsed % 10 ))
}

# With --list, a case is named and left alone.
do_case() {
    if [ -n "$list" ]; then
        echo "$1"
    else
        run_case "$1" "$2"
    fi
}

while read -r snap; do
    [ -n "$snap" ] || continue

    # A single case was asked for: its snapshot directory is checked like
    # any other, and then only that case runs.
    case $snap in
        *.snapshot) only='' ;;
        *) only=$snap; snap=${snap%/*} ;;
    esac

    # The project is the snapshot directory without its suffix, unless the
    # case says otherwise -- which it must when the compiler is given a
    # directory rather than a project, as in -demo mode.
    base=${snap%.snapshot}
    if [ -f "$snap/project" ]; then
        named=$(cat "$snap/project")
        project=${snap%/*}/$named
    else
        project=$base
        [ -f "$base.urp" ] || [ -f "$base.ur" ] || die \
            "$snap is named for a project '${base##*/}' that is not beside it" \
            "expected $base.urp or $base.ur" \
            "write the project's name in $snap/project if it goes by another"
    fi

    # Flat or nested, decided by whether the snapshot directory has an
    # 'expected' of its own, and never both.
    find "$snap" -mindepth 1 -maxdepth 1 -type d ! -name expected \
        | LC_ALL=C sort > "$tmp/subdirs"
    if [ -d "$snap/expected" ]; then
        [ ! -s "$tmp/subdirs" ] || die "$snap has an expected of its own and case directories too" \
            "cases: $(tr '\n' ' ' < "$tmp/subdirs")" \
            "a project's snapshots all nest, or none of them do"
        do_case "$snap" "$project"
    elif [ -s "$tmp/subdirs" ]; then
        while read -r c; do
            [ -z "$only" ] || [ "$c" = "$only" ] || continue
            [ -d "$c/expected" ] || die "$c has no expected directory" \
                "every case under $snap needs one; '$me --create' makes them"
            do_case "$c" "$project"
        done < "$tmp/subdirs"
    else
        die "$snap holds no snapshots" \
            "expected $snap/expected, or case directories with one each" \
            "'$me --create' makes them"
    fi
done < "$tmp/snapshots"

[ -n "$list" ] || summary
exit $failed

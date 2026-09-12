#!/bin/sh
#
# Build the fixture tree for urt/check in the directory named: projects,
# their snapshots under PROJECT.urt/snapshot/CASE, and one of every mistake
# the runner is meant to notice.  The artifacts under expected/ start
# empty; a plain run fills them from the stand-in compiler beside this
# script.
#
# A script rather than files in the repository, so that nothing here
# looks like a snapshot to a run over the whole tree.

set -eu
root=$1
mkdir -p "$root"
cd "$root"

# proj DIR NAME: a project, .ur and .urp, under DIR
proj() {
    mkdir -p "$1"
    printf 'fun main () = return <xml>%s</xml>\n' "$2" > "$1/$2.ur"
    printf '%s\n' "$2" > "$1/$2.urp"
}

# snap DIR ARTIFACT...: a case directory with empty args and expected/
snap() {
    d=$1; shift
    mkdir -p "$d/expected"
    : > "$d/args"
    for a in "$@"; do : > "$d/expected/$a"; done
}

# The good ones.
proj . hello
snap hello.urt/snapshot/1 exitcode stdout.txt stderr.txt settings.txt
proj . shop
mkdir -p shop.urt/snapshot
printf 'One case per database.\n' > shop.urt/snapshot/README.md
for db in mysql postgres sqlite; do
    snap "shop.urt/snapshot/$db" exitcode schema.sql
    printf -- '-dbms %s\n' "$db" > "shop.urt/snapshot/$db/args"
done
proj . lonely
proj sub deep
snap sub/deep.urt/snapshot/1 exitcode stdout.txt parsetree.ur typecheck.urs client.js endpoints.json server.c
printf 'The whole pipeline.\n' > sub/deep.urt/README.md
mkdir -p sub/deep.urt/watcher
: > sub/deep.urt/watcher/state
proj sub/demo first
proj sub/demo second
snap sub/demo/merging.urt/snapshot/1 exitcode stdout.txt
printf '.\n' > sub/demo/merging.urt/project
printf -- '-demo /Merging\n' > sub/demo/merging.urt/snapshot/1/args
mkdir -p empty

# The mistakes.
mkdir -p sub/orphan.urt/snapshot/1/expected
: > sub/orphan.urt/snapshot/1/expected/exitcode
proj broken flat
mkdir -p broken/flat.urt/snapshot/expected
: > broken/flat.urt/snapshot/expected/exitcode
: > broken/flat.urt/snapshot/args
proj broken empty
mkdir -p broken/empty.urt/snapshot
printf 'nothing here\n' > broken/empty.urt/snapshot/README.md
proj broken stray
snap broken/stray.urt/snapshot/1 exitcode
printf 'todo\n' > broken/stray.urt/snapshot/notes.txt
: > broken/stray.urt/snapshot/1/expected/bogus.txt
mkdir -p broken/stray.urt/snapshot/1/expected/sub
: > broken/stray.urt/stray.txt
proj broken nocase
snap broken/nocase.urt/snapshot/a exitcode
mkdir -p broken/nocase.urt/snapshot/b
: > broken/nocase.urt/snapshot/b/args
proj broken twins
for c in one two three four; do snap "broken/twins.urt/snapshot/$c" exitcode; done
printf -- '-dbms sqlite' > broken/twins.urt/snapshot/one/args
printf -- '  -dbms\t sqlite\n\n' > broken/twins.urt/snapshot/two/args
rm broken/twins.urt/snapshot/four/args
proj broken nothing
snap broken/nothing.urt/snapshot/1
proj broken noexit
snap broken/noexit.urt/snapshot/1 exitcode parsetree.ur
proj broken fails
snap broken/fails.urt/snapshot/1 exitcode stderr.txt schema.sql
printf -- '-dbms bogus\n' > broken/fails.urt/snapshot/1/args
proj broken stopper
snap broken/stopper.urt/snapshot/1 exitcode stdout.txt
printf -- '-stop parse\n' > broken/stopper.urt/snapshot/1/args
# A case that cannot be named stops the run, so it comes last of all.
proj zz badname
snap zz/badname.urt/snapshot/c.d exitcode

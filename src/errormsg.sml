(* Copyright (c) 2008, 2012, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *)

structure ErrorMsg :> ERROR_MSG = struct

type pos = {line : int,
            char : int}

type span = {file : string,
             first : pos,
             last : pos}

type 'a located = 'a * span


fun posToString {line, char} =
    String.concat [Int.toString line, ":", Int.toString char]

(* Directories as (NAME, absolute path) pairs; see displayFile. *)
val pathRoots : (string * string) list ref = ref []

fun setPathRoots roots =
    let
        val cwd = OS.FileSys.getDir ()
    in
        pathRoots := map (fn (name, dir) => (name, OS.Path.mkAbsolute {path = dir, relativeTo = cwd})) roots
    end

(* Is file (a canonical path) below directory dir?  Returns the rest of the path. *)
fun below (dir, file) =
    let
        val dir = if String.isSuffix "/" dir then dir else dir ^ "/"
    in
        if String.isPrefix dir file then
            SOME (String.extract (file, size dir, NONE))
        else
            NONE
    end

(* A file below a path root is $NAME/rest, with the longest root winning, so
 * that it reads as it would in a .urp file and does not change with the
 * directory the compiler runs in.  Failing that, a file below the current
 * directory is relative to it, as other compilers report files.  Anything
 * else keeps its absolute path; climbing out of the current directory with
 * '..' would pull in unrelated directories. *)
fun displayFile "" = ""
  | displayFile file =
    let
        val file = OS.Path.mkCanonical file

        fun longest ((name, dir), best) =
            case (below (dir, file), best) of
                (NONE, _) => best
              | (SOME rest, SOME (_, dir', _)) =>
                if size dir > size dir' then SOME (name, dir, rest) else best
              | (SOME rest, NONE) => SOME (name, dir, rest)
    in
        case foldl longest NONE (!pathRoots) of
            SOME (name, _, rest) => "$" ^ name ^ "/" ^ rest
          | NONE =>
            case below (OS.FileSys.getDir (), file) of
                SOME rest => rest
              | NONE => file
    end

fun spanToString {file, first, last} =
    String.concat [displayFile file, ":", posToString first, "-", posToString last]

val dummyPos = {line = 0,
                char = 0}
val dummySpan = {file = "",
                 first = dummyPos,
                 last = dummyPos}


val file = ref ""
val numLines = ref 1
val lines : int list ref = ref []

fun resetPositioning fname = (file := fname;
                              numLines := 1;
                              lines := [])

fun newline pos = (numLines := !numLines + 1;
                   lines := pos :: !lines)

fun lastLineStart () =
    case !lines of
        [] => 0
      | n :: _ => n+1

fun posOf n =
    let
        fun search lineNum lines =
            case lines of
                [] => {line = 1,
                       char = n}
              | bound :: rest =>
                if n > bound then
                    {line = lineNum,
                     char = n - bound - 1}
                else
                    search (lineNum - 1) rest
    in
        search (!numLines) (!lines)
    end

fun spanOf (pos1, pos2) = {file = !file,
                           first = posOf pos1,
                           last = posOf pos2}


val errors = ref false
val errorLog = ref ([]: { span: span
                        , message: string } list)
fun readErrorLog () = !errorLog
val structuresCurrentlyElaborating: ((string * bool) list) ref = ref nil

fun startElabStructure s =
    structuresCurrentlyElaborating := ((s, false) :: !structuresCurrentlyElaborating)
fun stopElabStructureAndGetErrored s =
    let 
        val errored =
            case List.find (fn x => #1 x = s) (!structuresCurrentlyElaborating) of
                NONE => false
              | SOME tup => #2 tup
        val () = structuresCurrentlyElaborating :=
                 (List.filter (fn x => #1 x <> s) (!structuresCurrentlyElaborating))
    in 
        errored
    end
fun resetStructureTracker () =
    structuresCurrentlyElaborating := []

fun resetErrors () = (errors := false; errorLog := [])
fun anyErrors () = !errors
val callOnError = ref (fn () => ())
fun error s = (TextIO.output (TextIO.stdErr, s);
               TextIO.output1 (TextIO.stdErr, #"\n");
               errors := true;
               !callOnError();
               structuresCurrentlyElaborating :=
                 List.map (fn (s, e) => (s, true)) (!structuresCurrentlyElaborating))

fun errorAt (span : span) s = (TextIO.output (TextIO.stdErr, displayFile (#file span));
                               TextIO.output (TextIO.stdErr, ":");
                               TextIO.output (TextIO.stdErr, posToString (#first span));
                               TextIO.output (TextIO.stdErr, ": (to ");
                               TextIO.output (TextIO.stdErr, posToString (#last span));
                               TextIO.output (TextIO.stdErr, ") ");
                               errorLog := ({ span = span
                                            , message = s
                                            } :: !errorLog);
                               error s)
fun errorAt' span s = errorAt (spanOf span) s

fun withOnError onError cont =
    let
        val f = !callOnError
    in
        callOnError := onError;
        (cont () before callOnError := f)
        handle ex => (callOnError := f; raise ex)
    end
end

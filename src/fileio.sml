structure FileIO :> FILE_IO = struct

val mostRecentModTimeRef = ref (Time.zeroTime)

fun checkFileModTime fname =
  let
      val mtime = OS.FileSys.modTime fname
      val mostRecentMod = !mostRecentModTimeRef
      val resetTime = Globals.getResetTime ()
      fun lessThan (a, b) = LargeInt.compare (Time.toSeconds a, Time.toSeconds b) = LESS
      infix lessThan
  in
      if mostRecentMod lessThan mtime andalso mtime lessThan resetTime
      then mostRecentModTimeRef := mtime
      else ()
  end

fun mostRecentModTime () =
  case OS.Process.getEnv "SOURCE_DATE_EPOCH" of
      SOME s =>
        (case LargeInt.fromString s of
             SOME n => Time.fromSeconds n
           | NONE => Globals.getResetTime ())
    | NONE =>
        if Time.compare (!mostRecentModTimeRef, Time.zeroTime) = EQUAL
        then Globals.getResetTime ()
        else !mostRecentModTimeRef

fun txtOpenIn fname =
  let
      val inf = TextIO.openIn fname
      val () = checkFileModTime fname
  in
      inf
  end

fun binOpenIn fname =
  let
      val inf = BinIO.openIn fname
      val () = checkFileModTime fname
  in
      inf
  end

end

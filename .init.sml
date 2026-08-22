fun r () = CM.make "src/urweb.cm";
val _ = r ();
fun c fp = Compiler.compile fp;
val _ = Compiler.enableBoot ();

local
	open Sttyle
	infix ++
	val orange = rgb (255, 125, 12)
	fun code txt = sttyle [bold, bg (color256 238)] (text (" " ^ txt ^ " "))
	val banner =
		sttyle []
			(
				nl
				++ sttyle [bold, fg black, bg magenta] (text " WELCOME, BRAVE SOUL! ")
				++ nl
				++ nl
				++ text "To compile an Ur/Web project "
				++ sttyle [underline, fg blue] (text "tests/alert.ur")
				++ text ", run"
				++ nl
				++ text "  "
				++ code "Compiler.compile \"tests/alert\";"
				++ text " or "
				++ code "c \"tests/alert\";"
				++ nl
				++ nl
				++ text "To recompile Ur/Web itself, run"
				++ nl
				++ text "  "
				++ code "CM.make \"src/urweb.cm\";"
				++ text " or "
				++ code "r ();"
				++ nl
				++ nl
			)
in
	val _ = print (render banner)
end;


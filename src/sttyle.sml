structure Sttyle :> STTYLE =
struct
	exception Sttyle of string

	datatype color =
		Basic of int
		| Bright of int
		| Ansi256 of int
		| Rgb of int * int * int
		| Default

	datatype attr = Attr of int list

	datatype doc =
		Text of string
		| Cat of doc list
		| Style of int list * doc

	val black = Basic 0
	val red = Basic 1
	val green = Basic 2
	val yellow = Basic 3
	val blue = Basic 4
	val magenta = Basic 5
	val cyan = Basic 6
	val white = Basic 7
	val default = Default

	fun byte what n =
		if n < 0 orelse n > 255 then
			raise Sttyle (what ^ ": " ^ Int.toString n ^ " out of range 0-255")
		else
			n

	fun bright (Basic n) = Bright n
		| bright (Bright n) = Bright n
		| bright _ = raise Sttyle "bright: only basic colors have a bright variant"

	fun color256 n = Ansi256 (byte "color256" n)

	fun rgb (r, g, b) = Rgb (byte "rgb" r, byte "rgb" g, byte "rgb" b)

	fun fg (Basic n) = Attr [30 + n]
		| fg (Bright n) = Attr [90 + n]
		| fg (Ansi256 n) = Attr [38, 5, n]
		| fg (Rgb (r, g, b)) = Attr [38, 2, r, g, b]
		| fg Default = Attr [39]

	fun bg (Basic n) = Attr [40 + n]
		| bg (Bright n) = Attr [100 + n]
		| bg (Ansi256 n) = Attr [48, 5, n]
		| bg (Rgb (r, g, b)) = Attr [48, 2, r, g, b]
		| bg Default = Attr [49]

	val bold = Attr [1]
	val dim = Attr [2]
	val italic = Attr [3]
	val underline = Attr [4]
	val blink = Attr [5]
	val reverse = Attr [7]
	val hidden = Attr [8]
	val strike = Attr [9]

	val esc = #"\027"

	fun text s =
		if CharVector.exists (fn c => c = esc) s then
			raise Sttyle "text: embedded escape character would break nesting"
		else
			Text s

	val nl = Text "\n"

	val empty = Cat []

	fun cat ds = Cat ds

	infix ++
	fun a ++ b = Cat [a, b]

	fun sttyle attrs d = Style (List.concat (map (fn Attr cs => cs) attrs), d)

	fun sgr [] = ""
		| sgr cs = "\027[" ^ String.concatWith ";" (map Int.toString cs) ^ "m"

	fun walk (Text s, _, acc) = s :: acc
		| walk (Cat ds, amb, acc) = foldl (fn (d, a) => walk (d, amb, a)) acc ds
		| walk (Style ([], d), amb, acc) = walk (d, amb, acc)
		| walk (Style (cs, d), amb, acc) =
			sgr (0 :: amb) :: walk (d, amb @ cs, sgr cs :: acc)

	fun render d = String.concat (rev (walk (d, [], [])))

	fun output (strm, d) = TextIO.output (strm, render d)
end
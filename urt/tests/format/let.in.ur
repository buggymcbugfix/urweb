(* On one line when written so. *)
val r = let val x = 0 in x + x end

fun f x = let val y = x in y end

(* Broken: the keywords at the level of the construct, the declarations
 * and the body one level deeper, one declaration per line. *)
val s =
	let
		val x = 0
		val y = 1
	in
		x + y
	end

(* One line break anywhere inside breaks the whole. *)
val t = let val x = 0
	in x end

val u = let
	val x = 0 in x end

(* Declarations of every kind, and blank lines between them kept. *)
fun g x =
	let
		val y = x + 1
		fun double n = n * 2

		val rec fact = fn n => if n = 0 then 1 else n * fact (n - 1)
		and other = fn n => n
	in
		double y + fact x
	end

(* A body that spans lines. *)
fun h x =
	let
		val y = x
	in
		if y > 0 then
			y
		else
			0
	end

(* Nested `let`s, in declarations and in the body. *)
fun nested x =
	let
		val y =
			let
				val z = x
			in
				z + 1
			end
	in
		let
			val w = y
		in
			w
		end
	end

(* In a sequence and with a sequence as the body. *)
fun bound s =
	x <- get s;
	let
		val y = x + 1
	in
		set s y;
		return y
	end

(* As an argument, in parentheses. *)
val applied = f (let val x = 1 in x end) 2

val applied' =
	f
		(
			let
				val x = 1
			in
				x
			end
		)
		2

(* Declarations with their bodies below. *)
val v =
	let
		val x =
			someFunction someArgument
		fun k a =
			a + 1
	in
		k x
	end

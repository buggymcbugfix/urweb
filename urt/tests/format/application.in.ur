(* An application on one line stays on one line, with one space between
 * the parts. *)
val a = f x y z
val b = f  x   y
val c = f (g (h x))

(* Broken by the author: the single-word arguments the author kept on the
 * head's line stay there, the rest go one per line one level deeper. *)
val d =
	f x y
		(g z)
		(h w)

val e =
	f
		x
		y
		(g z)

val e' = f x
	y

(* An argument that spans lines forces the break; arguments in
 * parentheses, records and XML literals get their brackets on their own
 * lines. *)
val g1 =
	List.mp
		(fn x => x + 1)
		xs

val g2 =
	List.foldl
		(
			fn x acc =>
				acc + x
		)
		0
		xs

val g3 =
	render
		ctx
		{
			Title = "t",
			Body = body
		}

val g4 =
	render ctx
		<xml>
			<p>text</p>
		</xml>

(* Nested applications, each broken on its own. *)
val h1 =
	outer
		(
			inner
				a
				b
		)
		c

val h2 = outer (inner a b) (inner c d)

(* Explicit type arguments, implicit arguments, `!` and `@`. *)
val i1 = @foldR [fn _ => int] [fn _ => int] (fn [nm ::_] [t ::_] [r ::_] [[nm] ~ r] x acc => acc + x) 0 fl r
val i2 = f [int] [string] x
val i3 = f ! x
val i4 =
	@foldR
		[fn _ => int]
		[fn _ => int]
		(fn [nm ::_] [t ::_] [r ::_] [[nm] ~ r] x acc => acc + x)
		0
		fl
		r

(* A `fn` argument with a multi-line body, the last argument. *)
val j =
	List.app
		(
			fn x =>
				debug x;
				debug x
		)
		xs

(* Applications as operands and in conditions. *)
val k = f x + g y
val k' = if f x then g y else h z

(* Sections through operators and monadic application. *)
val l = f <| g x
val l' = x |> f |> g

(* Long applications stay on one line: there is no width limit. *)
val m = someFunction someArgument anotherArgument yetAnotherArgument andOneMore andTheLastOne

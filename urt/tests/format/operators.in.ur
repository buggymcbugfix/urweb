(* Arithmetic, comparison and boolean operators: one space around each,
 * on one line. *)
val arith = 1+2*3-4/5%6
val cmp = 1<2 && 2<=3 && 3>2 && 3>=2 && 1=1 && 1<>2
val bool = (True && False) || not (True || False)
val neg = -5 + 2
val strings = "a" ^ "b" ^ "c"

(* A chain broken by the author: the operators lead their operands, one
 * level deeper than the first operand. *)
val url =
	Url.absolute "/img/"
	^ replaceSpace r.Style
	^ "/"
	^ replaceSpace r.Fabric
	^ ".jpg"

val url' =
	Url.absolute "/img/" ^ replaceSpace r.Style
		^ "/" ^ replaceSpace r.Fabric
		^ ".jpg"

(* Records: `++`, `--`, `---`. *)
val joined = {A = 1} ++ {B = 2} ++ {C = 3}
val without = r -- #A
val without' = r --- [A = _, B = _]

val joined' =
	{A = 1}
	++ {B = 2}
	++ {C = 3}

(* An operand that spans lines goes below its operator, one level deeper. *)
val joined'' =
	r --- [A = _, B = _]
	++
		{
			A = 1,
			B = 2
		}

(* `::` with the operator on its own line and the operands one deeper. *)
val list = 1 :: 2 :: 3 :: []

val photos =
	(
			bless (Photo.url Photo.Main r)
		::
			bless (Photo.url (Photo.Detail 1) r)
		::
			[]
	)

val pairs =
	(Some a, Some b)
	:: (c, d)
	:: []

(* Application operators and composition. *)
val piped = xs |> List.sort (fn a b => a > b) |> List.mp show
val piped' =
	List.sort (fn a b => a > b) xs
	|> List.groupBy (fn a b => a = b)
	|> List.mp List.length
val applied = show <| 1 + 2
val composed = f >>> g >>> h
val composed' = f <<< g

(* Backtick infix, and mixed chains, which keep their nesting. *)
val infix = 3 `Basis.plus` 4
val mixed = 1 + 2 * 3 + 4
val mixed' =
	a && b
	|| c && d
val mixed'' =
	(a && b)
	|| (c && d)

(* Applications: the head with single-word arguments on its line, the
 * rest one per line one level deeper. *)
val a1 = f x y z
val a2 = f (g x) (h y)
val a3 =
	f
		(g x)
		(h y)
val a4 =
	f x y
		(g z)
		{A = 1}
val a5 =
	f
		x
		y

(* Every kind of argument. *)
val args = f 1 "s" #"c" 1.5 True () {} {A = 1} (1, 2) [] r.Field (fn x => x) <xml/> [#Name] [int] !

(* Arguments with type applications and implicit arguments. *)
val explicit = @foldR [fn _ => int] [fn _ => int] (fn [nm ::_] [t ::_] [r ::_] [[nm] ~ r] x acc => x + acc) 0 fl r
val implicit = f [a] [b] x

(* Field projection and labels. *)
val fields = r.A.B.C + r.D
val label = f [#Name] r
val record = ({Name = "n", Age = 1}).Name

(* Type ascription. *)
val ascribed = (1 : int)
val ascribed' = f (x : int) (y : string)

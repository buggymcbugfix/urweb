(* On one line: the braces hugging, one space after each comma. *)
val short = {A = 1, B = "two"}
val short' = { A = 1 , B = "two" }
val unit = {}
val tuple = (1, "two", (3, 4))
val tuple' = ( 1 , 2 )

(* Broken: the braces on their own lines, one field per line one level
 * deeper, the comma after the field, however the author put them. *)
val long =
	{
		First = 1,
		Second = "two",
		Third = 3.0
	}

val leading =
	{ First = 1
	, Second = "two"
	, Third = 3.0
	}

val hugging = {
	First = 1,
	Second = "two"
}

(* Nested records and tuples. *)
val nested =
	{
		Selection = r --- [X = _, Y = _],
		Out = {Xs = xs, Ys = ys},
		Pair = (1, {A = 2})
	}

val nested' =
	{
		Out =
			{
				Xs = xs,
				Ys = ys
			},
		Pair =
			(
				1,
				{A = 2}
			)
	}

(* A field's value on its own line. *)
val below =
	{
		Long =
			someFunction someArgument anotherArgument,
		Short = 1
	}

(* Fields whose values span lines. *)
val bodies =
	{
		Body =
			<xml>
				<p>text</p>
			</xml>,
		Handler =
			fn x =>
				debug x;
				return (),
		Choice =
			if flag then
				1
			else
				2
	}

(* Alignment of `=`: kept when the author aligned any field, at the width
 * of the widest name. *)
val aligned =
	{
		Email         = user.Email,
		PaymentMethod = method,
		Town = town
	}

(* One field's name touches its `=`: single spaces everywhere. *)
val touching =
	{
		Email= x,
		PaymentMethod   = y
	}

(* Single spaces stay single. *)
val plain =
	{
		Email = x,
		PaymentMethod = y
	}

(* On one line, never aligned. *)
val flat = {Email  = x, PaymentMethod = y}

(* Aligned, with a value on its own line padded like the others. *)
val alignedBelow =
	{
		A    = 1,
		Bbbb =
			f x
	}

(* Records as arguments and in sequences. *)
val applied = f {A = 1, B = 2} x
val applied' =
	f
		{
			A = 1,
			B = 2
		}
		x

fun stored s =
	set s {A = 1, B = 2};
	set
		s
		{
			A = 3,
			B = 4
		}

(* Tuples broken like records. *)
val triple =
	(
		1,
		"two",
		3.0
	)

(* Record patterns and projections stay as written. *)
fun proj {A = a, B = {C = c, ...}, ...} = a + c
val fields = r.A + r.B.C

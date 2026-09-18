(* A sequence on one line, and one statement per line. *)
fun modify [a] (s : source a) (f : a -> a) = x <- get s; set s (f x)

fun modify' [a] (s : source a) (f : a -> a) =
	x <- get s;
	set s (f x)

(* Binds with a type annotation on the pattern, tuple and record patterns. *)
fun typed s =
	(n : int) <- get s;
	(a, b) <- return (n, n + 1);
	{X = x, Y = y} <- return {X = a, Y = b};
	return (x + y)

(* A right-hand side that spans lines goes below `<-`, one level deeper,
 * with the `;` after it. *)
fun below () =
	rows <-
		queryL1
			(
				SELECT T.Id, T.Name
				FROM tbUser AS T
				WHERE T.Active
				ORDER BY T.Name
			);
	names <-
		List.mapM
			(fn r => return r.Name)
			rows;
	return names

(* A right-hand side that the author left on the line stays there while
 * it fits on one. *)
fun onLine () =
	count <- oneRowE1 (SELECT COUNT( * ) AS N FROM tbUser AS T WHERE T.Active);
	return count

(* Parenthesised sequences as right-hand sides and as statements. *)
fun grouped s =
	total <-
		(
			a <- get s;
			b <- get s;
			return (a + b)
		);
	(
		set s 0;
		set s 1
	);
	return total

(* `return` of records, applications and XML. *)
fun returns () =
	r <- return {A = 1, B = "one"};
	return
		<xml>
			<p>{[r.A]}</p>
		</xml>

(* A `let` in a sequence, and a sequence in a `let`. *)
fun withLet s =
	x <- get s;
	let
		val y = x + 1
	in
		set s y;
		return y
	end

(* Statements that are applications with several arguments, some spanning
 * lines. *)
fun statements ctx =
	log ctx "start";
	Page.render
		ctx
		{Title = "Users", Body = <xml>none</xml>};
	List.app
		(fn u => log ctx u.Name)
		users;
	log ctx "end"

(* Long chains, with a blank line kept between groups. *)
fun long () =
	a <- one ();
	b <- two a;

	c <- three a b;
	d <- four c;

	return (a, b, c, d)

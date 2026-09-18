(* A literal on one line stays on one line. *)
val empty = <xml/>
val short = <xml><b>bold</b> and <i>italic</i></xml>
fun greet name = <xml>Hello, {[name]}!</xml>

(* The author's lines are kept; each is indented by the tag nesting at
 * its start, a line starting with a closing tag at the level of its
 * opener, whichever line that was on. *)
fun page (title : string) (body : xbody) : transaction page =
	return
		<xml>
			<head><title>{[title]}</title></head>
			<body class="main">
				{body}
				<ul>{List.mapX (fn s => <xml><li>{[s]}</li></xml>) ("a" :: "b" :: [])}</ul>
			</body>
		</xml>

fun g () : transaction page =
	return
		<xml><body>
			<!-- an XML comment inside the literal -->
			{[f 1]}
		</body></xml>

fun h () =
	<xml>
		<head><title>Hi</title></head>
		<body>
			<p>One</p><p>Two
			</p>
			<ul><li>a</li>
				<li>b</li></ul>
		</body>
	</xml>

(* Whitespace between nodes: where there was none there is none, where
 * there was some there is one space; runs inside text become one space;
 * text is never joined or split. *)
fun spacing () =
	<xml>Text with spaces and
		line breaks is kept as written, whitespace collapsed.</xml>

fun adjacent () =
	<xml>
		<span>{[a]}</span>{[b]} <b>c</b><i>d</i> e
		<p>f</p>
		g<br />h <br /> i
	</xml>

(* Attributes: literals, expressions, bare; on the line, or one per line
 * one level deeper with the `>` back at the tag's level.  Self-closing
 * tags end ` />`, or with `/>` on its own line. *)
fun attributes s =
	<xml>
		<div class="main" id={"x"} onclick={fn _ => set s 1}>text</div>
		<input type="checkbox" checked disabled />
		<br /><hr /><img src="x.png" />
		<div
			class="main"
			id={"x"}
		>
			text
		</div>
		<textbox{#Name}
			value={v}
		/>
		<dyn
			signal={
				x <- signal src;
				return <xml>{[x]}</xml>
			}
		/>
	</xml>

(* Holes: `{e}` and `{[e]}`, with expressions that span lines. *)
fun holes ctx =
	<xml>
		<p>{[title ctx]}</p>
		<p>{[
			translate ctx
				{
					De = "Hallo",
					En = "Hello"
				}
		]}</p>
		{
			if flag then
				<xml>yes</xml>
			else
				<xml>no</xml>
		}
		{
			List.mapX
				(fn x => <xml><li>{[x]}</li></xml>)
				xs
		}
	</xml>

(* Tags with type-level and record arguments. *)
fun forms () =
	<xml>
		<form>
			<textbox{#Name} value="" />
			<checkbox{#Ok} />
			<submit action={handle} value="Go" />
		</form>
		<a link={main ()}>home</a>
		<ctextbox source={s} />
		<button value="Click" onclick={fn _ => alert "hi"} />
	</xml>

(* Entities and text that looks like code. *)
val entities = <xml>&lt;not a tag&gt; &amp; &quot;quoted&quot; &#169;</xml>

(* `<pre>` and `<textarea>` are printed exactly as written. *)
fun preformatted () =
	<xml>
		<div>
			<pre>
   preformatted   text
      stays exactly   as it is
</pre>
			<textarea{#Text}>
  raw
    text</textarea>
		</div>
	</xml>

(* An XML literal as an argument, as a record field and in a sequence. *)
fun uses ctx =
	render ctx <xml><p>inline</p></xml>;
	render
		ctx
		<xml>
			<p>below</p>
		</xml>;
	return {Body = <xml>field</xml>, Title = "t"}

(* Comments in and around the literal. *)
fun commented () =
	<xml> (* after the opening tag *)
		<p>a</p> (* after an element *)
		(* on its own line *)
		<p>b</p>
	</xml>

(* Blank lines inside a literal are kept, at most one. *)
fun blanks () =
	<xml>
		<p>a</p>

		<p>b</p>
	</xml>

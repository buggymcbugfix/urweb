(* Messy whitespace: mixed tabs and spaces, trailing whitespace, too many
 * blank lines, none at the end of the file. *)



val a = 1   
    val b = 2	
	val c =
        3



fun f x =
  	let
	    val y = x
    in
		y
    end



val d = f   1
  

val e = <xml>
  	<p>mixed</p>   
</xml>
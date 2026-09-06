
signature STTYLE =
sig
  type color
  type attr
  type doc

  exception Sttyle of string

  val black : color
  val red : color
  val green : color
  val yellow : color
  val blue : color
  val magenta : color
  val cyan : color
  val white : color
  val default : color

  val bright : color -> color
  val color256 : int -> color
  val rgb : int * int * int -> color

  val fg : color -> attr
  val bg : color -> attr

  val bold : attr
  val dim : attr
  val italic : attr
  val underline : attr
  val blink : attr
  val reverse : attr
  val hidden : attr
  val strike : attr

  val text : string -> doc
  val nl : doc
  val empty : doc
  val cat : doc list -> doc
  val ++ : doc * doc -> doc
  val sttyle : attr list -> doc -> doc

  val render : doc -> string
  val output : TextIO.outstream * doc -> unit
end

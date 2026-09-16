(* Hexadecimal digits and numbers.  Each conversion comes in two forms: one
returning an option, and an *Error variant with the same argument that raises
an error instead, naming what was wrong.

The examples are equations that hold, written so that a doctest runner, once
there is one, can check them as they stand; the ones on options need
Option.eq in scope. *)

(* The value of a digit, 0-9, a-f or A-F; None for any other character.

  fromDigit #"7" = Some 7
  fromDigit #"b" = Some 11
  fromDigit #"B" = Some 11
  fromDigit #"g" = None
*)
val fromDigit : char -> option int
val fromDigitError : char -> int

(* The digit for a value from 0 to 15, in upper case; None outside that
range.

  toDigit 7 = Some #"7"
  toDigit 11 = Some #"B"
  toDigit 16 = None
  toDigit (-1) = None
*)
val toDigit : int -> option char
val toDigitError : int -> char

(* The number a string of digits denotes.  None for the empty string, for any
character that is not a digit, and for a number that does not fit in an int,
i.e. above 2^63-1: there is no sign and no prefix here, so "8000000000000000"
is out of range rather than negative.

  parse "ff" = Some 255
  parse "FF" = Some 255
  parse "000001" = Some 1
  parse "" = None
  parse "fg" = None
  parse "0xff" = None
  parse "7fffffffffffffff" = Some 9223372036854775807
  parse "8000000000000000" = None
  parse "10000000000000000" = None
*)
val parse : string -> option int
val parseError : string -> int

(* As parse, after an optional 0x or 0X.

  parseLiteral "0xff" = Some 255
  parseLiteral "0XFF" = Some 255
  parseLiteral "ff" = Some 255
  parseLiteral "0" = Some 0
  parseLiteral "0x" = None
  parseLiteral "x1" = None
*)
val parseLiteral : string -> option int
val parseLiteralError : string -> int

(* The digits of a non-negative number, upper case, no prefix, no leading
zeros.  A negative number is an error.

  show 0 = "0"
  show 255 = "FF"
  show 9223372036854775807 = "7FFFFFFFFFFFFFFF"
  parse (show 48879) = Some 48879
*)
val show : int -> string

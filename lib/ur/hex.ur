(* The value of a digit, -1 for any other character.  The loops below use this
rather than fromDigit so that no option is allocated per character. *)
fun digitValue (ch : char) : int =
    let
        val c = ord ch
    in
        if c >= 48 && c <= 57 then c - 48
        else if c >= 97 && c <= 102 then c - 87
        else if c >= 65 && c <= 70 then c - 55
        else -1
    end

fun fromDigit (ch : char) : option int =
    let
        val d = digitValue ch
    in
        if d < 0 then None else Some d
    end

fun fromDigitError ch =
    case fromDigit ch of
        Some d => d
      | None => error <xml>Hex.fromDigit: not a hexadecimal digit: "{[ch]}"</xml>

fun toDigit (n : int) : option char =
    if n < 0 || n > 15 then None
    else if n < 10 then Some (chr (48 + n))
    else Some (chr (55 + n))

fun toDigitError n =
    case toDigit n of
        Some ch => ch
      | None => error <xml>Hex.toDigit: not a digit value: {[n]}</xml>

(* Digits are taken one at a time from the front with strsub 0 and strsuffix 1,
both constant-time in the runtime, so that the loop is linear; indexing a
string at i costs i, since strings are UTF-8.  A number fits as long as the
accumulator, before it takes another digit, is at most (2^63-1) div 16. *)
fun parse (s : string) : option int =
    let
        fun go s acc =
            if s = "" then Some acc
            else
                let
                    val d = digitValue (strsub s 0)
                in
                    if d < 0 || acc > 576460752303423487 then None
                    else go (strsuffix s 1) (16 * acc + d)
                end
    in
        if s = "" then None else go s 0
    end

fun parseError s =
    case parse s of
        Some n => n
      | None => error <xml>Hex.parse: not a hexadecimal number that fits an int: "{[s]}"</xml>

fun parseLiteral (s : string) : option int =
    if strlenGe s 2 && strsub s 0 = #"0" && (strsub s 1 = #"x" || strsub s 1 = #"X") then
        parse (strsuffix s 2)
    else
        parse s

fun parseLiteralError s =
    case parseLiteral s of
        Some n => n
      | None => error <xml>Hex.parseLiteral: not a hexadecimal literal that fits an int: "{[s]}"</xml>

fun show (n : int) : string =
    let
        fun go n acc =
            if n = 0 then acc
            else go (n / 16) (str1 (toDigitError (n % 16)) ^ acc)
    in
        if n < 0 then error <xml>Hex.show: negative number: {[n]}</xml>
        else if n = 0 then "0"
        else go n ""
    end

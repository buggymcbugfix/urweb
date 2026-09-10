structure Operators =
 struct
  val addMulSub = Basis.minus (Basis.plus 1 (Basis.times 2 3)) 4
   val grouped = Basis.times (Basis.plus 1 2) (Basis.minus 3 4)
   val subLeft = Basis.minus (Basis.minus 1 2) 3
   val subRight = Basis.minus 1 (Basis.minus 2 3)
   val compared = Basis.lt (Basis.plus 1 1) (Basis.times 2 2)
   
   val andOr =
    case True of
     Basis.True => Basis.True | 
      Basis.False =>
       case False of Basis.True => True | Basis.False => Basis.False
   
   val negated =
    not (case True of Basis.True => False | Basis.False => Basis.False)
   val concatenated = Basis.strcat "a" (Basis.strcat "b" "c")
   val rec ap : int -> int -> int = fn x : int => fn y : int => Basis.plus x y
   val applyFirst = Basis.plus (ap 1 2) 3
   val applyLast = ap 1 (Basis.plus 2 3)
   val branch = case Basis.lt 1 2 of Basis.True => 3 | Basis.False => 4
   
   val rec
    main : (_ :: Type) -> transaction page =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Top.txt addMulSub))
  end
 export Operators
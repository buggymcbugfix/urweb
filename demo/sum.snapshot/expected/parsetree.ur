structure Sum : sig
                 val main : unit -> transaction page
                 end =
 struct
  val rec
   sum : fs ::: {Unit} -> (folder fs) -> $(mapU int fs) -> (_ :: Type) =
    fn fs ::: {Unit} =>
     fn fl : folder fs =>
      fn x : $(mapU int fs) =>
       foldUR [int] [fn _ => int]
        (fn nm :: Name =>
          fn rest :: {Unit} =>
           [nm = ()] ~ rest => fn n => fn acc => Basis.plus n acc) 0 fl x
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "  ")
               (Basis.join (Top.txt (sum {}))
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (br {}) (Basis.cdata ""))
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "  ")
                       (Basis.join (Top.txt (sum {A = 0, B = 1}))
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (br {}) (Basis.cdata ""))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "  ")
                               (Basis.join
                                 (Top.txt (sum {C = 2, D = 3, E = 4}))
                                 (Basis.cdata "\n")))))))))))))
  end
 export Sum
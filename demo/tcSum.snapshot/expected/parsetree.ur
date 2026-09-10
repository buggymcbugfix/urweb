structure TcSum : sig
                   val main : unit -> transaction page
                   end =
 struct
  val rec
   sum :
    t ::: _ ->
     (num t) -> fs ::: {Unit} -> (folder fs) -> $(mapU t fs) -> (_ :: Type) =
    fn t ::: _ =>
     fn _ : num t =>
      fn fs ::: {Unit} =>
       fn fl : folder fs =>
        fn x : $(mapU t fs) =>
         foldUR [t] [fn _ => t]
          (fn nm :: Name =>
            fn rest :: {Unit} =>
             [nm = ()] ~ rest => fn n => fn acc => Basis.plus n acc) zero fl x
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "  ")
               (Basis.join (Top.txt (sum {A = 0, B = 1}))
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (br {}) (Basis.cdata ""))
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "  ")
                       (Basis.join (Top.txt (sum {C = 2.1, D = 3.2, E = 4.3}))
                         (Basis.cdata "\n")))))))))
  end
 export TcSum
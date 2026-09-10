structure Counter : sig
                     val main : unit -> transaction page
                     end =
 struct
  val rec
   counter : (_ :: Type) -> (_ :: Type) =
    fn n =>
     return
      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
        (Basis.join (Basis.cdata "\n")
          (Basis.join (Basis.cdata "  Current counter: ")
            (Basis.join (Top.txt n)
              (Basis.join
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (br {}) (Basis.cdata ""))
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "  ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {Link = counter (Basis.plus n 1)} (a {})
                        (Basis.cdata "Increment"))
                      (Basis.join
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (br {}) (Basis.cdata ""))
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "  ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {Link = counter (Basis.minus n 1)}
                                (a {}) (Basis.cdata "Decrement"))
                              (Basis.cdata "\n")))))))))))))
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) => case $x of {} => counter 0
  end
 export Counter
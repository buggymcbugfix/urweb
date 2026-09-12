structure Subforms : sig
                      val main : unit -> transaction page
                      end =
 struct
  val rec
   sub : (_ :: Type) -> (_ :: Type) =
    fn r =>
     let
      val rec
       sub' : (_ :: Type) -> (_ :: Type) =
        fn ls =>
         case ls of
          Basis.Nil => Basis.cdata "" | 
           Basis.Cons {1 = r, 2 = ls} =>
            Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "                ")
               (Basis.join
                 (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                   (p {})
                   (Basis.join (Top.txt r.#Num)
                     (Basis.join (Basis.cdata " = ") (Top.txt r.#Text))))
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "                ")
                     (Basis.join (sub' ls)
                       (Basis.join (Basis.cdata "\n")
                         (Basis.cdata "              ")))))))
      in
      return
       (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
         (Basis.join (Basis.cdata "\n")
           (Basis.join (Basis.cdata "          ")
             (Basis.join (sub' r.#Lines)
               (Basis.join (Basis.cdata "\n") (Basis.cdata "        "))))))
      end
   
   val rec
    subfrms : (_ :: Type) -> (_ :: Type) =
     fn n =>
      case Basis.le n 0 of
       Basis.True => Basis.cdata "" | 
        Basis.False =>
         Basis.join (Basis.cdata "\n")
          (Basis.join (Basis.cdata "          ")
            (Basis.join
              (Basis.entry
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "            ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {Value = show n} (hidden [#Num] {}) (Basis.cdata ""))
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "            ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (p {})
                              (Basis.join (Top.txt n)
                                (Basis.join (Basis.cdata ": ")
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {}
                                    (textbox [#Text] {}) (Basis.cdata "")))))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.cdata "          ")))))))))
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "          ")
                  (Basis.join (subfrms (Basis.minus n 1))
                    (Basis.join (Basis.cdata "\n") (Basis.cdata "        ")))))))
   
   val rec
    form : (_ :: Type) -> (_ :: Type) =
     fn n =>
      return
       (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
         (Basis.join (Basis.cdata "\n")
           (Basis.join (Basis.cdata "  ")
             (Basis.join
               (Basis.form Basis.None Basis.None
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "    ")
                     (Basis.join
                       (subforms [#Lines]
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "      ")
                             (Basis.join (subfrms n)
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.cdata "    "))))))
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "    ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {Action = sub} (submit {})
                               (Basis.cdata [(_ :: _)] [[]] ""))
                             (Basis.join (Basis.cdata "\n") (Basis.cdata "  ")))))))))
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "  ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {Link = form (Basis.plus n 1)} (a {})
                         (Basis.cdata "One more blank"))
                       (Basis.join
                         (Basis.tag Basis.null Basis.None Basis.noStyle
                           Basis.None {} (br {}) (Basis.cdata ""))
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "  ")
                             (Basis.join
                               (case Basis.gt n 0 of
                                 Basis.True =>
                                  Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {Link = form (Basis.minus n 1)}
                                   (a {}) (Basis.cdata "One fewer blank") | 
                                  Basis.False => Basis.cdata "")
                               (Basis.cdata "\n")))))))))))))
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) => case $x of {} => form 1
  end
 export Subforms
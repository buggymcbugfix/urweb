structure Metaform :
 sig
  structure Make :
   functor (M
    :sig
      con fs :: {Unit}
       val fl : folder fs
       val names : $(mapU string fs)
      end) : sig
              val main : unit -> transaction page
              end
  end =
 struct
  structure Make =
   functor (M
    :sig
      con fs :: {Unit}
       val fl : folder fs
       val names : $(mapU string fs)
      end) =>
    struct
     val rec
      handler : (_ :: Type) -> (_ :: Type) =
       fn values =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "      ")
               (Basis.join
                 (mapUX2 [string] [string] [body]
                   (fn nm :: Name =>
                     fn rest :: _ =>
                      [nm = ()] ~ rest =>
                       fn name =>
                        fn value =>
                         Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "          ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (p {})
                                (Basis.join (Basis.cdata " ")
                                  (Basis.join (Top.txt name)
                                    (Basis.join (Basis.cdata " = ")
                                      (Top.txt value)))))
                              (Basis.join (Basis.cdata "\n")
                                (Basis.cdata "        "))))) M.fl M.names
                   values) (Basis.join (Basis.cdata "\n") (Basis.cdata "    "))))))
      
      val rec
       main : (_ :: Type) -> (_ :: Type) =
        fn $x : (_ :: Type) =>
         case $x of
          {} =>
           return
            (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
              (body {})
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "      ")
                  (Basis.join
                    (Basis.form Basis.None Basis.None
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "        ")
                          (Basis.join
                            (foldUR [string]
                              [fn cols => xml form [] (mapU string cols)]
                              (fn nm :: Name =>
                                fn rest :: _ =>
                                 [nm = ()] ~ rest =>
                                  fn name =>
                                   fn acc =>
                                    Basis.join (Basis.cdata "\n")
                                     (Basis.join (Basis.cdata "            ")
                                       (Basis.join
                                         (Basis.tag Basis.null Basis.None
                                           Basis.noStyle Basis.None {} (p {})
                                           (Basis.join (Basis.cdata " ")
                                             (Basis.join (Top.txt name)
                                               (Basis.join (Basis.cdata ": ")
                                                 (Basis.tag Basis.null
                                                   Basis.None Basis.noStyle
                                                   Basis.None {}
                                                   (textbox [nm] {})
                                                   (Basis.cdata ""))))))
                                         (Basis.join (Basis.cdata "\n")
                                           (Basis.join
                                             (Basis.cdata "            ")
                                             (Basis.join (useMore acc)
                                               (Basis.join (Basis.cdata "\n")
                                                 (Basis.cdata "          "))))))))
                              (Basis.cdata "") M.fl M.names)
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "        ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {Action = handler}
                                    (submit {})
                                    (Basis.cdata [(_ :: _)] [[]] ""))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.cdata "      ")))))))))
                    (Basis.join (Basis.cdata "\n") (Basis.cdata "    "))))))
     end
  end
 
 structure Metaform1 : sig
                        val main : unit -> transaction page
                        end =
  struct
   structure anon =
    Metaform.Make(struct
                   val names = {A = "Tic", B = "Tac", C = "Toe"}
                   end)
    open anon
   end
 export Metaform1
structure Nested : sig
                    val main : unit -> transaction page
                    end =
 struct
  val rec
   pageA : (_ :: Type) -> (_ :: Type) =
    fn $x : (_ :: Type) =>
     case $x of
      {} =>
       return
        (Basis.join (Basis.cdata "\n")
          (Basis.join (Basis.cdata "  ")
            (Basis.join
              (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                (head {})
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "    ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {} (title {}) (Basis.cdata "A"))
                      (Basis.join (Basis.cdata "\n") (Basis.cdata "  "))))))
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "  ")
                  (Basis.join
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (body {})
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "    ")
                          (Basis.join
                            (Basis.form Basis.None Basis.None
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "      ")
                                  (Basis.join
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None {} (tabl {})
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join (Basis.cdata "        ")
                                          (Basis.join
                                            (Basis.tag Basis.null Basis.None
                                              Basis.noStyle Basis.None {}
                                              (tr {})
                                              (Basis.join (Basis.cdata "\n")
                                                (Basis.join
                                                  (Basis.cdata "          ")
                                                  (Basis.join
                                                    (Basis.tag Basis.null
                                                      Basis.None Basis.noStyle
                                                      Basis.None {} (td {})
                                                      (Basis.cdata "Forename:"))
                                                    (Basis.join
                                                      (Basis.cdata "\n")
                                                      (Basis.join
                                                        (Basis.cdata
                                                          "          ")
                                                        (Basis.join
                                                          (Basis.tag Basis.null
                                                            Basis.None
                                                            Basis.noStyle
                                                            Basis.None {}
                                                            (td {})
                                                            (Basis.tag
                                                              Basis.null
                                                              Basis.None
                                                              Basis.noStyle
                                                              Basis.None {}
                                                              (textbox
                                                                [#Forename] {})
                                                              (Basis.cdata "")))
                                                          (Basis.join
                                                            (Basis.cdata "\n")
                                                            (Basis.cdata
                                                              "        ")))))))))
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata "        ")
                                                (Basis.join
                                                  (Basis.tag Basis.null
                                                    Basis.None Basis.noStyle
                                                    Basis.None {} (tr {})
                                                    (Basis.join
                                                      (Basis.cdata "\n")
                                                      (Basis.join
                                                        (Basis.cdata
                                                          "          ")
                                                        (Basis.join
                                                          (Basis.tag Basis.null
                                                            Basis.None
                                                            Basis.noStyle
                                                            Basis.None {}
                                                            (td {})
                                                            (Basis.cdata
                                                              "Enter a Surname?"))
                                                          (Basis.join
                                                            (Basis.cdata "\n")
                                                            (Basis.join
                                                              (Basis.cdata
                                                                "          ")
                                                              (Basis.join
                                                                (Basis.tag
                                                                  Basis.null
                                                                  Basis.None
                                                                  Basis.noStyle
                                                                  Basis.None {}
                                                                  (td {})
                                                                  (Basis.tag
                                                                    Basis.null
                                                                    Basis.None
                                                                    Basis.
                                                                     noStyle
                                                                    Basis.None
                                                                    {}
                                                                    (checkbox
                                                                      [#EnterSurname]
                                                                      {})
                                                                    (Basis.
                                                                      cdata "")))
                                                                (Basis.join
                                                                  (Basis.cdata
                                                                    "\n")
                                                                  (Basis.cdata
                                                                    "        ")))))))))
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.cdata "      ")))))))))
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join (Basis.cdata "      ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None
                                            {Action = fromA} (submit {})
                                            (Basis.cdata [(_ :: _)] [[]] ""))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata "    ")))))))))
                            (Basis.join (Basis.cdata "\n") (Basis.cdata "  "))))))
                    (Basis.cdata "\n")))))))
                                             and 
    fromA : (_ :: Type) -> (_ :: Type) =
     fn r =>
      let
       val forename = r.#Forename
        
        val rec
         pageB : (_ :: Type) -> (_ :: Type) =
          fn $x : (_ :: Type) =>
           case $x of
            {} =>
             return
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "          ")
                  (Basis.join
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (head {})
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "            ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (title {}) (Basis.cdata "B"))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.cdata "          "))))))
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "          ")
                        (Basis.join
                          (Basis.tag Basis.null Basis.None Basis.noStyle
                            Basis.None {} (body {})
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "            ")
                                (Basis.join
                                  (Basis.form Basis.None Basis.None
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join
                                        (Basis.cdata "              Surname:")
                                        (Basis.join (Basis.cdata "\n")
                                          (Basis.join
                                            (Basis.cdata "              ")
                                            (Basis.join
                                              (Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None {}
                                                (textbox [#Surname] {})
                                                (Basis.cdata ""))
                                              (Basis.join (Basis.cdata "\n")
                                                (Basis.join
                                                  (Basis.cdata "              ")
                                                  (Basis.join
                                                    (Basis.tag Basis.null
                                                      Basis.None Basis.noStyle
                                                      Basis.None
                                                      {Action = pageC'}
                                                      (submit {})
                                                      (Basis.cdata [(_ :: _)]
                                                        [[]] ""))
                                                    (Basis.join
                                                      (Basis.cdata "\n")
                                                      (Basis.cdata
                                                        "            ")))))))))))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.join (Basis.cdata "            ")
                                      (Basis.join
                                        (Basis.tag Basis.null Basis.None
                                          Basis.noStyle Basis.None
                                          {Link = pageA {}} (a {})
                                          (Basis.cdata "Previous"))
                                        (Basis.join (Basis.cdata "\n")
                                          (Basis.cdata "          ")))))))))
                          (Basis.join (Basis.cdata "\n")
                            (Basis.cdata "        "))))))))
                                                            and 
          pageC' : (_ :: Type) -> (_ :: Type) = fn r => pageC (Some r.#Surname)
                                                                               and
                                                                               
          pageC : (_ :: Type) -> (_ :: Type) =
           fn surname =>
            return
             (Basis.join (Basis.cdata "\n")
               (Basis.join (Basis.cdata "          ")
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (head {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "            ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (title {}) (Basis.cdata "C"))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.cdata "          "))))))
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "          ")
                       (Basis.join
                         (Basis.tag Basis.null Basis.None Basis.noStyle
                           Basis.None {} (body {})
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "            ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (p {})
                                   (Basis.join (Basis.cdata "Hello ")
                                     (Basis.join (Top.txt forename)
                                       (case surname of
                                         None => Basis.cdata "" | 
                                          Some s =>
                                           Basis.join (Basis.cdata " ")
                                            (Top.txt s)))))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "            ")
                                     (Basis.join
                                       (case surname of
                                         None =>
                                          Basis.tag Basis.null Basis.None
                                           Basis.noStyle Basis.None
                                           {Link = pageA {}} (a {})
                                           (Basis.cdata "Previous") | 
                                          Some _ =>
                                           Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None
                                            {Link = pageB {}} (a {})
                                            (Basis.cdata "Previous"))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.cdata "          ")))))))))
                         (Basis.join (Basis.cdata "\n")
                           (Basis.cdata "        "))))))))
       in
       case r.#EnterSurname of
        Basis.True => pageB {} | Basis.False => pageC None
       end
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) => case $x of {} => pageA {}
  end
 export Nested
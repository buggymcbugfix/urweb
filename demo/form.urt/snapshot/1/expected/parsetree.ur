structure Form : sig
                  val main : unit -> transaction page
                  end =
 struct
  val rec
   handler : (_ :: Type) -> (_ :: Type) =
    fn r =>
     return
      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
        (Basis.join (Basis.cdata "\n")
          (Basis.join (Basis.cdata "  ")
            (Basis.join
              (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                (tabl {})
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "    ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {} (tr {})
                        (Basis.join (Basis.cdata " ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (th {}) (Basis.cdata "A:"))
                            (Basis.join (Basis.cdata " ")
                              (Basis.join
                                (Basis.tag Basis.null Basis.None Basis.noStyle
                                  Basis.None {} (td {}) (Top.txt r.#A))
                                (Basis.cdata " "))))))
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "    ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (tr {})
                              (Basis.join (Basis.cdata " ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (th {})
                                    (Basis.cdata "B:"))
                                  (Basis.join (Basis.cdata " ")
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None {} (td {})
                                        (Top.txt r.#B)) (Basis.cdata " "))))))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "    ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (tr {})
                                    (Basis.join (Basis.cdata " ")
                                      (Basis.join
                                        (Basis.tag Basis.null Basis.None
                                          Basis.noStyle Basis.None {} (th {})
                                          (Basis.cdata "C:"))
                                        (Basis.join (Basis.cdata " ")
                                          (Basis.join
                                            (Basis.tag Basis.null Basis.None
                                              Basis.noStyle Basis.None {}
                                              (td {}) (Top.txt r.#C))
                                            (Basis.cdata " "))))))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.cdata "  "))))))))))))
              (Basis.cdata "\n")))))
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "  ")
               (Basis.join
                 (Basis.form Basis.None Basis.None
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "    ")
                       (Basis.join
                         (Basis.tag Basis.null Basis.None Basis.noStyle
                           Basis.None {} (tabl {})
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "      ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (tr {})
                                   (Basis.join (Basis.cdata " ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (th {})
                                         (Basis.cdata "A:"))
                                       (Basis.join (Basis.cdata " ")
                                         (Basis.join
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None {}
                                             (td {})
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (textbox [#A] {})
                                               (Basis.cdata "")))
                                           (Basis.cdata " "))))))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "      ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (tr {})
                                         (Basis.join (Basis.cdata " ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (th {}) (Basis.cdata "B:"))
                                             (Basis.join (Basis.cdata " ")
                                               (Basis.join
                                                 (Basis.tag Basis.null
                                                   Basis.None Basis.noStyle
                                                   Basis.None {} (td {})
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None {}
                                                     (textbox [#B] {})
                                                     (Basis.cdata "")))
                                                 (Basis.cdata " "))))))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join (Basis.cdata "      ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (tr {})
                                               (Basis.join (Basis.cdata " ")
                                                 (Basis.join
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None {} (th {})
                                                     (Basis.cdata "C:"))
                                                   (Basis.join
                                                     (Basis.cdata " ")
                                                     (Basis.join
                                                       (Basis.tag Basis.null
                                                         Basis.None
                                                         Basis.noStyle
                                                         Basis.None {} (td {})
                                                         (Basis.tag Basis.null
                                                           Basis.None
                                                           Basis.noStyle
                                                           Basis.None {}
                                                           (checkbox [#C] {})
                                                           (Basis.cdata "")))
                                                       (Basis.cdata " "))))))
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.join
                                                 (Basis.cdata "      ")
                                                 (Basis.join
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None {} (tr {})
                                                     (Basis.join
                                                       (Basis.cdata " ")
                                                       (Basis.join
                                                         (Basis.tag Basis.null
                                                           Basis.None
                                                           Basis.noStyle
                                                           Basis.None {}
                                                           (th {})
                                                           (Basis.cdata ""))
                                                         (Basis.join
                                                           (Basis.cdata " ")
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
                                                                 Basis.noStyle
                                                                 Basis.None
                                                                 {Action =
                                                                   handler}
                                                                 (submit {})
                                                                 (Basis.cdata
                                                                   [(_ :: _)]
                                                                   [[]] "")))
                                                             (Basis.cdata " "))))))
                                                   (Basis.join
                                                     (Basis.cdata "\n")
                                                     (Basis.cdata "    ")))))))))))))))
                         (Basis.join (Basis.cdata "\n") (Basis.cdata "  "))))))
                 (Basis.cdata "\n")))))
  end
 export Form
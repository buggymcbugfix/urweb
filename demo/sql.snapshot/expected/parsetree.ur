database dbname=test
 
 structure Sql : sig
                  val main : unit -> transaction page
                  end =
  struct
   table t : [#A = int, #B = float, #C = string, #D = bool] keys
    Basis.primary_key [#A] [[]] ! ! {A = _} constraints Basis.no_constraint
    
    val rec
     list : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind
          (queryX
            (Basis.sql_query
              {Rows =
                Basis.sql_query1 [[]]
                 {Distinct = Basis.False, From = Basis.sql_from_table [#T] t, 
                   Where = Basis.sql_inject Basis.True, 
                   GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                   Having = Basis.sql_inject Basis.True, 
                   SelectFields = Basis.sql_subset [[#T = ((_ :: {Type}), [])]],
                                                                               
                   SelectExps = {}}, 
                OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
            (fn row =>
              Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (tr {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "              ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (td {}) (Top.txt row.#T.#A))
                     (Basis.join (Basis.cdata " ")
                       (Basis.join
                         (Basis.tag Basis.null Basis.None Basis.noStyle
                           Basis.None {} (td {}) (Top.txt row.#T.#B))
                         (Basis.join (Basis.cdata " ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (td {}) (Top.txt row.#T.#C))
                             (Basis.join (Basis.cdata " ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (td {}) (Top.txt row.#T.#D))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "              ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (td {})
                                         (Basis.form Basis.None Basis.None
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None
                                             {Action = delete row.#T.#A, 
                                               Value = "Delete"} (submit {})
                                             (Basis.cdata [(_ :: _)] [[]] ""))))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.cdata "            "))))))))))))))))
          (fn rows =>
            return
             (Basis.join (Basis.cdata "\n")
               (Basis.join (Basis.cdata "      ")
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                     {Border = 1} (tabl {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "        ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (tr {})
                             (Basis.join (Basis.cdata " ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (th {}) (Basis.cdata "A"))
                                 (Basis.join (Basis.cdata " ")
                                   (Basis.join
                                     (Basis.tag Basis.null Basis.None
                                       Basis.noStyle Basis.None {} (th {})
                                       (Basis.cdata "B"))
                                     (Basis.join (Basis.cdata " ")
                                       (Basis.join
                                         (Basis.tag Basis.null Basis.None
                                           Basis.noStyle Basis.None {} (th {})
                                           (Basis.cdata "C"))
                                         (Basis.join (Basis.cdata " ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (th {}) (Basis.cdata "D"))
                                             (Basis.cdata " "))))))))))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "        ")
                               (Basis.join rows
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.cdata "      ")))))))))
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "      ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (br {}) (Basis.cdata ""))
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (hr {}) (Basis.cdata ""))
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {} (br {}) (Basis.cdata ""))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "      ")
                                     (Basis.join
                                       (Basis.form Basis.None Basis.None
                                         (Basis.join (Basis.cdata "\n")
                                           (Basis.join (Basis.cdata "        ")
                                             (Basis.join
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None {}
                                                 (tabl {})
                                                 (Basis.join (Basis.cdata "\n")
                                                   (Basis.join
                                                     (Basis.cdata "          ")
                                                     (Basis.join
                                                       (Basis.tag Basis.null
                                                         Basis.None
                                                         Basis.noStyle
                                                         Basis.None {} (tr {})
                                                         (Basis.join
                                                           (Basis.cdata " ")
                                                           (Basis.join
                                                             (Basis.tag
                                                               Basis.null
                                                               Basis.None
                                                               Basis.noStyle
                                                               Basis.None {}
                                                               (th {})
                                                               (Basis.cdata
                                                                 "A:"))
                                                             (Basis.join
                                                               (Basis.cdata " ")
                                                               (Basis.join
                                                                 (Basis.tag
                                                                   Basis.null
                                                                   Basis.None
                                                                   Basis.
                                                                    noStyle
                                                                   Basis.None
                                                                   {} (td {})
                                                                   (Basis.tag
                                                                     Basis.null
                                                                     Basis.None
                                                                     Basis.
                                                                      noStyle
                                                                     Basis.None
                                                                     {}
                                                                     (textbox
                                                                       [#A] {})
                                                                     (Basis.
                                                                       cdata "")))
                                                                 (Basis.cdata
                                                                   " "))))))
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
                                                               (tr {})
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   " ")
                                                                 (Basis.join
                                                                   (Basis.tag
                                                                     Basis.null
                                                                     Basis.None
                                                                     Basis.
                                                                      noStyle
                                                                     Basis.None
                                                                     {} (th {})
                                                                     (Basis.
                                                                       cdata
                                                                       "B:"))
                                                                   (Basis.join
                                                                     (Basis.
                                                                       cdata
                                                                       " ")
                                                                     (Basis.
                                                                       join
                                                                       (Basis.
                                                                         tag
                                                                         Basis.
                                                                          null
                                                                         Basis.
                                                                          None
                                                                         Basis.
                                                                          noStyle
                                                                         Basis.
                                                                          None
                                                                         {}
                                                                         (td {})
                                                                         (Basis.
                                                                           tag
                                                                           Basis.
                                                                            null
                                                                           Basis.
                                                                            None
                                                                           Basis.
                                                                            noStyle
                                                                           Basis.
                                                                            None
                                                                           {}
                                                                           (textbox
                                                                             [#B]
                                                                             {})
                                                                           (Basis.
                                                                             cdata
                                                                             "")))
                                                                       (Basis.
                                                                         cdata
                                                                         " "))))))
                                                             (Basis.join
                                                               (Basis.cdata
                                                                 "\n")
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   "          ")
                                                                 (Basis.join
                                                                   (Basis.tag
                                                                     Basis.null
                                                                     Basis.None
                                                                     Basis.
                                                                      noStyle
                                                                     Basis.None
                                                                     {} (tr {})
                                                                     (Basis.
                                                                       join
                                                                       (Basis.
                                                                         cdata
                                                                         " ")
                                                                       (Basis.
                                                                         join
                                                                         (Basis.
                                                                           tag
                                                                           Basis.
                                                                            null
                                                                           Basis.
                                                                            None
                                                                           Basis.
                                                                            noStyle
                                                                           Basis.
                                                                            None
                                                                           {}
                                                                           (th
                                                                             {})
                                                                           (Basis.
                                                                             cdata
                                                                             "C:"))
                                                                         (Basis.
                                                                           join
                                                                           (Basis.
                                                                             cdata
                                                                             " ")
                                                                           (Basis.
                                                                             join
                                                                             (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (td
                                                                               {})
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (textbox
                                                                               [#C]
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               "")))
                                                                             (Basis.
                                                                               cdata
                                                                               " "))))))
                                                                   (Basis.join
                                                                     (Basis.
                                                                       cdata
                                                                       "\n")
                                                                     (Basis.
                                                                       join
                                                                       (Basis.
                                                                         cdata
                                                                         "          ")
                                                                       (Basis.
                                                                         join
                                                                         (Basis.
                                                                           tag
                                                                           Basis.
                                                                            null
                                                                           Basis.
                                                                            None
                                                                           Basis.
                                                                            noStyle
                                                                           Basis.
                                                                            None
                                                                           {}
                                                                           (tr
                                                                             {})
                                                                           (Basis.
                                                                             join
                                                                             (Basis.
                                                                               cdata
                                                                               " ")
                                                                             (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (th
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               "D:"))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               " ")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (td
                                                                               {})
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (checkbox
                                                                               [#D]
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               "")))
                                                                               (Basis.
                                                                               cdata
                                                                               " "))))))
                                                                         (Basis.
                                                                           join
                                                                           (Basis.
                                                                             cdata
                                                                             "\n")
                                                                           (Basis.
                                                                             join
                                                                             (Basis.
                                                                               cdata
                                                                               "          ")
                                                                             (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (tr
                                                                               {})
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               " ")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (th
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               ""))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               " ")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (td
                                                                               {})
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {Action
                                                                               =
                                                                               add
                                                                               ,
                                                                               
                                                                               Value
                                                                               =
                                                                               "Add Row"
                                                                               }
                                                                               (submit
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               [(_
                                                                               ::
                                                                               _)]
                                                                               [[]]
                                                                               "")))
                                                                               (Basis.
                                                                               cdata
                                                                               " "))))))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "\n")
                                                                               (Basis.
                                                                               cdata
                                                                               "        "))))))))))))))))))
                                               (Basis.join (Basis.cdata "\n")
                                                 (Basis.cdata "      "))))))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.cdata "    "))))))))))))))))
                                                                             and 
      add : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (dml
           (Basis.insert t
             {A = Basis.sql_inject (readError r.#A), 
               B = Basis.sql_inject (readError r.#B), 
               C = Basis.sql_inject r.#C, D = Basis.sql_inject r.#D}))
         (fn _ : {} =>
           Basis.bind (list {})
            (fn xml =>
              return
               (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                 (body {})
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "      ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {} (p {}) (Basis.cdata "Row added."))
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "      ")
                             (Basis.join xml
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.cdata "    "))))))))))))
                                                                 and 
      delete : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
       fn a =>
        fn $x : (_ :: Type) =>
         case $x of
          {} =>
           Basis.bind
            (dml
              (Basis.delete t
                (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#A])
                  (Basis.sql_inject a))))
            (fn _ : {} =>
              Basis.bind (list {})
               (fn xml =>
                 return
                  (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                    (body {})
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "      ")
                        (Basis.join
                          (Basis.tag Basis.null Basis.None Basis.noStyle
                            Basis.None {} (p {}) (Basis.cdata "Row deleted."))
                          (Basis.join (Basis.cdata "\n")
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "      ")
                                (Basis.join xml
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.cdata "    "))))))))))))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (list {})
          (fn xml =>
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "      ")
                   (Basis.join xml
                     (Basis.join (Basis.cdata "\n") (Basis.cdata "    ")))))))
   end
 export Sql
database dbname=test
 
 structure Constraints : sig
                          val main : unit -> transaction page
                          end =
  struct
   table t : [#Id = int, #Nam = string, #Parent = option int] keys
    Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints
    Basis.join_constraints
     (Basis.one_constraint [#Nam] (Basis.unique [#Nam] [[]]))
     (Basis.join_constraints
       (Basis.one_constraint [#Id]
         (Basis.check
           (Basis.sql_binary Basis.sql_ge (Basis.sql_exp [#Id])
             (Basis.sql_inject 0))))
       (Basis.one_constraint [#Parent]
         (Basis.foreign_key (Basis.mat_cons [#Parent] [#Id] Basis.mat_nil) t
           {OnDelete = Basis.no_action, OnUpdate = Basis.no_action})))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
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
            (fn r =>
              Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (tr {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "              ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (td {}) (Top.txt r.#T.#Id))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "              ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (td {}) (Top.txt r.#T.#Nam))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "              ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (td {})
                                   (case r.#T.#Parent of
                                     None => Basis.cdata "NULL" | 
                                      Some id => Top.txt id))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.cdata "            ")))))))))))))
          (fn list =>
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "      ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (tabl {})
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "        ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (tr {})
                               (Basis.join (Basis.cdata " ")
                                 (Basis.join
                                   (Basis.tag Basis.null Basis.None
                                     Basis.noStyle Basis.None {} (th {})
                                     (Basis.cdata "Id"))
                                   (Basis.join (Basis.cdata " ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (th {})
                                         (Basis.cdata "Name"))
                                       (Basis.join (Basis.cdata " ")
                                         (Basis.join
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None {}
                                             (th {}) (Basis.cdata "Parent"))
                                           (Basis.cdata " "))))))))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "        ")
                                 (Basis.join list
                                   (Basis.join (Basis.cdata "\n")
                                     (Basis.cdata "      ")))))))))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "      ")
                           (Basis.join
                             (Basis.form Basis.None Basis.None
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "        ")
                                   (Basis.join
                                     (Basis.tag Basis.null Basis.None
                                       Basis.noStyle Basis.None {} (tabl {})
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join (Basis.cdata "          ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (tr {})
                                               (Basis.join (Basis.cdata " ")
                                                 (Basis.join
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None {} (th {})
                                                     (Basis.cdata "Id:"))
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
                                                           (textbox [#Id] {})
                                                           (Basis.cdata "")))
                                                       (Basis.cdata " "))))))
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.join
                                                 (Basis.cdata "          ")
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
                                                           (Basis.cdata "Name:"))
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
                                                                 Basis.None {}
                                                                 (textbox
                                                                   [#Nam] {})
                                                                 (Basis.cdata
                                                                   "")))
                                                             (Basis.cdata " "))))))
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
                                                           (tr {})
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
                                                                   "Parent:"))
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
                                                                     {} (td {})
                                                                     (Basis.tag
                                                                       Basis.
                                                                        null
                                                                       Basis.
                                                                        None
                                                                       Basis.
                                                                        noStyle
                                                                       Basis.
                                                                        None {}
                                                                       (textbox
                                                                         [#Parent]
                                                                         {})
                                                                       (Basis.
                                                                         cdata
                                                                         "")))
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
                                                                       Basis.
                                                                        null
                                                                       Basis.
                                                                        None
                                                                       Basis.
                                                                        noStyle
                                                                       Basis.
                                                                        None {}
                                                                       (th {})
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
                                                                              }
                                                                             (submit
                                                                               {})
                                                                             (Basis.
                                                                               cdata
                                                                               [
                                                                               (_
                                                                               ::
                                                                               _)]
                                                                               [
                                                                               []]
                                                                               "")))
                                                                         (Basis.
                                                                           cdata
                                                                           " "))))))
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   "\n")
                                                                 (Basis.cdata
                                                                   "        ")))))))))))))))
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.cdata "      "))))))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.cdata "    ")))))))))))
                                                              and 
      add : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (dml
           (Basis.insert t
             {Id = Basis.sql_inject (readError r.#Id), 
               Nam = Basis.sql_inject r.#Nam, 
               Parent =
                Basis.sql_inject
                 (case r.#Parent of "" => None | s => Some (readError s))}))
         (fn _ : {} => main {})
   end
 export Constraints
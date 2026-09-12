database dbname=test
 
 structure Outer : sig
                    val main : unit -> transaction page
                    end =
  struct
   table t : [#Id = int, #B = string] keys
    Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints Basis.no_constraint
    
    table u : [#Id = int, #Link = int, #C = string, #D = option float] keys
     Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints
     Basis.one_constraint [#Link]
      (Basis.foreign_key (Basis.mat_cons [#Link] [#Id] Basis.mat_nil) t
        {OnDelete = Basis.no_action, OnUpdate = Basis.no_action})
    
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
                 {Distinct = Basis.False, 
                   From =
                    Basis.sql_left_join (Basis.sql_from_table [#T] t)
                     (Basis.sql_from_table [#U] u)
                     (Basis.sql_binary Basis.sql_eq
                       (Basis.sql_field [#T] [#Id])
                       (Basis.sql_field [#U] [#Link])), 
                   Where = Basis.sql_inject Basis.True, 
                   GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                   Having = Basis.sql_inject Basis.True, 
                   SelectFields =
                    Basis.sql_subset
                     [[#T =
                        ([#B = (_ :: Type)] ++ [#Id = (_ :: Type)], 
                          (_ :: {Type})), 
                        #U =
                         ([#D = (_ :: Type)] ++
                           [#C = (_ :: Type)] ++ [#Id = (_ :: Type)], 
                           (_ :: {Type}))]], SelectExps = {}}, 
                OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
            (fn r =>
              Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (tr {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "                    ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (td {}) (Top.txt r.#T.#Id))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "                    ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (td {}) (Top.txt r.#T.#B))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.join (Basis.cdata "                    ")
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (td {}) (Top.txt r.#U.#Id))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join
                                     (Basis.cdata "                    ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (td {})
                                         (Top.txt r.#U.#C))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join
                                           (Basis.cdata "                    ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (td {}) (Top.txt r.#U.#D))
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.cdata
                                                 "                  ")))))))))))))))))))
          (fn xml =>
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "      ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (tabl {}) xml)
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "      ")
                           (Basis.join
                             (Basis.form Basis.None Basis.None
                               (Basis.join (Basis.cdata "Insert into t: ")
                                 (Basis.join
                                   (Basis.tag Basis.null Basis.None
                                     Basis.noStyle Basis.None {Size = 5}
                                     (textbox [#Id] {}) (Basis.cdata ""))
                                   (Basis.join (Basis.cdata " ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {Size = 5}
                                         (textbox [#B] {}) (Basis.cdata ""))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join (Basis.cdata "        ")
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None
                                             {Action = addT} (submit {})
                                             (Basis.cdata [(_ :: _)] [[]] "")))))))))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "      ")
                                 (Basis.join
                                   (Basis.form Basis.None Basis.None
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.join
                                         (Basis.cdata "        Insert into u: ")
                                         (Basis.join
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None
                                             {Size = 5} (textbox [#Id] {})
                                             (Basis.cdata ""))
                                           (Basis.join (Basis.cdata " ")
                                             (Basis.join
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None
                                                 {Size = 5}
                                                 (textbox [#Link] {})
                                                 (Basis.cdata ""))
                                               (Basis.join (Basis.cdata " ")
                                                 (Basis.join
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None {Size = 5}
                                                     (textbox [#C] {})
                                                     (Basis.cdata ""))
                                                   (Basis.join
                                                     (Basis.cdata "\n")
                                                     (Basis.join
                                                       (Basis.cdata "        ")
                                                       (Basis.join
                                                         (Basis.tag Basis.null
                                                           Basis.None
                                                           Basis.noStyle
                                                           Basis.None
                                                           {Size = 5}
                                                           (textbox [#D] {})
                                                           (Basis.cdata ""))
                                                         (Basis.join
                                                           (Basis.cdata " ")
                                                           (Basis.join
                                                             (Basis.tag
                                                               Basis.null
                                                               Basis.None
                                                               Basis.noStyle
                                                               Basis.None
                                                               {Action = addU}
                                                               (submit {})
                                                               (Basis.cdata
                                                                 [(_ :: _)]
                                                                 [[]] ""))
                                                             (Basis.join
                                                               (Basis.cdata
                                                                 "\n")
                                                               (Basis.cdata
                                                                 "      ")))))))))))))))
                                   (Basis.join (Basis.cdata "\n")
                                     (Basis.cdata "    "))))))))))))))
                                                                       and 
      addT : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (dml
           (Basis.insert t
             {Id = Basis.sql_inject (readError r.#Id), 
               B = Basis.sql_inject r.#B})) (fn _ : {} => main {})
                                                                   and 
      addU : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (dml
           (Basis.insert u
             {Id = Basis.sql_inject (readError r.#Id), 
               Link = Basis.sql_inject (readError r.#Link), 
               C = Basis.sql_inject r.#C, D = Basis.sql_inject (readError r.#D)}))
         (fn _ : {} => main {})
   end
 export Outer
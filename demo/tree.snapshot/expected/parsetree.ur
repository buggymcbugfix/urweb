database dbname=test
 
 structure TreeFun :
  sig
   structure Make :
    functor (M
     :sig
       con key :: Type
        con id :: Name
        con parent :: Name
        con cols :: {Type}
        constraint [id = ()] ~ [parent = ()]
        constraint [id = (), parent = ()] ~ cols
        val key_inj : sql_injectable_prim key
        
        table tab : [id = key, parent = option key] ++ cols keys
         Basis.no_primary_key constraints Basis.no_constraint
       end) :
     sig
      con id :: _ = M.id
       con parent :: _ = M.parent
       
       val tree :
        ($([id = M.key, parent = option M.key] ++ M.cols) -> xbody) ->
         (option M.key) -> transaction xbody
      end
   end =
  struct
   structure Make =
    functor (M
     :sig
       con key :: Type
        con id :: Name
        con parent :: Name
        con cols :: {Type}
        constraint [id = ()] ~ [parent = ()]
        constraint [id = (), parent = ()] ~ cols
        val key_inj : sql_injectable_prim key
        
        table tab : [id = key, parent = option key] ++ cols keys
         Basis.no_primary_key constraints Basis.no_constraint
       end) =>
     struct
      open M
       
       val rec
        tree :
         ($([id = key, parent = option key] ++ cols) -> xbody) ->
          (option M.key) -> (_ :: Type) =
         fn f : $([id = key, parent = option key] ++ cols) -> xbody =>
          fn root : option M.key =>
           let
            val rec
             recurse : (option key) -> (_ :: Type) =
              fn root : option key =>
               queryX'
                (Basis.sql_query
                  {Rows =
                    Basis.sql_query1 [[]]
                     {Distinct = Basis.False, 
                       From = Basis.sql_from_table [#Tab] tab, 
                       Where =
                        eqNullable' (Basis.sql_field [#Tab] [parent]) root, 
                       GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                       Having = Basis.sql_inject Basis.True, 
                       SelectFields =
                        Basis.sql_subset [[#Tab = ((_ :: {Type}), [])]], 
                       SelectExps = {}}, 
                    OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                    Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
                (fn r =>
                  Basis.bind (recurse (Some r.#Tab.id))
                   (fn children =>
                     return
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join
                          (Basis.cdata "                              ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (li {})
                              (Basis.join (Basis.cdata " ") (f r.#Tab)))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join
                                (Basis.cdata "                              ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (li {})
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join
                                        (Basis.cdata
                                          "                                ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None {} (ul {})
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata
                                                  "                                  ")
                                                (Basis.join children
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.cdata
                                                      "                                "))))))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata
                                              "                              "))))))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.cdata "                            "))))))))))
            in
            Basis.bind (recurse root)
             (fn res =>
               return
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (ul {}) res))
            end
      end
   end
 
 structure Tree : sig
                   val main : unit -> transaction page
                   end =
  struct
   sequence s
    
    table t : [#Id = int, #Parent = option int, #Nam = string] keys
     Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints
     Basis.one_constraint [#F]
      (Basis.foreign_key (Basis.mat_cons [#Parent] [#Id] Basis.mat_nil) t
        {OnDelete = Basis.cascade, OnUpdate = Basis.no_action})
    
    structure anon =
     TreeFun.Make(struct
                   con id :: _ = #Id
                    con parent :: _ = #Parent
                    val tab = t
                   end)
    open anon
    
    val rec
     row : (_ :: Type) -> (_ :: Type) =
      fn r =>
       Basis.join (Basis.cdata "\n")
        (Basis.join (Basis.cdata "  #")
          (Basis.join (Top.txt r.#Id)
            (Basis.join (Basis.cdata ": ")
              (Basis.join (Top.txt r.#Nam)
                (Basis.join (Basis.cdata " ")
                  (Basis.join
                    (Basis.form Basis.None Basis.None
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {Action = del r.#Id, Value = "Delete"} (submit {})
                        (Basis.cdata [(_ :: _)] [[]] "")))
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "  ")
                          (Basis.join
                            (Basis.form Basis.None Basis.None
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "    Add child: ")
                                  (Basis.join
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None {}
                                      (textbox [#Nam] {}) (Basis.cdata ""))
                                    (Basis.join (Basis.cdata " ")
                                      (Basis.join
                                        (Basis.tag Basis.null Basis.None
                                          Basis.noStyle Basis.None
                                          {Action = add (Some r.#Id)}
                                          (submit {})
                                          (Basis.cdata [(_ :: _)] [[]] ""))
                                        (Basis.join (Basis.cdata "\n")
                                          (Basis.cdata "  "))))))))
                            (Basis.cdata "\n")))))))))))
                                                         and 
      main : (_ :: Type) -> (_ :: Type) =
       fn $x : (_ :: Type) =>
        case $x of
         {} =>
          Basis.bind (tree row None)
           (fn xml =>
             return
              (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                (body {})
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "      ")
                    (Basis.join xml
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "      ")
                            (Basis.join
                              (Basis.form Basis.None Basis.None
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join
                                    (Basis.cdata
                                      "        Add a top-level node: ")
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None {}
                                        (textbox [#Nam] {}) (Basis.cdata ""))
                                      (Basis.join (Basis.cdata " ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None
                                            {Action = add None} (submit {})
                                            (Basis.cdata [(_ :: _)] [[]] ""))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata "      "))))))))
                              (Basis.join (Basis.cdata "\n")
                                (Basis.cdata "    ")))))))))))
                                                               and 
      add : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
       fn parent =>
        fn r =>
         Basis.bind (nextval s)
          (fn id =>
            Basis.bind
             (dml
               (Basis.insert t
                 {Id = Basis.sql_inject id, Parent = Basis.sql_inject parent, 
                   Nam = Basis.sql_inject r.#Nam})) (fn _ : {} => main {}))
                                                                            and 
      del : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
       fn id =>
        fn $x : (_ :: Type) =>
         case $x of
          {} =>
           Basis.bind
            (dml
              (Basis.delete t
                (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
                  (Basis.sql_inject id)))) (fn _ : {} => main {})
   end
 export Tree
database dbname=test
 
 structure View : sig
                   val main : unit -> transaction page
                   end =
  struct
   table t : [#A = int] keys Basis.no_primary_key constraints
    Basis.no_constraint
    
    view v =
     Basis.sql_query
      {Rows =
        Basis.sql_query1 [[#T = ()]]
         {Distinct = Basis.False, From = Basis.sql_from_table [#T] t, 
           Where =
            Basis.sql_binary Basis.sql_gt (Basis.sql_field [#T] [#A])
             (Basis.sql_inject 7), 
           GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
           Having = Basis.sql_inject Basis.True, 
           SelectFields = Basis.sql_subset [[#T = ([], (_ :: {Type}))]], 
           SelectExps = {A = Basis.sql_window (Basis.sql_field [#T] [#A])}}, 
        OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
        Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}
    
    val rec
     list :
      u ::: _ -> (fieldsOf u [#A = int]) -> string -> u -> transaction xbody =
      fn u ::: _ =>
       fn _ : fieldsOf u [#A = int] =>
        fn title : string =>
         fn x : u =>
          Basis.bind
           (queryX
             (Basis.sql_query
               {Rows =
                 Basis.sql_query1 [[]]
                  {Distinct = Basis.False, From = Basis.sql_from_table [#X] x, 
                    Where = Basis.sql_inject Basis.True, 
                    GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                    Having = Basis.sql_inject Basis.True, 
                    SelectFields =
                     Basis.sql_subset [[#X = ((_ :: {Type}), [])]], 
                    SelectExps = {}}, 
                 OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                 Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
             (fn r : {X : {A : int}} =>
               Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                (li {}) (Top.txt r.#X.#A)))
           (fn xml =>
             return
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "      ")
                  (Basis.join
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (h2 {}) (Top.txt title))
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "      ")
                        (Basis.join
                          (Basis.tag Basis.null Basis.None Basis.noStyle
                            Basis.None {} (ul {}) xml)
                          (Basis.join (Basis.cdata "\n") (Basis.cdata "    ")))))))))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (list "T" t)
          (fn listT =>
            Basis.bind (list "V" v)
             (fn listV =>
               return
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (body {})
                  (Basis.join (Basis.cdata "\n")
                    (Basis.join (Basis.cdata "      ")
                      (Basis.join listT
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "      ")
                            (Basis.join listV
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "      ")
                                  (Basis.join
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None {} (br {})
                                      (Basis.cdata ""))
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join (Basis.cdata "      ")
                                          (Basis.join
                                            (Basis.form Basis.None Basis.None
                                              (Basis.join
                                                (Basis.cdata "Insert: ")
                                                (Basis.join
                                                  (Basis.tag Basis.null
                                                    Basis.None Basis.noStyle
                                                    Basis.None {}
                                                    (textbox [#A] {})
                                                    (Basis.cdata ""))
                                                  (Basis.join (Basis.cdata " ")
                                                    (Basis.tag Basis.null
                                                      Basis.None Basis.noStyle
                                                      Basis.None {Action = ins}
                                                      (submit {})
                                                      (Basis.cdata [(_ :: _)]
                                                        [[]] ""))))))
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.cdata "    "))))))))))))))))))
      
       and 
      ins : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (dml (Basis.insert t {A = Basis.sql_inject (readError r.#A)}))
         (fn _ : {} => main {})
   end
 export View
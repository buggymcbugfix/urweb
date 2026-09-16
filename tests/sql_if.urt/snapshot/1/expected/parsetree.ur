database dbname=sql_if
 
 structure Sql_if : sig
                     val main : unit -> transaction page
                     end =
  struct
   table t : [#A = int, #B = int] keys Basis.no_primary_key constraints
    Basis.no_constraint
    
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
                   Where =
                    Basis.sql_if_then_else
                     (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#A])
                       (Basis.sql_inject 6))
                     (Basis.sql_binary Basis.sql_lt (Basis.sql_field [#T] [#B])
                       (Basis.sql_inject 2))
                     (Basis.sql_binary Basis.sql_gt (Basis.sql_field [#T] [#B])
                       (Basis.sql_inject 5)), 
                   GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                   Having = Basis.sql_inject Basis.True, 
                   SelectFields = Basis.sql_subset [[#T = ((_ :: {Type}), [])]],
                                                                               
                   SelectExps = {}}, 
                OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
            (fn r =>
              Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (li {})
               (Basis.join (Top.txt r.#T.#A)
                 (Basis.join (Basis.cdata ", ") (Top.txt r.#T.#B)))))
          (fn x =>
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {}) x))
   end
 export Sql_if
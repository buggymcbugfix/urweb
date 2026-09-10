database dbname=test
 
 structure Batch : sig
                    val main : unit -> transaction page
                    end =
  struct
   datatype list t = Nil | Cons of {1 : t, 2 : list t}
    
    table t : [#Id = int, #A = string] keys
     Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints Basis.no_constraint
    
    val rec
     allRows : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         query
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
            fn acc => return (Cons {1 = {1 = r.#T.#Id, 2 = r.#T.#A}, 2 = acc}))
          Nil
    
    val rec
     doBatch : (_ :: Type) -> (_ :: Type) =
      fn ls =>
       case ls of
        Nil => return {} | 
         Cons {1 = {1 = id, 2 = a}, 2 = ls'} =>
          Basis.bind
           (dml
             (Basis.insert t {Id = Basis.sql_inject id, A = Basis.sql_inject a}))
           (fn _ : {} => doBatch ls')
    
    val rec
     del : (_ :: Type) -> (_ :: Type) =
      fn id =>
       dml
        (Basis.delete t
          (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
            (Basis.sql_inject id)))
    
    val rec
     show : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
      fn withDel =>
       fn lss =>
        let
         val rec
          show' : (_ :: Type) -> (_ :: Type) =
           fn ls =>
            case ls of
             Nil => Basis.cdata "" | 
              Cons {1 = {1 = id, 2 = a}, 2 = ls} =>
               Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "                ")
                  (Basis.join
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (tr {})
                      (Basis.join
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (td {}) (Top.txt id))
                        (Basis.join (Basis.cdata " ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (td {}) (Top.txt a))
                            (Basis.join (Basis.cdata " ")
                              (Basis.join
                                (case withDel of
                                  Basis.True =>
                                   Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (td {})
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None
                                        {Value = "Delete", 
                                          Onclick = fn _ => rpc (del id)}
                                        (button {}) (Basis.cdata ""))
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.cdata
                                          "                                                        ")))
                                    | Basis.False => Basis.cdata "")
                                (Basis.cdata " ")))))))
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "                ")
                        (Basis.join (show' ls)
                          (Basis.join (Basis.cdata "\n")
                            (Basis.cdata "              ")))))))
         in
         Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
          {Signal =
            Basis.bind (signal lss)
             (fn ls =>
               return
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (tabl {})
                  (Basis.join (Basis.cdata "\n")
                    (Basis.join (Basis.cdata "          ")
                      (Basis.join
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (tr {})
                          (Basis.join (Basis.cdata " ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (th {}) (Basis.cdata "Id"))
                              (Basis.join (Basis.cdata " ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (th {})
                                    (Basis.cdata "A")) (Basis.cdata " "))))))
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "          ")
                            (Basis.join (show' ls)
                              (Basis.join (Basis.cdata "\n")
                                (Basis.cdata "        "))))))))))} (dyn {})
          (Basis.cdata [(_ :: _)] [[]] "")
         end
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (source Nil)
          (fn lss =>
            Basis.bind (source Nil)
             (fn batched =>
               Basis.bind (source "")
                (fn id =>
                  Basis.bind (source "")
                   (fn a =>
                     let
                      val rec
                       add : (_ :: Type) -> (_ :: Type) =
                        fn $x : (_ :: Type) =>
                         case $x of
                          {} =>
                           Basis.bind (get id)
                            (fn id =>
                              Basis.bind (get a)
                               (fn a =>
                                 Basis.bind (get batched)
                                  (fn ls =>
                                    set batched
                                     (Cons
                                       {1 = {1 = readError id, 2 = a}, 2 = ls}))))
                       
                       val rec
                        exec : (_ :: Type) -> (_ :: Type) =
                         fn $x : (_ :: Type) =>
                          case $x of
                           {} =>
                            Basis.bind (get batched)
                             (fn ls =>
                               Basis.bind (rpc (doBatch ls))
                                (fn _ : {} => set batched Nil))
                      in
                      return
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {} (body {})
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "          ")
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {} (h2 {}) (Basis.cdata "Rows"))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "          ")
                                     (Basis.join (show True lss)
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join (Basis.cdata "\n")
                                           (Basis.join
                                             (Basis.cdata "          ")
                                             (Basis.join
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None
                                                 {Value = "Update", 
                                                   Onclick =
                                                    fn _ =>
                                                     Basis.bind
                                                      (rpc (allRows {}))
                                                      (fn ls => set lss ls)}
                                                 (button {}) (Basis.cdata ""))
                                               (Basis.join
                                                 (Basis.tag Basis.null
                                                   Basis.None Basis.noStyle
                                                   Basis.None {} (br {})
                                                   (Basis.cdata ""))
                                                 (Basis.join (Basis.cdata "\n")
                                                   (Basis.join
                                                     (Basis.cdata "          ")
                                                     (Basis.join
                                                       (Basis.tag Basis.null
                                                         Basis.None
                                                         Basis.noStyle
                                                         Basis.None {} (br {})
                                                         (Basis.cdata ""))
                                                       (Basis.join
                                                         (Basis.cdata "\n")
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
                                                                 (h2 {})
                                                                 (Basis.cdata
                                                                   "Batch new rows to add"))
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   "\n")
                                                                 (Basis.join
                                                                   (Basis.cdata
                                                                     "\n")
                                                                   (Basis.join
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
                                                                         (tabl
                                                                           {})
                                                                         (Basis.
                                                                           join
                                                                           (Basis.
                                                                             cdata
                                                                             "\n")
                                                                           (Basis.
                                                                             join
                                                                             (Basis.
                                                                               cdata
                                                                               "            ")
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
                                                                               "Id:"))
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
                                                                               {Source
                                                                               =
                                                                               id
                                                                               }
                                                                               (ctextbox
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
                                                                               "            ")
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
                                                                               "A:"))
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
                                                                               {Source
                                                                               =
                                                                               a}
                                                                               (ctextbox
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
                                                                               "            ")
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
                                                                               {Value
                                                                               =
                                                                               "Batch it"
                                                                               ,
                                                                               
                                                                               Onclick
                                                                               =
                                                                               fn
                                                                               _
                                                                               =>
                                                                               add
                                                                               {}
                                                                               }
                                                                               (button
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
                                                                               cdata
                                                                               "          "))))))))))))
                                                                       (Basis.
                                                                         join
                                                                         (Basis.
                                                                           cdata
                                                                           "\n")
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
                                                                               (h2
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               "Already batched:"))
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
                                                                               (show
                                                                               False
                                                                               batched)
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
                                                                               {Value
                                                                               =
                                                                               "Execute"
                                                                               ,
                                                                               
                                                                               Onclick
                                                                               =
                                                                               fn
                                                                               _
                                                                               =>
                                                                               exec
                                                                               {}
                                                                               }
                                                                               (button
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               ""))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "\n")
                                                                               (Basis.
                                                                               cdata
                                                                               "        "))))))))))))))))))))))))))))))))))))
                      end))))
   end
 export Batch
database dbname=test
 
 structure Noisy : sig
                    val main : unit -> transaction page
                    end =
  struct
   datatype list t = Nil | Cons of {1 : t, 2 : list t}
    
    table t : [#Id = int, #A = string] keys
     Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints Basis.no_constraint
    
    val rec
     add : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
      fn id =>
       fn s =>
        dml (Basis.insert t {Id = Basis.sql_inject id, A = Basis.sql_inject s})
    
    val rec
     del : (_ :: Type) -> (_ :: Type) =
      fn id =>
       dml
        (Basis.delete t
          (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
            (Basis.sql_inject id)))
    
    val rec
     lookup : (_ :: Type) -> (_ :: Type) =
      fn id =>
       Basis.bind
        (oneOrNoRows
          (Basis.sql_query
            {Rows =
              Basis.sql_query1 [[]]
               {Distinct = Basis.False, From = Basis.sql_from_table [#T] t, 
                 Where =
                  Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
                   (Basis.sql_inject id), 
                 GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                 Having = Basis.sql_inject Basis.True, 
                 SelectFields =
                  Basis.sql_subset [[#T = ([#A = (_ :: Type)], (_ :: {Type}))]],
                                                                               
                 SelectExps = {}}, 
              OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
              Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}))
        (fn ro =>
          case ro of None => return None | Some r => return (Some r.#T.#A))
    
    val rec
     check : (_ :: Type) -> (_ :: Type) =
      fn ls =>
       case ls of
        Nil => return {} | 
         Cons {1 = id, 2 = ls'} =>
          Basis.bind (rpc (lookup id))
           (fn ao =>
             Basis.bind (alert (case ao of None => "Nada" | Some a => a))
              (fn _ : {} => check ls'))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (source "")
          (fn idAdd =>
            Basis.bind (source "")
             (fn aAdd =>
               Basis.bind (source "")
                (fn idDel =>
                  return
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (body {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "      ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None
                             {Value = "Check values of 1, 2, and 3", 
                               Onclick =
                                fn _ =>
                                 check
                                  (Cons
                                    {1 = 1, 
                                      2 =
                                       Cons {1 = 2, 2 = Cons {1 = 3, 2 = Nil}}})
                              } (button {}) (Basis.cdata ""))
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (br {}) (Basis.cdata ""))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "      ")
                                 (Basis.join
                                   (Basis.tag Basis.null Basis.None
                                     Basis.noStyle Basis.None {} (br {})
                                     (Basis.cdata ""))
                                   (Basis.join (Basis.cdata "\n")
                                     (Basis.join (Basis.cdata "      ")
                                       (Basis.join
                                         (Basis.tag Basis.null Basis.None
                                           Basis.noStyle Basis.None
                                           {Value = "Add", 
                                             Onclick =
                                              fn _ =>
                                               Basis.bind (get idAdd)
                                                (fn id =>
                                                  Basis.bind (get aAdd)
                                                   (fn a =>
                                                     rpc (add (readError id) a)))
                                            } (button {}) (Basis.cdata ""))
                                         (Basis.join (Basis.cdata "\n")
                                           (Basis.join (Basis.cdata "      ")
                                             (Basis.join
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None
                                                 {Source = idAdd} (ctextbox {})
                                                 (Basis.cdata ""))
                                               (Basis.join (Basis.cdata "\n")
                                                 (Basis.join
                                                   (Basis.cdata "      ")
                                                   (Basis.join
                                                     (Basis.tag Basis.null
                                                       Basis.None Basis.noStyle
                                                       Basis.None
                                                       {Source = aAdd}
                                                       (ctextbox {})
                                                       (Basis.cdata ""))
                                                     (Basis.join
                                                       (Basis.tag Basis.null
                                                         Basis.None
                                                         Basis.noStyle
                                                         Basis.None {} (br {})
                                                         (Basis.cdata ""))
                                                       (Basis.join
                                                         (Basis.cdata "\n")
                                                         (Basis.join
                                                           (Basis.cdata
                                                             "      ")
                                                           (Basis.join
                                                             (Basis.tag
                                                               Basis.null
                                                               Basis.None
                                                               Basis.noStyle
                                                               Basis.None {}
                                                               (br {})
                                                               (Basis.cdata ""))
                                                             (Basis.join
                                                               (Basis.cdata
                                                                 "\n")
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   "      ")
                                                                 (Basis.join
                                                                   (Basis.tag
                                                                     Basis.null
                                                                     Basis.None
                                                                     Basis.
                                                                      noStyle
                                                                     Basis.None
                                                                     {Value =
                                                                       "Delete",
                                                                               
                                                                       Onclick
                                                                        =
                                                                        fn _ =>
                                                                         Basis.
                                                                          bind
                                                                          (get
                                                                            idDel)
                                                                          (fn
                                                                            id
                                                                            =>
                                                                            rpc
                                                                             (del
                                                                               (readError
                                                                               id)))
                                                                      }
                                                                     (button {})
                                                                     (Basis.
                                                                       cdata ""))
                                                                   (Basis.join
                                                                     (Basis.
                                                                       cdata
                                                                       "\n")
                                                                     (Basis.
                                                                       join
                                                                       (Basis.
                                                                         cdata
                                                                         "      ")
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
                                                                           {Source
                                                                             =
                                                                             idDel
                                                                            }
                                                                           (ctextbox
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
                                                                             "    "))))))))))))))))))))))))))))))))
   end
 export Noisy
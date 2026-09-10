database dbname=test
 
 structure BatchFun :
  sig
   con colMeta :: _ =
    fn $x :: (Type * Type) =>
     fn db :: Type =>
      fn state :: Type =>
       {Nam : string, Show : db -> xbody, Inject : sql_injectable db, 
         NewState : transaction state, Widget : state -> xbody, 
         ReadState : state -> transaction db} $x.1 $x.2
    con colsMeta :: _ = fn cols :: {(Type * Type)} => $(map colMeta cols)
    val int : string -> colMeta (int, source string)
    val float : string -> colMeta (float, source string)
    val string : string -> colMeta (string, source string)
    
    structure Make :
     functor (M
      :sig
        con cols :: {(Type * Type)}
         constraint [#Id = ()] ~ cols
         val fl : folder cols
         
         table tab : [#Id = int] ++ map fst cols keys Basis.no_primary_key
          constraints Basis.no_constraint
         val title : string
         val cols : colsMeta cols
        end) : sig
                val main : unit -> transaction page
                end
   end =
  struct
   con colMeta :: _ =
    fn $x :: (Type * Type) =>
     fn db :: Type =>
      fn state :: Type =>
       {Nam : string, Show : db -> xbody, Inject : sql_injectable db, 
         NewState : transaction state, Widget : state -> xbody, 
         ReadState : state -> transaction db} $x.1 $x.2
    con colsMeta :: _ = fn cols => $(map colMeta cols)
    
    val rec
     default :
      t ::: _ ->
       (show t) ->
        (read t) ->
         (sql_injectable t) -> (_ :: Type) -> colMeta (t, source string) =
      fn t ::: _ =>
       fn sh : show t =>
        fn rd : read t =>
         fn inj : sql_injectable t =>
          fn name =>
           {Nam = name, Show = txt, Inject = _, NewState = source "", 
             Widget =
              fn s =>
               Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                {Source = s} (ctextbox {}) (Basis.cdata ""), 
             ReadState =
              fn s => Basis.bind (get s) (fn v => return (readError v))}
    val int = default
    val float = default
    val string = default
    
    structure Make =
     functor (M
      :sig
        con cols :: {(Type * Type)}
         constraint [#Id = ()] ~ cols
         val fl : folder cols
         
         table tab : [#Id = int] ++ map fst cols keys Basis.no_primary_key
          constraints Basis.no_constraint
         val title : string
         val cols : colsMeta cols
        end) =>
      struct
       val t = M.tab
        datatype list t = Nil | Cons of {1 : t, 2 : list t}
        
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
                     SelectFields =
                      Basis.sql_subset [[#T = ((_ :: {Type}), [])]], 
                     SelectExps = {}}, 
                  OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                  Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
              (fn r => fn acc => return (Cons {1 = r.#T, 2 = acc})) Nil
        
        val rec
         add : (_ :: Type) -> (_ :: Type) =
          fn r =>
           dml
            (insert t
              ((foldR2 [fst] [colMeta]
                 [fn cols => $(map (fn t => sql_exp [] [] [] t.1) cols)]
                 (fn nm :: Name =>
                   fn t :: _ =>
                    fn rest :: _ =>
                     [nm = ()] ~ rest =>
                      fn input =>
                       fn col =>
                        fn acc => acc ++ {nm = sql_inject col.#Inject input})
                 {} M.fl (r -- #Id) M.cols) ++ {Id = Basis.sql_inject r.#Id}))
        
        val rec
         doBatch : (_ :: Type) -> (_ :: Type) =
          fn ls =>
           case ls of
            Nil => return {} | 
             Cons {1 = r, 2 = ls'} =>
              Basis.bind (add r) (fn _ : {} => doBatch ls')
        
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
                  Cons {1 = r, 2 = ls} =>
                   Basis.join (Basis.cdata "\n")
                    (Basis.join (Basis.cdata "                    ")
                      (Basis.join
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (tr {})
                          (Basis.join (Basis.cdata "\n")
                            (Basis.join (Basis.cdata "                      ")
                              (Basis.join
                                (Basis.tag Basis.null Basis.None Basis.noStyle
                                  Basis.None {} (td {}) (Top.txt r.#Id))
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join
                                    (Basis.cdata "                      ")
                                    (Basis.join
                                      (mapX2 [colMeta] [fst] [(_ :: _)]
                                        (fn nm :: Name =>
                                          fn p :: _ =>
                                           fn rest :: _ =>
                                            [nm = ()] ~ rest =>
                                             fn m =>
                                              fn v =>
                                               Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None {}
                                                (td {}) (m.#Show v)) M.fl
                                        M.cols (r -- #Id))
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join
                                          (Basis.cdata "                      ")
                                          (Basis.join
                                            (case withDel of
                                              Basis.True =>
                                               Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None {}
                                                (td {})
                                                (Basis.tag Basis.null
                                                  Basis.None Basis.noStyle
                                                  Basis.None
                                                  {Value = "Delete", 
                                                    Onclick =
                                                     fn _ => rpc (del r.#Id)}
                                                  (button {}) (Basis.cdata ""))
                                                                               |
                                                                               
                                               Basis.False => Basis.cdata "")
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.cdata
                                                "                    "))))))))))))
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "                    ")
                            (Basis.join (show' ls)
                              (Basis.join (Basis.cdata "\n")
                                (Basis.cdata "                  ")))))))
             in
             Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
              {Signal =
                Basis.bind (signal lss)
                 (fn ls =>
                   return
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (tabl {})
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "              ")
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (tr {})
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "                ")
                                  (Basis.join
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None {} (th {})
                                      (Basis.cdata "Id"))
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join
                                        (Basis.cdata "                ")
                                        (Basis.join
                                          (mapX [colMeta] [tr]
                                            (fn nm :: Name =>
                                              fn p :: _ =>
                                               fn rest :: _ =>
                                                [nm = ()] ~ rest =>
                                                 fn m =>
                                                  Basis.tag Basis.null
                                                   Basis.None Basis.noStyle
                                                   Basis.None {} (th {})
                                                   (Top.txt m.#Nam)) M.fl
                                            M.cols)
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata "              ")))))))))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "              ")
                                (Basis.join (show' ls)
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.cdata "            "))))))))))}
              (dyn {}) (Basis.cdata [(_ :: _)] [[]] "")
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
                      Basis.bind
                       (foldR [colMeta] [fn r => transaction $(map snd r)]
                         (fn nm :: Name =>
                           fn p :: _ =>
                            fn rest :: _ =>
                             [nm = ()] ~ rest =>
                              fn m =>
                               fn acc =>
                                Basis.bind m.#NewState
                                 (fn s =>
                                   Basis.bind acc
                                    (fn r => return ({nm = s} ++ r))))
                         (return {}) M.fl M.cols)
                       (fn inps =>
                         let
                          val rec
                           add : (_ :: Type) -> (_ :: Type) =
                            fn $x : (_ :: Type) =>
                             case $x of
                              {} =>
                               Basis.bind (get id)
                                (fn id =>
                                  Basis.bind
                                   (foldR2 [colMeta] [snd]
                                     [fn r => transaction $(map fst r)]
                                     (fn nm :: Name =>
                                       fn p :: _ =>
                                        fn rest :: _ =>
                                         [nm = ()] ~ rest =>
                                          fn m =>
                                           fn s =>
                                            fn acc =>
                                             Basis.bind (m.#ReadState s)
                                              (fn v =>
                                                Basis.bind acc
                                                 (fn r =>
                                                   return ({nm = v} ++ r))))
                                     (return {}) M.fl M.cols inps)
                                   (fn vs =>
                                     Basis.bind (get batched)
                                      (fn ls =>
                                        set batched
                                         (Cons
                                           {1 = {Id = readError id} ++ vs, 
                                             2 = ls}))))
                           
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
                               (Basis.join (Basis.cdata "              ")
                                 (Basis.join
                                   (Basis.tag Basis.null Basis.None
                                     Basis.noStyle Basis.None {} (h2 {})
                                     (Basis.cdata "Rows"))
                                   (Basis.join (Basis.cdata "\n")
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.join
                                         (Basis.cdata "              ")
                                         (Basis.join (show True lss)
                                           (Basis.join (Basis.cdata "\n")
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.join
                                                 (Basis.cdata "              ")
                                                 (Basis.join
                                                   (Basis.tag Basis.null
                                                     Basis.None Basis.noStyle
                                                     Basis.None
                                                     {Value = "Update", 
                                                       Onclick =
                                                        fn _ =>
                                                         Basis.bind
                                                          (rpc (allRows {}))
                                                          (fn ls => set lss ls)}
                                                     (button {})
                                                     (Basis.cdata ""))
                                                   (Basis.join
                                                     (Basis.tag Basis.null
                                                       Basis.None Basis.noStyle
                                                       Basis.None {} (br {})
                                                       (Basis.cdata ""))
                                                     (Basis.join
                                                       (Basis.cdata "\n")
                                                       (Basis.join
                                                         (Basis.cdata
                                                           "              ")
                                                         (Basis.join
                                                           (Basis.tag
                                                             Basis.null
                                                             Basis.None
                                                             Basis.noStyle
                                                             Basis.None {}
                                                             (br {})
                                                             (Basis.cdata ""))
                                                           (Basis.join
                                                             (Basis.cdata "\n")
                                                             (Basis.join
                                                               (Basis.cdata
                                                                 "\n")
                                                               (Basis.join
                                                                 (Basis.cdata
                                                                   "              ")
                                                                 (Basis.join
                                                                   (Basis.tag
                                                                     Basis.null
                                                                     Basis.None
                                                                     Basis.
                                                                      noStyle
                                                                     Basis.None
                                                                     {} (h2 {})
                                                                     (Basis.
                                                                       cdata
                                                                       "Batch new rows to add"))
                                                                   (Basis.join
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
                                                                           "              ")
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
                                                                               "                ")
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
                                                                               "                ")
                                                                               (Basis.
                                                                               join
                                                                               (mapX2
                                                                               [colMeta]
                                                                               [snd]
                                                                               [(_
                                                                               ::
                                                                               _)]
                                                                               (fn
                                                                               nm
                                                                               ::
                                                                               Name
                                                                               =>
                                                                               fn
                                                                               p
                                                                               ::
                                                                               _
                                                                               =>
                                                                               fn
                                                                               rest
                                                                               ::
                                                                               _
                                                                               =>
                                                                               [nm
                                                                               =
                                                                               ()]
                                                                               ~
                                                                               rest
                                                                               =>
                                                                               fn
                                                                               m
                                                                               =>
                                                                               fn
                                                                               s
                                                                               =>
                                                                               Basis.
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
                                                                               join
                                                                               (Top.
                                                                               txt
                                                                               m.
                                                                               #Nam)
                                                                               (Basis.
                                                                               cdata
                                                                               ":")))
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
                                                                               (m.
                                                                               #Widget
                                                                               s))
                                                                               (Basis.
                                                                               cdata
                                                                               " "))))))
                                                                               M.
                                                                               fl
                                                                               M.
                                                                               cols
                                                                               inps)
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "\n")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "                ")
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
                                                                               "              "))))))))))))
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
                                                                               "              ")
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
                                                                               "              ")
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
                                                                               "              ")
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
                                                                               "            "))))))))))))))))))))))))))))))))))))
                          end))))
       end
   end
 
 structure BatchG : sig
                     val main : unit -> transaction page
                     end =
  struct
   table t : [#Id = int, #A = string, #B = float] keys
    Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints Basis.no_constraint
    
    structure anon =
     BatchFun.Make(struct
                    val tab = t
                     val title = "BatchG"
                     
                     val cols =
                      {A = BatchFun.string "A", B = BatchFun.float "B"}
                    end)
    open anon
   end
 export BatchG
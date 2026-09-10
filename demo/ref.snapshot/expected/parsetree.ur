database dbname=test
 
 structure RefFun :
  sig
   structure Make :
    functor (M :sig
                 con data :: Type
                  val inj : sql_injectable data
                 end) :
     sig
      con ref :: Type
       val new : M.data -> transaction ref
       val read : ref -> transaction M.data
       val write : ref -> M.data -> transaction unit
       val delete : ref -> transaction unit
      end
   end =
  struct
   structure Make =
    functor (M :sig
                 con data :: Type
                  val inj : sql_injectable data
                 end) =>
     struct
      con ref :: _ = int
       sequence s
       
       table t : [#Id = int, #Data = M.data] keys
        Basis.primary_key [#Id] [[]] ! ! {Id = _} constraints
        Basis.no_constraint
       
       val rec
        new : (_ :: Type) -> (_ :: Type) =
         fn d =>
          Basis.bind (nextval s)
           (fn id =>
             Basis.bind
              (dml
                (Basis.insert t
                  {Id = Basis.sql_inject id, Data = Basis.sql_inject d}))
              (fn _ : {} => return id))
       
       val rec
        read : (_ :: Type) -> (_ :: Type) =
         fn r =>
          Basis.bind
           (oneOrNoRows
             (Basis.sql_query
               {Rows =
                 Basis.sql_query1 [[]]
                  {Distinct = Basis.False, From = Basis.sql_from_table [#T] t, 
                    Where =
                     Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
                      (Basis.sql_inject r), 
                    GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                    Having = Basis.sql_inject Basis.True, 
                    SelectFields =
                     Basis.sql_subset
                      [[#T = ([#Data = (_ :: Type)], (_ :: {Type}))]], 
                    SelectExps = {}}, 
                 OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                 Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}))
           (fn o =>
             case o of
              None => error (Basis.cdata "You already deleted that ref!") | 
               Some r => return r.#T.#Data)
       
       val rec
        write : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
         fn r =>
          fn d =>
           dml
            (Basis.update [(_ :: {Type})] {Data = Basis.sql_inject d} t
              (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
                (Basis.sql_inject r)))
       
       val rec
        delete : (_ :: Type) -> (_ :: Type) =
         fn r =>
          dml
           (Basis.delete t
             (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
               (Basis.sql_inject r)))
      end
   end
 
 structure Ref : sig
                  val main : unit -> transaction page
                  end =
  struct
   structure IR = RefFun.Make(struct
                               con data :: _ = int
                               end)
    structure SR = RefFun.Make(struct
                                con data :: _ = string
                                end)
    
    val rec
     mutate : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (IR.new 3)
          (fn ir =>
            Basis.bind (IR.new 7)
             (fn ir' =>
               Basis.bind (SR.new "hi")
                (fn sr =>
                  Basis.bind (IR.write ir' 10)
                   (fn _ : {} =>
                     Basis.bind (IR.read ir)
                      (fn iv =>
                        Basis.bind (IR.read ir')
                         (fn iv' =>
                           Basis.bind (SR.read sr)
                            (fn sv =>
                              Basis.bind (IR.delete ir)
                               (fn _ : {} =>
                                 Basis.bind (IR.delete ir')
                                  (fn _ : {} =>
                                    Basis.bind (SR.delete sr)
                                     (fn _ : {} =>
                                       return
                                        (Basis.tag Basis.null Basis.None
                                          Basis.noStyle Basis.None {} (body {})
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.join (Basis.cdata "      ")
                                              (Basis.join (Top.txt iv)
                                                (Basis.join (Basis.cdata ", ")
                                                  (Basis.join (Top.txt iv')
                                                    (Basis.join
                                                      (Basis.cdata ", ")
                                                      (Basis.join (Top.txt sv)
                                                        (Basis.join
                                                          (Basis.cdata "\n")
                                                          (Basis.cdata "    "))))))))))))))))))))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         return
          (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
            (body {})
            (Basis.join (Basis.cdata "\n")
              (Basis.join (Basis.cdata "  ")
                (Basis.join
                  (Basis.form Basis.None Basis.None
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {Action = mutate, Value = "Do some pointless stuff"}
                      (submit {}) (Basis.cdata [(_ :: _)] [[]] "")))
                  (Basis.cdata "\n")))))
   end
 export Ref
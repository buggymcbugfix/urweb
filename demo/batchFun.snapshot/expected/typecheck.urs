structure BatchFun : sig
                      con colMeta :: (Type * Type) -> Type =
                       (fn $x :: (Type * Type) =>
                         (fn db :: Type =>
                           (fn state :: Type =>
                             {Nam : string, Show : db -> xbody, 
                               Inject : sql_injectable db, 
                               NewState : transaction state, 
                               Widget : state -> xbody, 
                               ReadState : state -> transaction db})) $x.1 $x.2)
                       
                       con colsMeta :: {(Type * Type)} -> Type =
                        (fn cols :: {(Type * Type)} => $(map colMeta cols))
                       
                       val int :
                        string ->
                         (fn $x :: (Type * Type) =>
                           (fn db :: Type =>
                             (fn state :: Type =>
                               {Nam : string, Show : db -> xbody, 
                                 Inject : sql_injectable db, 
                                 NewState : transaction state, 
                                 Widget : state -> xbody, 
                                 ReadState : state -> transaction db})) $x.1
                            $x.2) (int, source string)
                       
                       val float :
                        string ->
                         (fn $x :: (Type * Type) =>
                           (fn db :: Type =>
                             (fn state :: Type =>
                               {Nam : string, Show : db -> xbody, 
                                 Inject : sql_injectable db, 
                                 NewState : transaction state, 
                                 Widget : state -> xbody, 
                                 ReadState : state -> transaction db})) $x.1
                            $x.2) (float, source string)
                       
                       val string :
                        string ->
                         (fn $x :: (Type * Type) =>
                           (fn db :: Type =>
                             (fn state :: Type =>
                               {Nam : string, Show : db -> xbody, 
                                 Inject : sql_injectable db, 
                                 NewState : transaction state, 
                                 Widget : state -> xbody, 
                                 ReadState : state -> transaction db})) $x.1
                            $x.2) (string, source string)
                       
                       structure Make :
                        functor (M :
                         sig
                          con cols :: {(Type * Type)}
                           constraint [Id = ()] ~ cols
                           val fl : folder[[(Type * Type)]] cols
                           con tab_hidden_constraints :: {{Unit}}
                           constraint ([]) ++ [] ~ tab_hidden_constraints
                           
                           val tab :
                            sql_table
                             (([Id = int]) ++ map fst[[Type]][[Type]] cols)
                             (([]) ++ ([]) ++ tab_hidden_constraints)
                           val title : string
                           
                           val cols :
                            (fn cols :: {(Type * Type)} => $(map colMeta cols))
                             cols
                          end) :
                         sig
                          val main :
                           unit -> transaction (xml ([Html = ()]) ([]) ([]))
                          end
                      end
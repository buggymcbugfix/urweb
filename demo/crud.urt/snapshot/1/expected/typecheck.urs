structure Crud : sig
                  con colMeta :: (Type * Type) -> Type =
                   (fn $x :: (Type * Type) =>
                     (fn db :: Type =>
                       (fn widget :: Type =>
                         {Name : string, Show : db -> xbody, 
                           Widget : nm :: Name -> xml form ([]) ([nm = widget]),
                                                                               
                           WidgetPopulated :
                            nm :: Name -> db -> xml form ([]) ([nm = widget]), 
                           Parse : widget -> db, Inject : sql_injectable db}))
                      $x.1 $x.2)
                   
                   con colsMeta :: {(Type * Type)} -> Type =
                    (fn cols :: {(Type * Type)} => $(map colMeta cols))
                   
                   val int :
                    string ->
                     (fn $x :: (Type * Type) =>
                       (fn db :: Type =>
                         (fn widget :: Type =>
                           {Name : string, Show : db -> xbody, 
                             Widget :
                              nm :: Name -> xml form ([]) ([nm = widget]), 
                             WidgetPopulated :
                              nm :: Name -> db -> xml form ([]) ([nm = widget]),
                                                                               
                             Parse : widget -> db, Inject : sql_injectable db}))
                        $x.1 $x.2) (int, string)
                   
                   val float :
                    string ->
                     (fn $x :: (Type * Type) =>
                       (fn db :: Type =>
                         (fn widget :: Type =>
                           {Name : string, Show : db -> xbody, 
                             Widget :
                              nm :: Name -> xml form ([]) ([nm = widget]), 
                             WidgetPopulated :
                              nm :: Name -> db -> xml form ([]) ([nm = widget]),
                                                                               
                             Parse : widget -> db, Inject : sql_injectable db}))
                        $x.1 $x.2) (float, string)
                   
                   val string :
                    string ->
                     (fn $x :: (Type * Type) =>
                       (fn db :: Type =>
                         (fn widget :: Type =>
                           {Name : string, Show : db -> xbody, 
                             Widget :
                              nm :: Name -> xml form ([]) ([nm = widget]), 
                             WidgetPopulated :
                              nm :: Name -> db -> xml form ([]) ([nm = widget]),
                                                                               
                             Parse : widget -> db, Inject : sql_injectable db}))
                        $x.1 $x.2) (string, string)
                   
                   val bool :
                    string ->
                     (fn $x :: (Type * Type) =>
                       (fn db :: Type =>
                         (fn widget :: Type =>
                           {Name : string, Show : db -> xbody, 
                             Widget :
                              nm :: Name -> xml form ([]) ([nm = widget]), 
                             WidgetPopulated :
                              nm :: Name -> db -> xml form ([]) ([nm = widget]),
                                                                               
                             Parse : widget -> db, Inject : sql_injectable db}))
                        $x.1 $x.2) (bool, bool)
                   
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
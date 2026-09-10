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
 
 structure Crud1 : sig
                    val t1 :
                     sql_table
                      ([Id = int, A = int, B = string, C = float, D = bool])
                      (([Pkey = ([Id = ()]) ++ map (fn _ :: Type => ()) ([])])
                        ++ [])
                     
                     structure anon :
                      sig
                       structure M :
                        sig
                         con cols :: {(Type * Type)} =
                          [A = (int, string), B = (string, string), 
                            C = (float, string), D = (bool, bool)]
                          
                          con tab_hidden_constraints :: {{Unit}} =
                           [Pkey = [Id = ()]]
                          
                          val fl :
                           folder[[(Type * Type)]]
                            ([A = (int, string), B = (string, string), 
                               C = (float, string), D = (bool, bool)])
                          constraint ([]) ++ [] ~ tab_hidden_constraints
                          constraint [Id = ()] ~ cols
                          
                          val tab :
                           sql_table
                            ([Id = int, A = int, B = string, C = float, 
                               D = bool]) ([Pkey = [Id = ()]])
                          val title : string
                          
                          val cols :
                           {A :
                             {Name : string, Show : (int, string).1 -> xbody, 
                               Widget :
                                nm :: Name ->
                                 xml form ([]) ([nm = (int, string).2]), 
                               WidgetPopulated :
                                nm :: Name ->
                                 (int, string).1 ->
                                  xml form ([]) ([nm = (int, string).2]), 
                               Parse : (int, string).2 -> (int, string).1, 
                               Inject : sql_injectable (int, string).1}, 
                             B :
                              {Name : string, 
                                Show : (string, string).1 -> xbody, 
                                Widget :
                                 nm :: Name ->
                                  xml form ([]) ([nm = (string, string).2]), 
                                WidgetPopulated :
                                 nm :: Name ->
                                  (string, string).1 ->
                                   xml form ([]) ([nm = (string, string).2]), 
                                Parse :
                                 (string, string).2 -> (string, string).1, 
                                Inject : sql_injectable (string, string).1}, 
                             C :
                              {Name : string, 
                                Show : (float, string).1 -> xbody, 
                                Widget :
                                 nm :: Name ->
                                  xml form ([]) ([nm = (float, string).2]), 
                                WidgetPopulated :
                                 nm :: Name ->
                                  (float, string).1 ->
                                   xml form ([]) ([nm = (float, string).2]), 
                                Parse : (float, string).2 -> (float, string).1, 
                                Inject : sql_injectable (float, string).1}, 
                             D :
                              {Name : string, Show : (bool, bool).1 -> xbody, 
                                Widget :
                                 nm :: Name ->
                                  xml form ([]) ([nm = (bool, bool).2]), 
                                WidgetPopulated :
                                 nm :: Name ->
                                  (bool, bool).1 ->
                                   xml form ([]) ([nm = (bool, bool).2]), 
                                Parse : (bool, bool).2 -> (bool, bool).1, 
                                Inject : sql_injectable (bool, bool).1}}
                         end
                        
                        val main :
                         unit -> transaction (xml ([Html = ()]) ([]) ([]))
                       end
                     
                     structure M :
                      sig
                       con cols :: {(Type * Type)} =
                        [A = (int, string), B = (string, string), 
                          C = (float, string), D = (bool, bool)]
                        
                        con tab_hidden_constraints :: {{Unit}} =
                         [Pkey = [Id = ()]]
                        
                        val fl :
                         folder[[(Type * Type)]]
                          ([A = (int, string), B = (string, string), 
                             C = (float, string), D = (bool, bool)])
                        constraint ([]) ++ [] ~ tab_hidden_constraints
                        constraint [Id = ()] ~ cols
                        
                        val tab :
                         sql_table
                          ([Id = int, A = int, B = string, C = float, D = bool])
                          ([Pkey = [Id = ()]])
                        val title : string
                        
                        val cols :
                         {A :
                           {Name : string, Show : (int, string).1 -> xbody, 
                             Widget :
                              nm :: Name ->
                               xml form ([]) ([nm = (int, string).2]), 
                             WidgetPopulated :
                              nm :: Name ->
                               (int, string).1 ->
                                xml form ([]) ([nm = (int, string).2]), 
                             Parse : (int, string).2 -> (int, string).1, 
                             Inject : sql_injectable (int, string).1}, 
                           B :
                            {Name : string, Show : (string, string).1 -> xbody, 
                              Widget :
                               nm :: Name ->
                                xml form ([]) ([nm = (string, string).2]), 
                              WidgetPopulated :
                               nm :: Name ->
                                (string, string).1 ->
                                 xml form ([]) ([nm = (string, string).2]), 
                              Parse : (string, string).2 -> (string, string).1, 
                              Inject : sql_injectable (string, string).1}, 
                           C :
                            {Name : string, Show : (float, string).1 -> xbody, 
                              Widget :
                               nm :: Name ->
                                xml form ([]) ([nm = (float, string).2]), 
                              WidgetPopulated :
                               nm :: Name ->
                                (float, string).1 ->
                                 xml form ([]) ([nm = (float, string).2]), 
                              Parse : (float, string).2 -> (float, string).1, 
                              Inject : sql_injectable (float, string).1}, 
                           D :
                            {Name : string, Show : (bool, bool).1 -> xbody, 
                              Widget :
                               nm :: Name ->
                                xml form ([]) ([nm = (bool, bool).2]), 
                              WidgetPopulated :
                               nm :: Name ->
                                (bool, bool).1 ->
                                 xml form ([]) ([nm = (bool, bool).2]), 
                              Parse : (bool, bool).2 -> (bool, bool).1, 
                              Inject : sql_injectable (bool, bool).1}}
                       end
                     
                     val main :
                      unit -> transaction (xml ([Html = ()]) ([]) ([]))
                    end
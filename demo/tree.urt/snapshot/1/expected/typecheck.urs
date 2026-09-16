structure TreeFun : sig
                     structure Make :
                      functor (M :
                       sig
                        con key :: Type
                         con id :: Name
                         con parent :: Name
                         con cols :: {Type}
                         constraint [id = ()] ~ [parent = ()]
                         constraint [id = (), parent = ()] ~ cols
                         val key_inj : sql_injectable_prim key
                         con tab_hidden_constraints :: {{Unit}}
                         constraint ([]) ++ [] ~ tab_hidden_constraints
                         
                         val tab :
                          sql_table (([id = key, parent = option key]) ++ cols)
                           (([]) ++ ([]) ++ tab_hidden_constraints)
                        end) :
                       sig
                        con id :: Name = M.id
                         con parent :: Name = M.parent
                         
                         val tree :
                          ($(([id = M.key, parent = option M.key]) ++ M.cols)
                            -> xbody) ->
                           (option M.key) ->
                            transaction
                             (xml ([Dyn = (), MakeForm = (), Body = ()]) ([])
                               ([]))
                        end
                     end
 
 structure Tree : sig
                   val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                   end
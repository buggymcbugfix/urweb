structure RefFun : sig
                    structure Make :
                     functor (M :
                      sig
                       con data :: Type
                        val inj : sql_injectable data
                       end) :
                      sig
                       con ref :: Type
                        val new : M.data -> transaction ref
                        val read : ref -> transaction M.data
                        val write : ref -> M.data -> transaction {}
                        val delete : ref -> transaction {}
                       end
                    end
 
 structure Ref : sig
                  val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                  end
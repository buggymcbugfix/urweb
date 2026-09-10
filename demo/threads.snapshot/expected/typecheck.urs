structure Buffer : sig
                    con t :: Type
                     val create : transaction t
                     
                     val render :
                      t ->
                       signal
                        (xml ([Dyn = (), MakeForm = (), Body = ()]) ([]) ([]))
                     val write : t -> string -> transaction {}
                    end
 
 structure Threads : sig
                      val main :
                       unit -> transaction (xml ([Html = ()]) ([]) ([]))
                      end
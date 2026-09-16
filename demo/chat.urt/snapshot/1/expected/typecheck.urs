structure Broadcast : sig
                       structure Make :
                        functor (M : sig
                                      con t :: Type
                                      end) :
                         sig
                          con topic :: Type
                           val inj : sql_injectable topic
                           val create : transaction topic
                           val subscribe : topic -> transaction (channel M.t)
                           val send : topic -> M.t -> transaction {}
                           val subscribers : topic -> transaction int
                          end
                       end
 
 structure Buffer : sig
                     con t :: Type
                      val create : transaction t
                      
                      val render :
                       t ->
                        signal
                         (xml ([Dyn = (), MakeForm = (), Body = ()]) ([]) ([]))
                      val write : t -> string -> transaction {}
                     end
 
 structure Chat : sig
                   val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                   end
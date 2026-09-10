structure List : sig
                  datatype list t = Nil | Cons of t * (list t)
                   val length : t ::: Type -> (list t) -> int
                   val rev : t ::: Type -> (list t) -> list t
                  end
 
 structure ListFun : sig
                      structure Make :
                       functor (M :
                        sig
                         con t :: Type
                          val toString : t -> string
                          val fromString : string -> option t
                         end) :
                        sig
                         val main :
                          unit -> transaction (xml ([Html = ()]) ([]) ([]))
                         end
                      end
 
 structure ListShop : sig
                       val main :
                        unit -> transaction (xml ([Html = ()]) ([]) ([]))
                       end
structure WellTyped : sig
                       val twice : a ::: Type -> (a -> a) -> a -> a
                        
                        val main :
                         {} -> transaction (xml ([Html = ()]) ([]) ([]))
                       end
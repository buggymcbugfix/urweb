structure Cookie : sig
                    val main :
                     unit -> transaction (xml ([Html = ()]) ([]) ([]))
                    end
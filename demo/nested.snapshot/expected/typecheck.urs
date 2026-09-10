structure Nested : sig
                    val main :
                     unit -> transaction (xml ([Html = ()]) ([]) ([]))
                    end
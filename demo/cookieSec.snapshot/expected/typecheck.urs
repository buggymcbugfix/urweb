structure CookieSec : sig
                       val main :
                        unit -> transaction (xml ([Html = ()]) ([]) ([]))
                       end
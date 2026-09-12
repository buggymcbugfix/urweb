structure Css : sig
                 val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                 end
structure React : sig
                   val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                   end
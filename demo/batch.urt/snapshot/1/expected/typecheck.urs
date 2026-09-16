structure Batch : sig
                   val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                   end
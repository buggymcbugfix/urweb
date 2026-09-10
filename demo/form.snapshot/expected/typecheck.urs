structure Form : sig
                  val main : unit -> transaction (xml ([Html = ()]) ([]) ([]))
                  end
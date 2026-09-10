structure ListEdit : sig
                      val main :
                       unit -> transaction (xml ([Html = ()]) ([]) ([]))
                      end
structure Metaform : sig
                      structure Make :
                       functor (M :
                        sig
                         con fs :: {Unit}
                          val fl : folder[[Unit]] fs
                          val names : $(mapU[[Type]] string fs)
                         end) :
                        sig
                         val main :
                          unit -> transaction (xml ([Html = ()]) ([]) ([]))
                         end
                      end
 
 structure Metaform2 : sig
                        val main :
                         unit -> transaction (xml ([Html = ()]) ([]) ([]))
                        end
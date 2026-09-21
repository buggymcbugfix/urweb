structure LibList : sig
                     val show_list : t ::: Type -> (show t) -> show (list t)
                      
                      val show_pair :
                       a ::: Type ->
                        b ::: Type -> (show a) -> (show b) -> show (a * b)
                      val ints : list int
                      val nested : list (list int)
                      val assoc : list (string * int)
                      val a : list int
                      val b : list int
                      val b' : list int
                      val c : bool
                      val d : option int
                      val e : list (string * int)
                      val f : list (string * int)
                      val g : list int
                      val main : transaction (xml ([Html = ()]) ([]) ([]))
                     end
structure List :
 sig
  datatype list t = Nil | Cons of {1 : t, 2 : list t}
   val length : t ::: Type -> (list t) -> int
   val rev : t ::: Type -> (list t) -> list t
  end =
 struct
  datatype list t = Nil | Cons of {1 : t, 2 : list t}
   
   val rec
    length : t ::: _ -> (list t) -> (_ :: Type) =
     fn t ::: _ =>
      fn ls : list t =>
       let
        val rec
         length' : (list t) -> int -> (_ :: Type) =
          fn ls : list t =>
           fn acc : int =>
            case ls of
             Nil => acc | 
              Cons {1 = _, 2 = ls'} => length' ls' (Basis.plus acc 1)
        in
        length' ls 0
        end
   
   val rec
    rev : t ::: _ -> (list t) -> (_ :: Type) =
     fn t ::: _ =>
      fn ls : list t =>
       let
        val rec
         rev' : (list t) -> (list t) -> (_ :: Type) =
          fn ls : list t =>
           fn acc : list t =>
            case ls of
             Nil => acc | 
              Cons {1 = x, 2 = ls'} => rev' ls' (Cons {1 = x, 2 = acc})
        in
        rev' ls Nil
        end
  end
 
 structure ListFun :
  sig
   structure Make :
    functor (M
     :sig
       con t :: Type
        val toString : t -> string
        val fromString : string -> option t
       end) : sig
               val main : unit -> transaction page
               end
   end =
  struct
   open List
    
    structure Make =
     functor (M
      :sig
        con t :: Type
         val toString : t -> string
         val fromString : string -> option t
        end) =>
      struct
       val rec
        toXml : (list M.t) -> (_ :: Type) =
         fn ls : list M.t =>
          case ls of
           Nil => Basis.cdata "[]" | 
            Cons {1 = x, 2 = ls'} =>
             Basis.join (Top.txt (M.toString x))
              (Basis.join (Basis.cdata " :: ") (toXml ls'))
        
        val rec
         console : (list M.t) -> (_ :: Type) =
          fn ls : list M.t =>
           let
            val rec
             cons : {X : string} -> (_ :: Type) =
              fn r : {X : string} =>
               case M.fromString r.#X of
                None =>
                 return
                  (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                    (body {}) (Basis.cdata "Invalid string!")) | 
                 Some v => console (Cons {1 = v, 2 = ls})
            in
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "              Current list: ")
                   (Basis.join (toXml ls)
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {} (br {}) (Basis.cdata ""))
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join
                           (Basis.cdata "              Reversed list: ")
                           (Basis.join (toXml (rev ls))
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {} (br {}) (Basis.cdata ""))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join
                                   (Basis.cdata "              Length: ")
                                   (Basis.join (Top.txt (length ls))
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (br {})
                                         (Basis.cdata ""))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join
                                           (Basis.cdata "              ")
                                           (Basis.join
                                             (Basis.tag Basis.null Basis.None
                                               Basis.noStyle Basis.None {}
                                               (br {}) (Basis.cdata ""))
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.join (Basis.cdata "\n")
                                                 (Basis.join
                                                   (Basis.cdata
                                                     "              ")
                                                   (Basis.join
                                                     (Basis.form Basis.None
                                                       Basis.None
                                                       (Basis.join
                                                         (Basis.cdata "\n")
                                                         (Basis.join
                                                           (Basis.cdata
                                                             "                Add element: ")
                                                           (Basis.join
                                                             (Basis.tag
                                                               Basis.null
                                                               Basis.None
                                                               Basis.noStyle
                                                               Basis.None {}
                                                               (textbox [#X] {})
                                                               (Basis.cdata ""))
                                                             (Basis.join
                                                               (Basis.cdata " ")
                                                               (Basis.join
                                                                 (Basis.tag
                                                                   Basis.null
                                                                   Basis.None
                                                                   Basis.
                                                                    noStyle
                                                                   Basis.None
                                                                   {Action =
                                                                     cons}
                                                                   (submit {})
                                                                   (Basis.cdata
                                                                     [(_ :: _)]
                                                                     [[]] ""))
                                                                 (Basis.join
                                                                   (Basis.cdata
                                                                     "\n")
                                                                   (Basis.cdata
                                                                     "              "))))))))
                                                     (Basis.join
                                                       (Basis.cdata "\n")
                                                       (Basis.cdata
                                                         "            "))))))))))))))))))))))
            end
        
        val rec
         main : (_ :: Type) -> (_ :: Type) =
          fn $x : (_ :: Type) => case $x of {} => console Nil
       end
   end
 
 structure ListShop : sig
                       val main : unit -> transaction page
                       end =
  struct
   structure I =
    struct
     con t :: _ = int
      val toString = show
      val fromString = read
     end
    
    structure S =
     struct
      con t :: _ = string
       val toString = show
       val fromString = read
      end
    structure IL = ListFun.Make(I)
    structure SL = ListFun.Make(S)
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         return
          (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
            (body {})
            (Basis.join (Basis.cdata "\n")
              (Basis.join (Basis.cdata "  Pick your poison:")
                (Basis.join
                  (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                    (br {}) (Basis.cdata ""))
                  (Basis.join (Basis.cdata "\n")
                    (Basis.join (Basis.cdata "  ")
                      (Basis.join
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (ul {})
                          (Basis.join (Basis.cdata "\n")
                            (Basis.join (Basis.cdata "      ")
                              (Basis.join
                                (Basis.tag Basis.null Basis.None Basis.noStyle
                                  Basis.None {} (li {})
                                  (Basis.join (Basis.cdata " ")
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None
                                      {Link = IL.main {}} (a {})
                                      (Basis.cdata "Integers"))))
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join (Basis.cdata "      ")
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None {} (li {})
                                        (Basis.join (Basis.cdata " ")
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None
                                            {Link = SL.main {}} (a {})
                                            (Basis.cdata "Strings"))))
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.cdata "  ")))))))))
                        (Basis.cdata "\n"))))))))
   end
 export ListShop
structure ListEdit : sig
                      val main : unit -> transaction page
                      end =
 struct
  datatype
   rlist =
    Nil | 
     Cons of
      {Data : source string, NewData : source string, Tail : source rlist}
   
   val rec
    showString : (_ :: Type) -> (_ :: Type) =
     fn ss => Basis.bind (signal ss) (fn s => return (Top.txt s))
   
   val rec
    show : (_ :: Type) -> (_ :: Type) =
     fn rls => Basis.bind (signal rls) (fn v => show' v)
                                                         and 
     show' : (_ :: Type) -> (_ :: Type) =
      fn rl =>
       case rl of
        Nil => return (Basis.cdata "") | 
         Cons {Data = ss, NewData = ss', Tail = rls} =>
          return
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "        ")
               (Basis.join
                 (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                   {Signal = showString ss} (dyn {})
                   (Basis.cdata [(_ :: _)] [[]] ""))
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "        ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None
                         {Value = "Change to:", 
                           Onclick =
                            fn _ => Basis.bind (get ss') (fn s => set ss s)}
                         (button {}) (Basis.cdata ""))
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "        ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {Source = ss'} (ctextbox {})
                               (Basis.cdata ""))
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {} (br {}) (Basis.cdata ""))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "        ")
                                   (Basis.join
                                     (Basis.tag Basis.null Basis.None
                                       Basis.noStyle Basis.None
                                       {Signal = show rls} (dyn {})
                                       (Basis.cdata [(_ :: _)] [[]] ""))
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.cdata "      ")))))))))))))))
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        Basis.bind (source Nil)
         (fn head =>
           Basis.bind (source head)
            (fn tailP =>
              Basis.bind (source "")
               (fn data =>
                 let
                  val rec
                   add : (_ :: Type) -> (_ :: Type) =
                    fn $x : (_ :: Type) =>
                     case $x of
                      {} =>
                       Basis.bind (get data)
                        (fn data =>
                          Basis.bind (source data)
                           (fn data =>
                             Basis.bind (source "")
                              (fn ndata =>
                                Basis.bind (get tailP)
                                 (fn tail =>
                                   Basis.bind (source Nil)
                                    (fn tail' =>
                                      let
                                       val cons =
                                        Cons
                                         {Data = data, NewData = ndata, 
                                           Tail = tail'}
                                       in
                                       Basis.bind (set tail cons)
                                        (fn _ : {} => set tailP tail')
                                       end)))))
                  in
                  return
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (body {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "          ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {Source = data} (ctextbox {})
                             (Basis.cdata ""))
                           (Basis.join (Basis.cdata " ")
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None
                                 {Value = "Add", Onclick = fn _ => add {}}
                                 (button {}) (Basis.cdata ""))
                               (Basis.join
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {} (br {}) (Basis.cdata ""))
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join (Basis.cdata "          ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (br {})
                                         (Basis.cdata ""))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join (Basis.cdata "\n")
                                           (Basis.join
                                             (Basis.cdata "          ")
                                             (Basis.join
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None
                                                 {Signal = show head} (dyn {})
                                                 (Basis.cdata [(_ :: _)] [[]]
                                                   ""))
                                               (Basis.join (Basis.cdata "\n")
                                                 (Basis.cdata "        "))))))))))))))))
                  end)))
  end
 export ListEdit
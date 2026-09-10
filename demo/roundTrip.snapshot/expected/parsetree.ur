database dbname=test
 
 structure Buffer :
  sig
   con t :: Type
    val create : transaction t
    val render : t -> signal xbody
    val write : t -> string -> transaction unit
   end =
  struct
   datatype lines = End | Line of {1 : string, 2 : source lines}
    con t :: _ = {Head : source lines, Tail : source (source lines)}
    
    val create =
     Basis.bind (source End)
      (fn head =>
        Basis.bind (source head) (fn tail => return {Head = head, Tail = tail}))
    
    val rec
     renderL : (_ :: Type) -> (_ :: Type) =
      fn lines =>
       case lines of
        End => Basis.cdata "" | 
         Line {1 = line, 2 = linesS} =>
          Basis.join (Top.txt line)
           (Basis.join
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (br {}) (Basis.cdata ""))
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
               {Signal = renderS linesS} (dyn {})
               (Basis.cdata [(_ :: _)] [[]] "")))
                                                  and 
      renderS : (_ :: Type) -> (_ :: Type) =
       fn linesS =>
        Basis.bind (signal linesS) (fn lines => return (renderL lines))
    val rec render : (_ :: Type) -> (_ :: Type) = fn t => renderS t.#Head
    
    val rec
     write : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
      fn t =>
       fn s =>
        Basis.bind (get t.#Tail)
         (fn oldTail =>
           Basis.bind (source End)
            (fn newTail =>
              Basis.bind (set oldTail (Line {1 = s, 2 = newTail}))
               (fn _ : {} => set t.#Tail newTail)))
   end
 
 structure RoundTrip : sig
                        val main : unit -> transaction page
                        end =
  struct
   table channels :
    [#Client = client, #Channel = channel {1 : string, 2 : int, 3 : float}]
    keys Basis.primary_key [#Client] [[]] ! ! {Client = _} constraints
    Basis.no_constraint
    
    val rec
     writeBack : (_ :: Type) -> (_ :: Type) =
      fn v =>
       Basis.bind self
        (fn me =>
          Basis.bind
           (oneRow
             (Basis.sql_query
               {Rows =
                 Basis.sql_query1 [[]]
                  {Distinct = Basis.False, 
                    From = Basis.sql_from_table [#Channels] channels, 
                    Where =
                     Basis.sql_binary Basis.sql_eq
                      (Basis.sql_field [#Channels] [#Client])
                      (Basis.sql_inject me), 
                    GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                    Having = Basis.sql_inject Basis.True, 
                    SelectFields =
                     Basis.sql_subset
                      [[#Channels = ([#Channel = (_ :: Type)], (_ :: {Type}))]],
                                                                               
                    SelectExps = {}}, 
                 OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                 Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}))
           (fn r => send r.#Channels.#Channel v))
    
    val rec
     action : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind self
          (fn me =>
            Basis.bind channel
             (fn ch =>
               Basis.bind
                (dml
                  (Basis.insert channels
                    {Client = Basis.sql_inject me, 
                      Channel = Basis.sql_inject ch}))
                (fn _ : {} =>
                  Basis.bind Buffer.create
                   (fn buf =>
                     let
                      val rec
                       receiver : (_ :: Type) -> (_ :: Type) =
                        fn $x : (_ :: Type) =>
                         case $x of
                          {} =>
                           Basis.bind (recv ch)
                            (fn v =>
                              Basis.bind
                               (Buffer.write buf
                                 (Basis.strcat "("
                                   (Basis.strcat v.#1
                                     (Basis.strcat ", "
                                       (Basis.strcat (show v.#2)
                                         (Basis.strcat ", "
                                           (Basis.strcat (show v.#3) ")")))))))
                               (fn _ : {} => receiver {}))
                       
                       val rec
                        sender :
                         (_ :: Type) ->
                          (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
                         fn s =>
                          fn n =>
                           fn f =>
                            Basis.bind (sleep 2000)
                             (fn _ : {} =>
                               Basis.bind
                                (rpc (writeBack {1 = s, 2 = n, 3 = f}))
                                (fn _ : {} =>
                                  sender (Basis.strcat s "!") (Basis.plus n 1)
                                   (Basis.plus f 1.23)))
                      in
                      return
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None
                         {Onload =
                           Basis.bind (spawn (receiver {}))
                            (fn _ : {} => sender "" 0 0)} (body {})
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "          ")
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {Signal = Buffer.render buf}
                                 (dyn {}) (Basis.cdata [(_ :: _)] [[]] ""))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.cdata "        "))))))
                      end))))
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         return
          (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
            (body {})
            (Basis.join (Basis.cdata "\n")
              (Basis.join (Basis.cdata "  ")
                (Basis.join
                  (Basis.form Basis.None Basis.None
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {Value = "Begin demo", Action = action} (submit {})
                      (Basis.cdata [(_ :: _)] [[]] ""))) (Basis.cdata "\n")))))
   end
 export RoundTrip
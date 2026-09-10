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
 
 structure Threads : sig
                      val main : unit -> transaction page
                      end =
  struct
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        Basis.bind Buffer.create
         (fn buf =>
           let
            val rec
             loop : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
              fn prefix =>
               fn delay =>
                let
                 val rec
                  loop' : (_ :: Type) -> (_ :: Type) =
                   fn n =>
                    Basis.bind
                     (Buffer.write buf
                       (Basis.strcat prefix
                         (Basis.strcat ": Message #" (show n))))
                     (fn _ : {} =>
                       Basis.bind (sleep delay)
                        (fn _ : {} => loop' (Basis.plus n 1)))
                 in
                 loop'
                 end
            in
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
               {Onload =
                 Basis.bind (spawn (loop "A" 5000 0))
                  (fn _ : {} => spawn (loop "B" 3000 100))} (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "          ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {Signal = Buffer.render buf} (dyn {})
                       (Basis.cdata [(_ :: _)] [[]] ""))
                     (Basis.join (Basis.cdata "\n") (Basis.cdata "        "))))))
            end)
   end
 export Threads
structure React : sig
                   val main : unit -> transaction page
                   end =
 struct
  val rec
   main : (_ :: Type) -> (_ :: Type) =
    fn $x : (_ :: Type) =>
     case $x of
      {} =>
       Basis.bind (source "You didn't click it yet.")
        (fn s =>
          return
           (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
             (body {})
             (Basis.join (Basis.cdata "\n")
               (Basis.join (Basis.cdata "    ")
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                     {Value = "Click me!", 
                       Onclick = fn _ => set s "Now you clicked it."}
                     (button {}) (Basis.cdata ""))
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (br {}) (Basis.cdata ""))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "    ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None
                             {Signal =
                               Basis.bind (signal s)
                                (fn v => return (Top.txt v))} (dyn {})
                             (Basis.cdata [(_ :: _)] [[]] ""))
                           (Basis.join (Basis.cdata "\n") (Basis.cdata "  ")))))))))))
  end
 export React
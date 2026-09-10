database dbname=test
 
 structure Increment : sig
                        val main : unit -> transaction page
                        end =
  struct
   sequence seq
    
    val rec
     increment : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) => case $x of {} => nextval seq
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (source 0)
          (fn src =>
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "      ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {Signal =
                         Basis.bind (signal src) (fn n => return (Top.txt n))}
                       (dyn {}) (Basis.cdata [(_ :: _)] [[]] ""))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "      ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None
                             {Value = "Update", 
                               Onclick =
                                fn _ =>
                                 Basis.bind (rpc (increment {}))
                                  (fn n => set src n)} (button {})
                             (Basis.cdata ""))
                           (Basis.join (Basis.cdata "\n") (Basis.cdata "    "))))))))))
   end
 export Increment
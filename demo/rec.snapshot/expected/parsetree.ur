structure Rec : sig
                 val main : unit -> transaction page
                 end =
 struct
  val rec
   main : (_ :: Type) -> (_ :: Type) =
    fn $x : (_ :: Type) =>
     case $x of
      {} =>
       return
        (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
          (Basis.join (Basis.cdata "\n")
            (Basis.join (Basis.cdata "  ")
              (Basis.join
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                  {Link = other {}} (a {}) (Basis.cdata "Go to the other one!"))
                (Basis.cdata "\n")))))
                                       and 
    other : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
           (Basis.join (Basis.cdata "\n")
             (Basis.join (Basis.cdata "  ")
               (Basis.join
                 (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                   {Link = main {}} (a {})
                   (Basis.join (Basis.cdata "Return to ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {} (tt {}) (Basis.cdata "main"))
                       (Basis.cdata "!")))) (Basis.cdata "\n")))))
  end
 export Rec
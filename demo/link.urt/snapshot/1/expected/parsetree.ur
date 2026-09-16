structure Link : sig
                  val main : unit -> transaction page
                  end =
 struct
  val rec
   target : (_ :: Type) -> (_ :: Type) =
    fn $x : (_ :: Type) =>
     case $x of
      {} =>
       return
        (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
          (Basis.join (Basis.cdata "\n")
            (Basis.join (Basis.cdata "  Welcome!") (Basis.cdata "\n"))))
   
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
                   {Link = target {}} (a {}) (Basis.cdata "Go there"))
                 (Basis.cdata "\n")))))
  end
 export Link
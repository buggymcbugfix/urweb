structure Css : sig
                 val main : unit -> transaction page
                 end =
 struct
  style quote
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        return
         (Basis.join (Basis.cdata "\n")
           (Basis.join (Basis.cdata "  ")
             (Basis.join
               (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                 (head {})
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "    ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None
                         {Rel = "stylesheet", Typ = "text/css", 
                           Href =
                            Basis.bless "http://adam.chlipala.net/style.css"}
                         (link {}) (Basis.cdata ""))
                       (Basis.join (Basis.cdata "\n") (Basis.cdata "  "))))))
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "  ")
                     (Basis.join
                       (Basis.tag Basis.null Basis.None Basis.noStyle
                         Basis.None {} (body {})
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "    ")
                             (Basis.join
                               (Basis.tag quote Basis.None Basis.noStyle
                                 Basis.None {} (div {})
                                 (Basis.cdata "Here's a quote."))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.cdata "  ")))))) (Basis.cdata "\n"))))))))
  end
 export Css
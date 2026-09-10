structure Url : sig
                 val main : unit -> transaction page
                 end =
 struct
  val rec
   yourChoice : (_ :: Type) -> (_ :: Type) =
    fn r =>
     return
      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {} (body {})
        (Basis.join (Basis.cdata "\n")
          (Basis.join (Basis.cdata "  ")
            (Basis.join
              (case checkUrl r.#Url of
                None => Basis.cdata "You aren't allowed to link to there." | 
                 Some url =>
                  Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                   {Href = url} (a {}) (Basis.cdata "Enjoy!"))
              (Basis.cdata "\n")))))
   
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
                   {Href =
                     Basis.bless "http://en.wikipedia.org/wiki/Type_inference"}
                   (a {}) (Basis.cdata "Learn something"))
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (br {}) (Basis.cdata ""))
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "  ")
                       (Basis.join
                         (Basis.tag Basis.null Basis.None Basis.noStyle
                           Basis.None {} (br {}) (Basis.cdata ""))
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "  ")
                             (Basis.join
                               (Basis.form Basis.None Basis.None
                                 (Basis.join (Basis.cdata "\n")
                                   (Basis.join
                                     (Basis.cdata "    URL of your choice: ")
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {}
                                         (textbox [#Url] {}) (Basis.cdata ""))
                                       (Basis.join (Basis.cdata " ")
                                         (Basis.join
                                           (Basis.tag Basis.null Basis.None
                                             Basis.noStyle Basis.None
                                             {Action = yourChoice} (submit {})
                                             (Basis.cdata [(_ :: _)] [[]] ""))
                                           (Basis.join (Basis.cdata "\n")
                                             (Basis.cdata "  "))))))))
                               (Basis.cdata "\n"))))))))))))
  end
 export Url
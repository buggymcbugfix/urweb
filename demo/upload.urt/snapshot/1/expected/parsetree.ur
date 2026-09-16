structure Upload : sig
                    val main : unit -> transaction page
                    end =
 struct
  val rec
   echo : (_ :: Type) -> (_ :: Type) =
    fn r =>
     case Basis.gt (blobSize (fileData r.#File)) 100000 of
      Basis.True => return (Basis.cdata "Whoa!  That one's too big.") | 
       Basis.False =>
        returnBlob (fileData r.#File) (blessMime (fileMimeType r.#File))
   
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
                 (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                   (h1 {}) (Basis.cdata "The Amazing File Echoer!"))
                 (Basis.join (Basis.cdata "\n")
                   (Basis.join (Basis.cdata "\n")
                     (Basis.join (Basis.cdata "  ")
                       (Basis.join
                         (Basis.form Basis.None Basis.None
                           (Basis.join (Basis.cdata "Upload a file: ")
                             (Basis.join
                               (Basis.tag Basis.null Basis.None Basis.noStyle
                                 Basis.None {} (upload [#File] {})
                                 (Basis.cdata ""))
                               (Basis.join (Basis.cdata " ")
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None {Action = echo} (submit {})
                                   (Basis.cdata [(_ :: _)] [[]] ""))))))
                         (Basis.cdata "\n")))))))))
  end
 export Upload
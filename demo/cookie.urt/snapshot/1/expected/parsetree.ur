structure Cookie : sig
                    val main : unit -> transaction page
                    end =
 struct
  cookie c : {A : string, B : float, C : int}
   
   val rec
    set : (_ :: Type) -> (_ :: Type) =
     fn r =>
      Basis.bind
       (setCookie c
         {Value = {A = r.#A, B = readError r.#B, C = readError r.#C}, 
           Expires = None, Secure = False, HttpOnly = True})
       (fn _ : {} => return (Basis.cdata "Cookie set."))
   
   val rec
    setExp : (_ :: Type) -> (_ :: Type) =
     fn r =>
      Basis.bind
       (setCookie c
         {Value = {A = r.#A, B = readError r.#B, C = readError r.#C}, 
           Expires = Some (readError "2012-11-6 00:00:00"), Secure = False, 
           HttpOnly = True})
       (fn _ : {} => return (Basis.cdata "Cookie set robustly."))
   
   val rec
    delete : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        Basis.bind (clearCookie c)
         (fn _ : {} => return (Basis.cdata "Cookie cleared."))
   
   val rec
    main : (_ :: Type) -> (_ :: Type) =
     fn $x : (_ :: Type) =>
      case $x of
       {} =>
        Basis.bind (getCookie c)
         (fn ro =>
           return
            (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
              (body {})
              (Basis.join (Basis.cdata "\n")
                (Basis.join (Basis.cdata "      ")
                  (Basis.join
                    (case ro of
                      None => Basis.cdata "No cookie set." | 
                       Some v =>
                        Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "           Cookie: A = ")
                           (Basis.join (Top.txt v.#A)
                             (Basis.join (Basis.cdata ", B = ")
                               (Basis.join (Top.txt v.#B)
                                 (Basis.join (Basis.cdata ", C = ")
                                   (Basis.join (Top.txt v.#C)
                                     (Basis.join
                                       (Basis.tag Basis.null Basis.None
                                         Basis.noStyle Basis.None {} (br {})
                                         (Basis.cdata ""))
                                       (Basis.join (Basis.cdata "\n")
                                         (Basis.join
                                           (Basis.cdata "           ")
                                           (Basis.join
                                             (Basis.form Basis.None Basis.None
                                               (Basis.tag Basis.null Basis.None
                                                 Basis.noStyle Basis.None
                                                 {Value = "Delete", 
                                                   Action = delete} (submit {})
                                                 (Basis.cdata [(_ :: _)] [[]]
                                                   "")))
                                             (Basis.join (Basis.cdata "\n")
                                               (Basis.cdata "         ")))))))))))))
                    (Basis.join (Basis.cdata "\n")
                      (Basis.join (Basis.cdata "      ")
                        (Basis.join
                          (Basis.tag Basis.null Basis.None Basis.noStyle
                            Basis.None {} (br {}) (Basis.cdata ""))
                          (Basis.join
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None {} (br {}) (Basis.cdata ""))
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "      ")
                                  (Basis.join
                                    (Basis.form Basis.None Basis.None
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join (Basis.cdata "        A: ")
                                          (Basis.join
                                            (Basis.tag Basis.null Basis.None
                                              Basis.noStyle Basis.None {}
                                              (textbox [#A] {})
                                              (Basis.cdata ""))
                                            (Basis.join
                                              (Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None {}
                                                (br {}) (Basis.cdata ""))
                                              (Basis.join (Basis.cdata "\n")
                                                (Basis.join
                                                  (Basis.cdata "        B: ")
                                                  (Basis.join
                                                    (Basis.tag Basis.null
                                                      Basis.None Basis.noStyle
                                                      Basis.None {}
                                                      (textbox [#B] {})
                                                      (Basis.cdata ""))
                                                    (Basis.join
                                                      (Basis.tag Basis.null
                                                        Basis.None
                                                        Basis.noStyle
                                                        Basis.None {} (br {})
                                                        (Basis.cdata ""))
                                                      (Basis.join
                                                        (Basis.cdata "\n")
                                                        (Basis.join
                                                          (Basis.cdata
                                                            "        C: ")
                                                          (Basis.join
                                                            (Basis.tag
                                                              Basis.null
                                                              Basis.None
                                                              Basis.noStyle
                                                              Basis.None {}
                                                              (textbox [#C] {})
                                                              (Basis.cdata ""))
                                                            (Basis.join
                                                              (Basis.tag
                                                                Basis.null
                                                                Basis.None
                                                                Basis.noStyle
                                                                Basis.None {}
                                                                (br {})
                                                                (Basis.cdata ""))
                                                              (Basis.join
                                                                (Basis.cdata
                                                                  "\n")
                                                                (Basis.join
                                                                  (Basis.cdata
                                                                    "        ")
                                                                  (Basis.join
                                                                    (Basis.tag
                                                                      Basis.
                                                                       null
                                                                      Basis.
                                                                       None
                                                                      Basis.
                                                                       noStyle
                                                                      Basis.
                                                                       None
                                                                      {Action =
                                                                        set}
                                                                      (submit
                                                                        {})
                                                                      (Basis.
                                                                        cdata
                                                                        [(_ ::
                                                                          _)]
                                                                        [[]] ""))
                                                                    (Basis.join
                                                                      (Basis.
                                                                        cdata
                                                                        "\n")
                                                                      (Basis.
                                                                        cdata
                                                                        "      "))))))))))))))))))
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None {} (br {})
                                        (Basis.cdata ""))
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join (Basis.cdata "\n")
                                          (Basis.join (Basis.cdata "      ")
                                            (Basis.join
                                              (Basis.form Basis.None Basis.None
                                                (Basis.join (Basis.cdata "\n")
                                                  (Basis.join
                                                    (Basis.cdata "        ")
                                                    (Basis.join
                                                      (Basis.tag Basis.null
                                                        Basis.None
                                                        Basis.noStyle
                                                        Basis.None {} (b {})
                                                        (Basis.cdata
                                                          "Version that expires on November 6, 2012:"))
                                                      (Basis.join
                                                        (Basis.tag Basis.null
                                                          Basis.None
                                                          Basis.noStyle
                                                          Basis.None {} (br {})
                                                          (Basis.cdata ""))
                                                        (Basis.join
                                                          (Basis.cdata "\n")
                                                          (Basis.join
                                                            (Basis.cdata
                                                              "        A: ")
                                                            (Basis.join
                                                              (Basis.tag
                                                                Basis.null
                                                                Basis.None
                                                                Basis.noStyle
                                                                Basis.None {}
                                                                (textbox [#A]
                                                                  {})
                                                                (Basis.cdata ""))
                                                              (Basis.join
                                                                (Basis.tag
                                                                  Basis.null
                                                                  Basis.None
                                                                  Basis.noStyle
                                                                  Basis.None {}
                                                                  (br {})
                                                                  (Basis.cdata
                                                                    ""))
                                                                (Basis.join
                                                                  (Basis.cdata
                                                                    "\n")
                                                                  (Basis.join
                                                                    (Basis.
                                                                      cdata
                                                                      "        B: ")
                                                                    (Basis.join
                                                                      (Basis.
                                                                        tag
                                                                        Basis.
                                                                         null
                                                                        Basis.
                                                                         None
                                                                        Basis.
                                                                         noStyle
                                                                        Basis.
                                                                         None
                                                                        {}
                                                                        (textbox
                                                                          [#B]
                                                                          {})
                                                                        (Basis.
                                                                          cdata
                                                                          ""))
                                                                      (Basis.
                                                                        join
                                                                        (Basis.
                                                                          tag
                                                                          Basis.
                                                                           null
                                                                          Basis.
                                                                           None
                                                                          Basis.
                                                                           noStyle
                                                                          Basis.
                                                                           None
                                                                          {}
                                                                          (br
                                                                            {})
                                                                          (Basis.
                                                                            cdata
                                                                            ""))
                                                                        (Basis.
                                                                          join
                                                                          (Basis.
                                                                            cdata
                                                                            "\n")
                                                                          (Basis.
                                                                            join
                                                                            (Basis.
                                                                              cdata
                                                                              "        C: ")
                                                                            (Basis.
                                                                              join
                                                                              (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (textbox
                                                                               [#C]
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               ""))
                                                                              (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {}
                                                                               (br
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               ""))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "\n")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "        ")
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               tag
                                                                               Basis.
                                                                               null
                                                                               Basis.
                                                                               None
                                                                               Basis.
                                                                               noStyle
                                                                               Basis.
                                                                               None
                                                                               {Action
                                                                               =
                                                                               setExp
                                                                               }
                                                                               (submit
                                                                               {})
                                                                               (Basis.
                                                                               cdata
                                                                               [(_
                                                                               ::
                                                                               _)]
                                                                               [[]]
                                                                               ""))
                                                                               (Basis.
                                                                               join
                                                                               (Basis.
                                                                               cdata
                                                                               "\n")
                                                                               (Basis.
                                                                               cdata
                                                                               "      "))))))))))))))))))))))
                                              (Basis.join (Basis.cdata "\n")
                                                (Basis.cdata "    "))))))))))))))))))))
  end
 export Cookie
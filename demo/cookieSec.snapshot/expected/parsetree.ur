database dbname=test
 
 structure CookieSec : sig
                        val main : unit -> transaction page
                        end =
  struct
   cookie username : string
    
    table lastVisit : [#User = string, #When = time] keys
     Basis.primary_key [#User] [[]] ! ! {User = _} constraints
     Basis.no_constraint
    
    val rec
     main : (_ :: Type) -> (_ :: Type) =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind (getCookie username)
          (fn userO =>
            Basis.bind
             (queryX
               (Basis.sql_query
                 {Rows =
                   Basis.sql_query1 [[]]
                    {Distinct = Basis.False, 
                      From = Basis.sql_from_table [#LastVisit] lastVisit, 
                      Where = Basis.sql_inject Basis.True, 
                      GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                      Having = Basis.sql_inject Basis.True, 
                      SelectFields =
                       Basis.sql_subset [[#LastVisit = ((_ :: {Type}), [])]], 
                      SelectExps = {}}, 
                   OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                   Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
               (fn r =>
                 Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (tr {})
                  (Basis.join
                    (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                      {} (td {}) (Top.txt r.#LastVisit.#User))
                    (Basis.join (Basis.cdata " ")
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {} (td {}) (Top.txt r.#LastVisit.#When))))))
             (fn list =>
               return
                (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                  (body {})
                  (Basis.join (Basis.cdata "\n")
                    (Basis.join (Basis.cdata "      Cookie: ")
                      (Basis.join (Top.txt userO)
                        (Basis.join
                          (Basis.tag Basis.null Basis.None Basis.noStyle
                            Basis.None {} (br {}) (Basis.cdata ""))
                          (Basis.join (Basis.cdata "\n")
                            (Basis.join (Basis.cdata "\n")
                              (Basis.join (Basis.cdata "      ")
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (tabl {})
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join (Basis.cdata "        ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None {} (tr {})
                                            (Basis.join
                                              (Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None {}
                                                (th {}) (Basis.cdata "User"))
                                              (Basis.join (Basis.cdata " ")
                                                (Basis.tag Basis.null
                                                  Basis.None Basis.noStyle
                                                  Basis.None {} (th {})
                                                  (Basis.cdata "Last Visit")))))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.join
                                              (Basis.cdata "        ")
                                              (Basis.join list
                                                (Basis.join (Basis.cdata "\n")
                                                  (Basis.cdata "      ")))))))))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join (Basis.cdata "      ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None {} (h2 {})
                                            (Basis.cdata "Set cookie value"))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.join (Basis.cdata "      ")
                                              (Basis.join
                                                (Basis.form Basis.None
                                                  Basis.None
                                                  (Basis.join
                                                    (Basis.tag Basis.null
                                                      Basis.None Basis.noStyle
                                                      Basis.None {}
                                                      (textbox [#User] {})
                                                      (Basis.cdata ""))
                                                    (Basis.join
                                                      (Basis.cdata " ")
                                                      (Basis.tag Basis.null
                                                        Basis.None
                                                        Basis.noStyle
                                                        Basis.None
                                                        {Action = set}
                                                        (submit {})
                                                        (Basis.cdata [(_ :: _)]
                                                          [[]] "")))))
                                                (Basis.join (Basis.cdata "\n")
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.join
                                                      (Basis.cdata "      ")
                                                      (Basis.join
                                                        (Basis.tag Basis.null
                                                          Basis.None
                                                          Basis.noStyle
                                                          Basis.None {} (h2 {})
                                                          (Basis.cdata
                                                            "Record your visit"))
                                                        (Basis.join
                                                          (Basis.cdata "\n")
                                                          (Basis.join
                                                            (Basis.cdata
                                                              "      ")
                                                            (Basis.join
                                                              (Basis.form
                                                                Basis.None
                                                                Basis.None
                                                                (Basis.tag
                                                                  Basis.null
                                                                  Basis.None
                                                                  Basis.noStyle
                                                                  Basis.None
                                                                  {Action =
                                                                    imHere}
                                                                  (submit {})
                                                                  (Basis.cdata
                                                                    [(_ :: _)]
                                                                    [[]] "")))
                                                              (Basis.join
                                                                (Basis.cdata
                                                                  "\n")
                                                                (Basis.cdata
                                                                  "    ")))))))))))))))))))))))))))
      
       and 
      set : (_ :: Type) -> (_ :: Type) =
       fn r =>
        Basis.bind
         (setCookie username
           {Value = r.#User, Expires = None, Secure = False, HttpOnly = True})
         (fn _ : {} => main {})
                                and 
      imHere : (_ :: Type) -> (_ :: Type) =
       fn $x : (_ :: Type) =>
        case $x of
         {} =>
          Basis.bind (getCookie username)
           (fn userO =>
             case userO of
              None => return (Basis.cdata "You don't have a cookie set!") | 
               Some user =>
                Basis.bind
                 (dml
                   (Basis.delete lastVisit
                     (Basis.sql_binary Basis.sql_eq
                       (Basis.sql_field [#T] [#User]) (Basis.sql_inject user))))
                 (fn _ : {} =>
                   Basis.bind
                    (dml
                      (Basis.insert lastVisit
                        {User = Basis.sql_inject user, 
                          When = Basis.sql_nfunc Basis.sql_current_timestamp}))
                    (fn _ : {} => main {})))
   end
 export CookieSec
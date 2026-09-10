database dbname=spawn
 
 structure Spawn =
  struct
   table t : [#A = int, #Ch = channel string] keys Basis.no_primary_key
    constraints Basis.no_constraint
    
    val rec
     listener : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
      fn n =>
       fn ch =>
        Basis.bind (recv ch)
         (fn s =>
           Basis.bind (alert (Basis.strcat (show n) (Basis.strcat ": " s)))
            (fn _ : {} => listener n ch))
    
    val rec
     speak : (_ :: Type) -> (_ :: Type) -> (_ :: Type) =
      fn id =>
       fn msg =>
        Basis.bind
         (oneRow
           (Basis.sql_query
             {Rows =
               Basis.sql_query1 [[]]
                {Distinct = Basis.False, From = Basis.sql_from_table [#T] t, 
                  Where =
                   Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#A])
                    (Basis.sql_inject id), 
                  GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                  Having = Basis.sql_inject Basis.True, 
                  SelectFields =
                   Basis.sql_subset
                    [[#T = ([#Ch = (_ :: Type)], (_ :: {Type}))]], 
                  SelectExps = {}}, 
               OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
               Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}))
         (fn r => send r.#T.#Ch msg)
    
    val rec
     main : (_ :: Type) -> transaction page =
      fn $x : (_ :: Type) =>
       case $x of
        {} =>
         Basis.bind channel
          (fn ch1 =>
            Basis.bind
             (dml
               (Basis.insert t
                 {A = Basis.sql_inject 1, Ch = Basis.sql_inject ch1}))
             (fn _ : {} =>
               Basis.bind channel
                (fn ch2 =>
                  Basis.bind
                   (dml
                     (Basis.insert t
                       {A = Basis.sql_inject 2, Ch = Basis.sql_inject ch2}))
                   (fn _ : {} =>
                     Basis.bind (source "")
                      (fn s1 =>
                        Basis.bind (source "")
                         (fn s2 =>
                           return
                            (Basis.tag Basis.null Basis.None Basis.noStyle
                              Basis.None
                              {Onload =
                                Basis.bind (spawn (listener 1 ch1))
                                 (fn _ : {} => spawn (listener 2 ch2))}
                              (body {})
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "      1: ")
                                  (Basis.join
                                    (Basis.tag Basis.null Basis.None
                                      Basis.noStyle Basis.None {Source = s1}
                                      (ctextbox {}) (Basis.cdata ""))
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None
                                        {Onclick =
                                          Basis.bind (get s1)
                                           (fn msg => speak 1 msg)} (button {})
                                        (Basis.cdata ""))
                                      (Basis.join
                                        (Basis.tag Basis.null Basis.None
                                          Basis.noStyle Basis.None {} (br {})
                                          (Basis.cdata ""))
                                        (Basis.join (Basis.cdata "\n")
                                          (Basis.join (Basis.cdata "      2: ")
                                            (Basis.join
                                              (Basis.tag Basis.null Basis.None
                                                Basis.noStyle Basis.None
                                                {Source = s2} (ctextbox {})
                                                (Basis.cdata ""))
                                              (Basis.join
                                                (Basis.tag Basis.null
                                                  Basis.None Basis.noStyle
                                                  Basis.None
                                                  {Onclick =
                                                    Basis.bind (get s2)
                                                     (fn msg => speak 2 msg)}
                                                  (button {}) (Basis.cdata ""))
                                                (Basis.join (Basis.cdata "\n")
                                                  (Basis.cdata "    "))))))))))))))))))
   end
 export Spawn
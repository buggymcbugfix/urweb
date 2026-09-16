structure Crud :
 sig
  con colMeta :: _ =
   fn $x :: (Type * Type) =>
    fn db :: Type =>
     fn widget :: Type =>
      {Name : string, Show : db -> xbody, 
        Widget : nm :: Name -> xml form [] [nm = widget], 
        WidgetPopulated : nm :: Name -> db -> xml form [] [nm = widget], 
        Parse : widget -> db, Inject : sql_injectable db} $x.1 $x.2
   con colsMeta :: _ = fn cols :: {(Type * Type)} => $(map colMeta cols)
   val int : string -> colMeta (int, string)
   val float : string -> colMeta (float, string)
   val string : string -> colMeta (string, string)
   val bool : string -> colMeta (bool, bool)
   
   structure Make :
    functor (M
     :sig
       con cols :: {(Type * Type)}
        constraint [#Id = ()] ~ cols
        val fl : folder cols
        
        table tab : [#Id = int] ++ map fst cols keys Basis.no_primary_key
         constraints Basis.no_constraint
        val title : string
        val cols : colsMeta cols
       end) : sig
               val main : unit -> transaction page
               end
  end =
 struct
  con colMeta :: _ =
   fn $x :: (Type * Type) =>
    fn db :: Type =>
     fn widget :: Type =>
      {Name : string, Show : db -> xbody, 
        Widget : nm :: Name -> xml form [] [nm = widget], 
        WidgetPopulated : nm :: Name -> db -> xml form [] [nm = widget], 
        Parse : widget -> db, Inject : sql_injectable db} $x.1 $x.2
   con colsMeta :: _ = fn cols => $(map colMeta cols)
   
   val rec
    default :
     t ::: _ ->
      (show t) ->
       (read t) -> (sql_injectable t) -> (_ :: Type) -> colMeta (t, string) =
     fn t ::: _ =>
      fn sh : show t =>
       fn rd : read t =>
        fn inj : sql_injectable t =>
         fn name =>
          {Name = name, Show = txt, 
            Widget =
             fn nm :: Name =>
              Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (textbox [nm] {}) (Basis.cdata ""), 
            WidgetPopulated =
             fn nm :: Name =>
              fn n =>
               Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                {Value = show n} (textbox [nm] {}) (Basis.cdata ""), 
            Parse = readError, Inject = _}
   val int = default
   val float = default
   val string = default
   
   val rec
    bool : (_ :: Type) -> (_ :: Type) =
     fn name =>
      {Name = name, Show = txt, 
        Widget =
         fn nm :: Name =>
          Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
           (checkbox [nm] {}) (Basis.cdata ""), 
        WidgetPopulated =
         fn nm :: Name =>
          fn b =>
           Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
            {Checked = b} (checkbox [nm] {}) (Basis.cdata ""), 
        Parse = fn x => x, Inject = _}
   
   structure Make =
    functor (M
     :sig
       con cols :: {(Type * Type)}
        constraint [#Id = ()] ~ cols
        val fl : folder cols
        
        table tab : [#Id = int] ++ map fst cols keys Basis.no_primary_key
         constraints Basis.no_constraint
        val title : string
        val cols : colsMeta cols
       end) =>
     struct
      val tab = M.tab
       sequence seq
       
       val rec
        list : (_ :: Type) -> (_ :: Type) =
         fn $x : (_ :: Type) =>
          case $x of
           {} =>
            Basis.bind
             (queryX
               (Basis.sql_query
                 {Rows =
                   Basis.sql_query1 [[]]
                    {Distinct = Basis.False, 
                      From = Basis.sql_from_table [#T] tab, 
                      Where = Basis.sql_inject Basis.True, 
                      GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                      Having = Basis.sql_inject Basis.True, 
                      SelectFields =
                       Basis.sql_subset [[#T = ((_ :: {Type}), [])]], 
                      SelectExps = {}}, 
                   OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                   Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset})
               (fn fs : {T : $([#Id = int] ++ map fst M.cols)} =>
                 Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "                         ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {} (tr {})
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join
                            (Basis.cdata "                           ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (td {}) (Top.txt fs.#T.#Id))
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join
                                  (Basis.cdata "                           ")
                                  (Basis.join
                                    (mapX2 [fst] [colMeta] [tr]
                                      (fn nm :: Name =>
                                        fn t :: _ =>
                                         fn rest :: _ =>
                                          [nm = ()] ~ rest =>
                                           fn v =>
                                            fn col =>
                                             Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata
                                                  "                               ")
                                                (Basis.join
                                                  (Basis.tag Basis.null
                                                    Basis.None Basis.noStyle
                                                    Basis.None {} (td {})
                                                    (col.#Show v))
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.cdata
                                                      "                             ")))))
                                      M.fl (fs.#T -- #Id) M.cols)
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join
                                        (Basis.cdata
                                          "                           ")
                                        (Basis.join
                                          (Basis.tag Basis.null Basis.None
                                            Basis.noStyle Basis.None {} (td {})
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata
                                                  "                             ")
                                                (Basis.join
                                                  (Basis.tag Basis.null
                                                    Basis.None Basis.noStyle
                                                    Basis.None
                                                    {Link = upd fs.#T.#Id}
                                                    (a {})
                                                    (Basis.cdata "[Update]"))
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.join
                                                      (Basis.cdata
                                                        "                             ")
                                                      (Basis.join
                                                        (Basis.tag Basis.null
                                                          Basis.None
                                                          Basis.noStyle
                                                          Basis.None
                                                          {Link =
                                                            confirm fs.#T.#Id}
                                                          (a {})
                                                          (Basis.cdata
                                                            "[Delete]"))
                                                        (Basis.join
                                                          (Basis.cdata "\n")
                                                          (Basis.cdata
                                                            "                           ")))))))))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata
                                              "                         "))))))))))))
                      (Basis.join (Basis.cdata "\n")
                        (Basis.cdata "                       "))))))
             (fn rows =>
               return
                (Basis.join (Basis.cdata "\n")
                  (Basis.join (Basis.cdata "          ")
                    (Basis.join
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {Border = 1} (tabl {})
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "            ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (tr {})
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join (Basis.cdata "              ")
                                    (Basis.join
                                      (Basis.tag Basis.null Basis.None
                                        Basis.noStyle Basis.None {} (th {})
                                        (Basis.cdata "ID"))
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.join
                                          (Basis.cdata "              ")
                                          (Basis.join
                                            (mapX [colMeta] [tr]
                                              (fn nm :: Name =>
                                                fn t :: _ =>
                                                 fn rest :: _ =>
                                                  [nm = ()] ~ rest =>
                                                   fn col =>
                                                    Basis.join
                                                     (Basis.cdata "\n")
                                                     (Basis.join
                                                       (Basis.cdata
                                                         "                  ")
                                                       (Basis.join
                                                         (Basis.tag Basis.null
                                                           Basis.None
                                                           Basis.noStyle
                                                           Basis.None {}
                                                           (th {})
                                                           (cdata col.#Name))
                                                         (Basis.join
                                                           (Basis.cdata "\n")
                                                           (Basis.cdata
                                                             "                ")))))
                                              M.fl M.cols)
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.cdata "            ")))))))))
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "            ")
                                  (Basis.join rows
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.cdata "          ")))))))))
                      (Basis.join (Basis.cdata "\n")
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "          ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (br {}) (Basis.cdata ""))
                              (Basis.join
                                (Basis.tag Basis.null Basis.None Basis.noStyle
                                  Basis.None {} (hr {}) (Basis.cdata ""))
                                (Basis.join
                                  (Basis.tag Basis.null Basis.None
                                    Basis.noStyle Basis.None {} (br {})
                                    (Basis.cdata ""))
                                  (Basis.join (Basis.cdata "\n")
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join (Basis.cdata "          ")
                                        (Basis.join
                                          (Basis.form Basis.None Basis.None
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata "            ")
                                                (Basis.join
                                                  (foldR [colMeta]
                                                    [fn cols =>
                                                      xml form []
                                                       (map snd cols)]
                                                    (fn nm :: Name =>
                                                      fn t :: _ =>
                                                       fn rest :: _ =>
                                                        [nm = ()] ~ rest =>
                                                         fn col : colMeta t =>
                                                          fn acc =>
                                                           Basis.join
                                                            (Basis.cdata "\n")
                                                            (Basis.join
                                                              (Basis.cdata
                                                                "                ")
                                                              (Basis.join
                                                                (Basis.tag
                                                                  Basis.null
                                                                  Basis.None
                                                                  Basis.noStyle
                                                                  Basis.None {}
                                                                  (p {})
                                                                  (Basis.join
                                                                    (Basis.
                                                                      cdata " ")
                                                                    (Basis.join
                                                                      (cdata
                                                                        col.#Name)
                                                                      (Basis.
                                                                        join
                                                                        (Basis.
                                                                          cdata
                                                                          ": ")
                                                                        (col.#Widget
                                                                          [nm])))))
                                                                (Basis.join
                                                                  (Basis.cdata
                                                                    "\n")
                                                                  (Basis.join
                                                                    (Basis.
                                                                      cdata
                                                                      "                ")
                                                                    (Basis.join
                                                                      (useMore
                                                                        acc)
                                                                      (Basis.
                                                                        join
                                                                        (Basis.
                                                                          cdata
                                                                          "\n")
                                                                        (Basis.
                                                                          cdata
                                                                          "              "))))))))
                                                    (Basis.cdata "") M.fl
                                                    M.cols)
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.join
                                                      (Basis.cdata
                                                        "            ")
                                                      (Basis.join
                                                        (Basis.cdata "\n")
                                                        (Basis.join
                                                          (Basis.cdata
                                                            "            ")
                                                          (Basis.join
                                                            (Basis.tag
                                                              Basis.null
                                                              Basis.None
                                                              Basis.noStyle
                                                              Basis.None
                                                              {Action = create}
                                                              (submit {})
                                                              (Basis.cdata
                                                                [(_ :: _)] [[]]
                                                                ""))
                                                            (Basis.join
                                                              (Basis.cdata "\n")
                                                              (Basis.cdata
                                                                "          ")))))))))))
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata "        "))))))))))))))))
         
          and 
         create : $(map snd M.cols) -> (_ :: Type) =
          fn inputs : $(map snd M.cols) =>
           Basis.bind (nextval seq)
            (fn id =>
              Basis.bind
               (dml
                 (insert tab
                   ((foldR2 [snd] [colMeta]
                      [fn cols => $(map (fn t => sql_exp [] [] [] t.1) cols)]
                      (fn nm :: Name =>
                        fn t :: _ =>
                         fn rest :: _ =>
                          [nm = ()] ~ rest =>
                           fn input =>
                            fn col =>
                             fn acc =>
                              acc ++
                               {nm = sql_inject col.#Inject (col.#Parse input)})
                      {} M.fl inputs M.cols) ++ {Id = Basis.sql_inject id})))
               (fn _ : {} =>
                 Basis.bind (list {})
                  (fn ls =>
                    return
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (body {})
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "          ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (p {})
                               (Basis.join (Basis.cdata "Inserted with ID ")
                                 (Basis.join (Top.txt id) (Basis.cdata "."))))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "          ")
                                   (Basis.join ls
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.cdata "        ")))))))))))))
                                                                            and 
         upd : int -> (_ :: Type) =
          fn id : int =>
           let
            val rec
             save : $(map snd M.cols) -> (_ :: Type) =
              fn inputs : $(map snd M.cols) =>
               Basis.bind
                (dml
                  (update [map fst M.cols]
                    (foldR2 [snd] [colMeta]
                      [fn cols =>
                        $(map
                           (fn t =>
                             sql_exp [#T = [#Id = int] ++ map fst M.cols] [] []
                              t.1) cols)]
                      (fn nm :: Name =>
                        fn t :: _ =>
                         fn rest :: _ =>
                          [nm = ()] ~ rest =>
                           fn input =>
                            fn col =>
                             fn acc =>
                              acc ++
                               {nm = sql_inject col.#Inject (col.#Parse input)})
                      {} M.fl inputs M.cols) tab
                    (Basis.sql_binary Basis.sql_eq (Basis.sql_field [#T] [#Id])
                      (Basis.sql_inject id))))
                (fn _ : {} =>
                  Basis.bind (list {})
                   (fn ls =>
                     return
                      (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                        {} (body {})
                        (Basis.join (Basis.cdata "\n")
                          (Basis.join (Basis.cdata "                  ")
                            (Basis.join
                              (Basis.tag Basis.null Basis.None Basis.noStyle
                                Basis.None {} (p {}) (Basis.cdata "Saved!"))
                              (Basis.join (Basis.cdata "\n")
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join
                                    (Basis.cdata "                  ")
                                    (Basis.join ls
                                      (Basis.join (Basis.cdata "\n")
                                        (Basis.cdata "                "))))))))))))
            in
            Basis.bind
             (oneOrNoRows
               (Basis.sql_query
                 {Rows =
                   Basis.sql_query1 [[]]
                    {Distinct = Basis.False, 
                      From = Basis.sql_from_table [#Tab] tab, 
                      Where =
                       Basis.sql_binary Basis.sql_eq
                        (Basis.sql_field [#Tab] [#Id]) (Basis.sql_inject id), 
                      GroupBy = Basis.sql_subset_all [(_ :: {{Type}})], 
                      Having = Basis.sql_inject Basis.True, 
                      SelectFields =
                       Basis.sql_subset
                        [[#Tab = (map fst M.cols, (_ :: {Type}))]], 
                      SelectExps = {}}, 
                   OrderBy = Basis.sql_order_by_Nil [(_ :: {Type})], 
                   Limit = Basis.sql_no_limit, Offset = Basis.sql_no_offset}))
             (fn fso =>
               case (fso : Basis.option {Tab : $(map fst M.cols)}) of
                None =>
                 return
                  (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                    (body {}) (Basis.cdata "Not found!")) | 
                 Some fs =>
                  return
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (body {})
                     (Basis.form Basis.None Basis.None
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "                ")
                           (Basis.join
                             (foldR2 [fst] [colMeta]
                               [fn cols => xml form [] (map snd cols)]
                               (fn nm :: Name =>
                                 fn t :: _ =>
                                  fn rest :: _ =>
                                   [nm = ()] ~ rest =>
                                    fn v =>
                                     fn col : colMeta t =>
                                      fn acc : xml form [] (map snd rest) =>
                                       Basis.join (Basis.cdata "\n")
                                        (Basis.join
                                          (Basis.cdata
                                            "                        ")
                                          (Basis.join
                                            (Basis.tag Basis.null Basis.None
                                              Basis.noStyle Basis.None {}
                                              (p {})
                                              (Basis.join (Basis.cdata " ")
                                                (Basis.join (cdata col.#Name)
                                                  (Basis.join
                                                    (Basis.cdata ": ")
                                                    (col.#WidgetPopulated [nm]
                                                      v)))))
                                            (Basis.join (Basis.cdata "\n")
                                              (Basis.join
                                                (Basis.cdata
                                                  "                        ")
                                                (Basis.join (useMore acc)
                                                  (Basis.join
                                                    (Basis.cdata "\n")
                                                    (Basis.cdata
                                                      "                      "))))))))
                               (Basis.cdata "") M.fl fs.#Tab M.cols)
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "                ")
                                   (Basis.join
                                     (Basis.tag Basis.null Basis.None
                                       Basis.noStyle Basis.None {Action = save}
                                       (submit {})
                                       (Basis.cdata [(_ :: _)] [[]] ""))
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.cdata "              "))))))))))))
            end
                and 
         confirm : int -> (_ :: Type) =
          fn id : int =>
           let
            val rec
             delete : (_ :: Type) -> (_ :: Type) =
              fn $x : (_ :: Type) =>
               case $x of
                {} =>
                 Basis.bind
                  (dml
                    (Basis.delete tab
                      (Basis.sql_binary Basis.sql_eq
                        (Basis.sql_field [#T] [#Id]) (Basis.sql_inject id))))
                  (fn _ : {} =>
                    Basis.bind (list {})
                     (fn ls =>
                       return
                        (Basis.tag Basis.null Basis.None Basis.noStyle
                          Basis.None {} (body {})
                          (Basis.join (Basis.cdata "\n")
                            (Basis.join (Basis.cdata "                  ")
                              (Basis.join
                                (Basis.tag Basis.null Basis.None Basis.noStyle
                                  Basis.None {} (p {})
                                  (Basis.cdata "The deed is done."))
                                (Basis.join (Basis.cdata "\n")
                                  (Basis.join
                                    (Basis.cdata "                  ")
                                    (Basis.join (Basis.cdata "\n")
                                      (Basis.join
                                        (Basis.cdata "                  ")
                                        (Basis.join ls
                                          (Basis.join (Basis.cdata "\n")
                                            (Basis.cdata "                ")))))))))))))
            in
            return
             (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
               (body {})
               (Basis.join (Basis.cdata "\n")
                 (Basis.join (Basis.cdata "              ")
                   (Basis.join
                     (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None
                       {} (p {})
                       (Basis.join
                         (Basis.cdata "Are you sure you want to delete ID #")
                         (Basis.join (Top.txt id) (Basis.cdata "?"))))
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "              ")
                         (Basis.join (Basis.cdata "\n")
                           (Basis.join (Basis.cdata "              ")
                             (Basis.join
                               (Basis.form Basis.None Basis.None
                                 (Basis.tag Basis.null Basis.None Basis.noStyle
                                   Basis.None
                                   {Action = delete, Value = "I was born sure!"}
                                   (submit {}) (Basis.cdata [(_ :: _)] [[]] "")))
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.cdata "            ")))))))))))
            end
                and 
         main : (_ :: Type) -> (_ :: Type) =
          fn $x : (_ :: Type) =>
           case $x of
            {} =>
             Basis.bind (list {})
              (fn ls =>
                return
                 (Basis.join
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (head {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "          ")
                         (Basis.join
                           (Basis.tag Basis.null Basis.None Basis.noStyle
                             Basis.None {} (title {}) (cdata M.title))
                           (Basis.join (Basis.cdata "\n")
                             (Basis.cdata "        "))))))
                   (Basis.tag Basis.null Basis.None Basis.noStyle Basis.None {}
                     (body {})
                     (Basis.join (Basis.cdata "\n")
                       (Basis.join (Basis.cdata "\n")
                         (Basis.join (Basis.cdata "          ")
                           (Basis.join
                             (Basis.tag Basis.null Basis.None Basis.noStyle
                               Basis.None {} (h1 {}) (cdata M.title))
                             (Basis.join (Basis.cdata "\n")
                               (Basis.join (Basis.cdata "\n")
                                 (Basis.join (Basis.cdata "          ")
                                   (Basis.join ls
                                     (Basis.join (Basis.cdata "\n")
                                       (Basis.cdata "        ")))))))))))))
      end
  end
 export Crud
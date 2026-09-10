structure Alert : sig
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
                  {Value = "Click me!", 
                    Onclick = fn _ => alert "You clicked me!"} (button {})
                  (Basis.cdata "")) (Basis.cdata "\n")))))
  end
 export Alert
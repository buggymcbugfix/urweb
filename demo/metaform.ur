functor Make (M : sig
                  con fs :: {Unit}
                  val fl : folder fs
                  val names : $(mapU string fs)
              end) = struct

    fun handler values = return <xml><body>
      {@mapUX2 [string] [string] [body]
        (fn [nm :: Name] [rest ::_] [[nm] ~ rest] name value => <xml>
          <p> {[name]} = {[value]}</p>
        </xml>)
        M.fl M.names values}
    </body></xml>

    fun main () = return <xml><body>
      <form>
        {@foldUR [string] [fn cols => xml form [] (mapU string cols)]
          (fn [nm :: Name] [rest ::_] [[nm] ~ rest] name acc => <xml>
            <p> {[name]}: <textbox{nm}/></p>
            {useMore acc}
          </xml>)
          <xml/>
          M.fl M.names}
        <submit action={handler}/>
      </form>
    </body></xml>

end

fun sub r =
    let
        fun sub' ls =
            case ls of
                [] => <xml/>
              | r :: ls => <xml>
                <p>{[r.Num]} = {[r.Text]}</p>
                {sub' ls}
              </xml>
    in
        return <xml><body>
          {sub' r.Lines}
        </body></xml>
    end

fun subfrms n =
    if n <= 0 then
        <xml/>
    else
        <xml>
          <entry>
            <hidden{#Num} value={show n}/>
            <p>{[n]}: <textbox{#Text}/></p>
          </entry>
          {subfrms (n - 1)}
        </xml>

fun form n = return <xml><body>
  <form>
    <subforms{#Lines}>
      {subfrms n}
    </subforms>
    <submit action={sub}/>
  </form>

  <a link={form (n + 1)}>One more blank</a><br/>
  {if n > 0 then
       <xml><a link={form (n - 1)}>One fewer blank</a></xml>
   else
       <xml/>}
</body></xml>

fun main () = form 1

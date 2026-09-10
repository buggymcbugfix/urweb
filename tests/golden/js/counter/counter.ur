fun main () : transaction page =
    n <- source 0;
    return <xml><body>
      <button value="Increment" onclick={fn _ => v <- get n; set n (v + 1)}/>
      <dyn signal={v <- signal n; return <xml>Count: {[v]}</xml>}/>
    </body></xml>

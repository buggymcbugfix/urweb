fun sumTo (k : int) : int = if k <= 0 then 0 else k + sumTo (k - 1)

fun main () : transaction page =
    n <- source 0;
    return <xml><body>
      <button value="Sum" onclick={fn _ => v <- get n; set n (sumTo (v + 3))}/>
      <dyn signal={v <- signal n; return <xml>{[v]}</xml>}/>
    </body></xml>

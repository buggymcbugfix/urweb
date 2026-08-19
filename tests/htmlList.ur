val main : transaction page =
   let
      val items : xlist = 
         <xml>
            <li>Some</li>
            <li>list items,</li>
            <li>nothing</li>
            <li>special</li>
            <li>to see</li>
            <li>here.</li>
            (* <form></form> *)
         </xml>
   in
      return
         <xml>
            <body>
               <ol>
                  {items}
               </ol>
               <ol start=4 reversed={True}>
                  {items}
               </ol>
               <ol start=4 reversed={True} type="i">
                  {items}
                  <li>(Although to be fair, this one is actually a bit weird...)</li>
               </ol>
               <menu>
                  <li>And check out <tt>menu</tt> which is merely a synonym for <tt>ul</tt>:</li>
                  {items}
               </menu>
            </body>
         </xml>
   end
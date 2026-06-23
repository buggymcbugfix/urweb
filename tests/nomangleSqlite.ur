(* CamelCase column names, and quote keywords *)
table person : { Id : int, FirstName : string, Select : string, Order : int }
  PRIMARY KEY Id,
  CONSTRAINT UniqueName UNIQUE FirstName

(* `order` is a keyword, as are the fields `Group` and `Limit` *)
table order : { OrderId : int, Person : int, Group : string, Limit : float }
  PRIMARY KEY OrderId,
  CONSTRAINT Person FOREIGN KEY Person REFERENCES person(Id) ON DELETE CASCADE

view personOrders = SELECT person.FirstName AS FirstName, order.Group AS Group, order.Limit AS Limit
                    FROM person JOIN order ON order.Person = person.Id

ensure_index order : { Person = equality, Group = equality }

sequence orderSeq

fun main () : transaction page =
    n <- nextval orderSeq;
    dml (INSERT INTO person (Id, FirstName, Select, Order) VALUES ({[n]}, {["Alice" ^ show n]}, {["s"]}, {[3]}));
    dml (INSERT INTO order (OrderId, Person, Group, Limit) VALUES ({[n]}, {[n]}, {["vip"]}, {[1.5]}));
    dml (UPDATE person SET Select = {["updated"]} WHERE Id = {[n]});
    ps <- queryX1 (SELECT person.Id, person.FirstName, person.Select, person.Order FROM person WHERE person.Order = 3 ORDER BY person.Id)
                  (fn r => <xml><li>{[r.Id]} {[r.FirstName]} {[r.Select]} {[r.Order]}</li></xml>);
    vs <- queryX1 (SELECT personOrders.FirstName, personOrders.Group, personOrders.Limit FROM personOrders ORDER BY personOrders.FirstName)
                  (fn r => <xml><li>{[r.FirstName]} {[r.Group]} {[r.Limit]}</li></xml>);
    c <- oneRowE1 (SELECT COUNT( * ) FROM order WHERE order.Group = {["vip"]}); (* an anonymous expression column, rendered as the identifier "1" *)
    return <xml><body>
      <ul>{ps}</ul>
      <ul>{vs}</ul>
      <p>count {[c]}</p>
    </body></xml>

sequence ids

table item : { Id : int, Name : string, Price : float, Created : time }
  PRIMARY KEY Id

table tag : { Item : int, Tag : string }
  PRIMARY KEY (Item, Tag),
  CONSTRAINT Item FOREIGN KEY Item REFERENCES item(Id)

view cheap = SELECT item.Name AS Name FROM item WHERE item.Price < 10.0

fun main () : transaction page =
    rows <- queryX1 (SELECT * FROM cheap) (fn r => <xml><li>{[r.Name]}</li></xml>);
    return <xml><body><ul>{rows}</ul></body></xml>

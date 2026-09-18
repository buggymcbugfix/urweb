table tbUser : {Id : int, Name : string, Age : int, Active : bool}
table tbOrder : {Id : int, UserId : int, Total : float, Placed : time}

(* A query on one line stays on one line, with one space between words. *)
fun byId id = oneRow (SELECT tbUser.Name, tbUser.Age FROM tbUser WHERE tbUser.Id = {[id]})
fun byId' id = oneRow (SELECT tbUser.Name, tbUser.Age FROM tbUser WHERE tbUser.Id = {[id]})

(* Broken: the parentheses on their own lines, the statement one level
 * deeper, every clause on its own line. *)
fun active () =
	queryL1
		(
			SELECT tbUser.Id, tbUser.Name
			FROM tbUser
			WHERE tbUser.Active
			ORDER BY tbUser.Name
		)

(* One line break between clauses breaks the whole statement. *)
fun active' () =
	queryL1
		(
			SELECT tbUser.Id, tbUser.Name
			FROM tbUser
			WHERE tbUser.Active
		)

(* Select lists: on the SELECT line, or one item per line one level deeper
 * with the comma after the item; DISTINCT, `*`, `T.*`, aggregates,
 * COUNT( * ), aliases, expressions. *)
fun selects () =
	queryL1
		(
			SELECT
				U.Id AS Id,
				U.Name AS Name,
				COUNT( * ) AS Orders,
				SUM(O.Total) AS Total,
				MAX(O.Placed) AS Latest,
				COALESCE(AVG(O.Total), 0.0) AS Average,
				(U.Age > 18) AS Adult,
				lower(U.Name) AS Lower
			FROM tbUser AS U
			JOIN tbOrder AS O
				ON O.UserId = U.Id
			GROUP BY U.Id, U.Name
		);
	queryL1 (SELECT DISTINCT tbUser.Age FROM tbUser);
	queryL1 (SELECT * FROM tbUser);
	queryL1 (SELECT U.* FROM tbUser AS U)

(* FROM: joins of every kind at the level of FROM, each ON one level
 * deeper; a subquery below its JOIN. *)
fun joins () =
	queryL1
		(
			SELECT U.Name, O.Total
			FROM tbUser AS U
			JOIN tbOrder AS O
				ON O.UserId = U.Id
			INNER JOIN tbOrder AS O2
				ON O2.UserId = U.Id
			LEFT JOIN tbOrder AS O3
				ON O3.UserId = U.Id
			LEFT OUTER JOIN tbOrder AS O4
				ON O4.UserId = U.Id
			RIGHT JOIN tbOrder AS O5
				ON O5.UserId = U.Id
			RIGHT OUTER JOIN tbOrder AS O6
				ON O6.UserId = U.Id
			FULL JOIN tbOrder AS O7
				ON O7.UserId = U.Id
			FULL OUTER JOIN tbOrder AS O8
				ON O8.UserId = U.Id
			LEFT JOIN
				(
					SELECT O.UserId AS UserId, COUNT( * ) AS N
					FROM tbOrder AS O
					GROUP BY O.UserId
				) AS Counts
				ON Counts.UserId = U.Id
			CROSS JOIN tbOrder AS O9
		);
	queryL1 (SELECT U.Name FROM tbUser AS U JOIN tbOrder AS O ON O.UserId = U.Id);
	queryL1 (SELECT U.Name FROM tbUser AS U, tbOrder AS O WHERE O.UserId = U.Id);
	queryL1 (SELECT U.Name FROM (tbUser AS U JOIN tbOrder AS O ON O.UserId = U.Id))

(* Conditions: AND/OR chains with the operators one level deeper than the
 * keyword, leading their operands; NOT, IS NULL, LIKE, comparisons,
 * parentheses, IF THEN ELSE, holes. *)
fun conditions name age =
	queryL1
		(
			SELECT tbUser.Id
			FROM tbUser
			WHERE tbUser.Name = {[name]}
				AND tbUser.Age >= {[age]}
				AND NOT tbUser.Active
				AND tbUser.Name LIKE {["%" ^ name ^ "%"]}
		);
	queryL1
		(
			SELECT tbUser.Id
			FROM tbUser
			WHERE
				tbUser.Age IS NOT NULL
				AND (tbUser.Age > 18 OR tbUser.Name <> 'admin')
				AND (IF {[age]} = 0 THEN TRUE ELSE tbUser.Age = {[age]})
		);
	queryL1
		(
			SELECT tbUser.Id
			FROM tbUser
			WHERE tbUser.Active
				AND
					(
						tbUser.Age = 1
						OR tbUser.Age = 2
						OR tbUser.Age = 3
					)
		);
	queryL1 (SELECT tbUser.Id FROM tbUser WHERE tbUser.Name = {[name]} AND (tbUser.Age > 1 OR tbUser.Active))

(* GROUP BY, HAVING, ORDER BY with directions and RANDOM, LIMIT and
 * OFFSET, UNION. *)
fun rest () =
	queryL1
		(
			SELECT U.Age, COUNT( * ) AS N
			FROM tbUser AS U
			GROUP BY U.Age
			HAVING COUNT( * ) > 1
			ORDER BY N DESC, U.Age ASC
			LIMIT 10
			OFFSET 5
		);
	queryL1 (SELECT tbUser.Id FROM tbUser ORDER BY RANDOM() LIMIT 1);
	queryL1 (SELECT tbUser.Id FROM tbUser ORDER BY tbUser.Name LIMIT ALL);
	queryL1
		(
			SELECT tbUser.Name AS Name
			FROM tbUser
			UNION
			SELECT tbOrder.Id AS Name
			FROM tbOrder
		)

(* Window functions. *)
fun windows () =
	queryL1
		(
			SELECT
				U.Name,
				RANK() OVER (PARTITION BY U.Age ORDER BY U.Name) AS Rank,
				COUNT( * ) OVER (PARTITION BY U.Age) AS N
			FROM tbUser AS U
		)

(* Holes: `{[e]}` for injected values, `{e}` for expressions, `{{e}}` for
 * tables and constructor names, `{{{e}}}` for whole queries. *)
fun holes tab col q =
	queryL1 (SELECT * FROM {{tab}} AS T WHERE T.{col} = {[1]} AND {sql_nullable (SQL T.Id)} IS NULL);
	queryL1 (SELECT T.{{col}} FROM {{tab}} AS T GROUP BY T.{col});
	queryL1 ({{{q}}});
	queryL1 (SELECT T.Id FROM {{tab}} AS T ORDER BY {{{ordering}}})

(* Fragments. *)
val cond = (WHERE tbUser.Active AND tbUser.Age > 1)
val cond' =
	(
		WHERE
			tbUser.Active
			AND tbUser.Age > 1
	)
val expr = (SQL tbUser.Age + 1)
val tables = (FROM tbUser AS U JOIN tbOrder AS O ON O.UserId = U.Id)
val subquery = (SELECT1 SELECT U.Name FROM tbUser AS U)

(* Scalar subqueries in expressions. *)
fun scalar () =
	queryL1
		(
			SELECT U.Name
			FROM tbUser AS U
			WHERE (SELECT COUNT( * ) AS N FROM tbOrder AS O WHERE O.UserId = U.Id) > 0
		)

(* DML: INSERT with a value list, INSERT with SET, UPDATE, DELETE; on one
 * line and broken. *)
fun dmls id name =
	dml (INSERT INTO tbUser (Id, Name, Age, Active) VALUES ({[id]}, {[name]}, 0, TRUE));
	dml
		(
			INSERT INTO tbUser
				(Id, Name, Age, Active)
			VALUES
				({[id]}, {[name]}, 0, TRUE)
		);
	dml
		(
			INSERT INTO tbUser
				(
					Id,
					Name,
					Age,
					Active
				)
			VALUES
				(
					{[id]},
					{[name]},
					0,
					TRUE
				)
		);
	dml (INSERT INTO tbUser SET Id = {[id]}, Name = {[name]}, Age = 0, Active = TRUE);
	dml
		(
			INSERT INTO tbUser
			SET
				Id = {[id]},
				Name = {[name]},
				Age = 0,
				Active = TRUE
		);
	dml (UPDATE tbUser SET Name = {[name]}, Age = Age + 1 WHERE Id = {[id]});
	dml
		(
			UPDATE tbUser
			SET
				Name   = {[name]},
				Age    = Age + 1,
				Active = FALSE
			WHERE Id = {[id]}
				AND Active
		);
	dml (DELETE FROM tbUser WHERE Id = {[id]});
	dml
		(
			DELETE FROM tbUser
			WHERE Id = {[id]}
		)

(* Views, with a query or an expression. *)
view vwActive = SELECT tbUser.Id AS Id, tbUser.Name AS Name FROM tbUser WHERE tbUser.Active

view vwAdults =
	SELECT
		tbUser.Id AS Id,
		tbUser.Name AS Name
	FROM tbUser
	WHERE tbUser.Age >= 18

view vwQuery = {activeQuery}

(* Comments inside a statement. *)
fun commented () =
	queryL1
		(
			SELECT
				tbUser.Id, (* the key *)
				(* tbUser.Name, *)
				tbUser.Age
			FROM tbUser
			(* WHERE tbUser.Active *)
			ORDER BY tbUser.Id
		)

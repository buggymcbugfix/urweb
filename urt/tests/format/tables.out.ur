(* A table on one line. *)
table tbUser : {Id : int, Name : string}

(* The type on its own line when the author broke after the colon or
 * inside the type, one field per line, a trailing comma kept. *)
table tbOrder :
	{
		Id : int,
		UserId : int,
		Placed : time,
	}

table tbItem :
	{
		Id : int,
		OrderId : int,
		Name : string
	}

(* Primary keys of one and several columns, with and without the comma
 * before the constraints. *)
table tbKeyed : {Id : int, Name : string} PRIMARY KEY Id

table tbKeyed' :
	{
		A : int,
		B : int
	}
	PRIMARY KEY (A, B)

(* Constraints: each on its own line at the level of the primary key,
 * the comma after it; a constraint's parts on its line or one per line
 * one level deeper. *)
table tbConstrained :
	{
		Id : int,
		UserId : int,
		OrderId : int,
		Qty : int,
		Email : string
	}
	PRIMARY KEY Id,
	CONSTRAINT FK_User FOREIGN KEY UserId REFERENCES tbUser(Id) ON DELETE CASCADE,
	CONSTRAINT FK_Order
		FOREIGN KEY OrderId
		REFERENCES tbOrder(Id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	CONSTRAINT FK_Both
		FOREIGN KEY (UserId, OrderId)
		REFERENCES tbPair(User, Order)
		ON DELETE SET NULL
		ON UPDATE NO ACTION,
	CONSTRAINT Uq_Email UNIQUE Email,
	CONSTRAINT Uq_Pair
		UNIQUE (UserId, OrderId),
	CONSTRAINT Ck_Qty CHECK Qty >= 1,
	CONSTRAINT Ck_Both
		CHECK Qty >= 1
			AND Qty <= {[maxQty]}

(* Constraints and keys given as expressions. *)
table tbExpr :
	{Id : int, Other : int}
	PRIMARY KEY {{keyExpr}},
	{{constraintExpr}}

table tbExpr' :
	{Id : int}
	CONSTRAINT Custom {constraintValue}

(* A table whose type is an expression. *)
table tbFromCon :
	(base ++ [Extra = string])
	PRIMARY KEY Id

(* Sequences and indices. *)
sequence seqOrder

ensure_index tbUser : {Name = equality}
ensure_index tbOrder : {UserId = equality, Placed = ordering} in tbOrder

(* The same in a signature. *)
structure S :
	sig
		table tbUser : {Id : int, Name : string}
		table tbOrder :
			{
				Id : int,
				UserId : int
			}
			PRIMARY KEY Id,
			CONSTRAINT FK_User
				FOREIGN KEY UserId
				REFERENCES tbUser(Id)
		sequence seqOrder
	end
=
	struct
		table tbUser : {Id : int, Name : string}
		table tbOrder : {Id : int, UserId : int} PRIMARY KEY Id, CONSTRAINT FK_User FOREIGN KEY UserId REFERENCES tbUser(Id)
		sequence seqOrder
	end

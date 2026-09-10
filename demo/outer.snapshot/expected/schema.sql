CREATE TABLE uw_Outer_t (
    uw_Id int8 NOT NULL,
    uw_B text NOT NULL,
    CONSTRAINT uw_Outer_t_pkey PRIMARY KEY (uw_Id)
);

CREATE TABLE uw_Outer_u (
    uw_Id int8 NOT NULL,
    uw_Link int8 NOT NULL,
    uw_C text NOT NULL,
    uw_D float8,
    CONSTRAINT uw_Outer_u_pkey PRIMARY KEY (uw_Id),
    CONSTRAINT uw_Outer_u_Link FOREIGN KEY (uw_Link) REFERENCES uw_Outer_t (uw_Id)
);


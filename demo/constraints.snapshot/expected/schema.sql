CREATE TABLE uw_Constraints_t (
    uw_Id int8 NOT NULL,
    uw_Nam text NOT NULL,
    uw_Parent int8,
    CONSTRAINT uw_Constraints_t_pkey PRIMARY KEY (uw_Id),
    CONSTRAINT uw_Constraints_t_Nam UNIQUE (uw_Nam),
    CONSTRAINT uw_Constraints_t_Id CHECK (uw_Id >= 0::int8),
    CONSTRAINT uw_Constraints_t_Parent FOREIGN KEY (uw_Parent) REFERENCES uw_Constraints_t (uw_Id)
);


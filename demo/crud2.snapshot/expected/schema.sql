CREATE TABLE uw_Crud2_t (
    uw_Id int8 NOT NULL,
    uw_Name text NOT NULL,
    uw_Ready bool NOT NULL,
    CONSTRAINT uw_Crud2_t_pkey PRIMARY KEY (uw_Id)
);

CREATE SEQUENCE uw_Crud2_seq;


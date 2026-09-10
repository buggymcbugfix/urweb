CREATE SEQUENCE uw_Ref_IR_s;

CREATE TABLE uw_Ref_IR_t (
    uw_Id int8 NOT NULL,
    uw_Data int8 NOT NULL,
    CONSTRAINT uw_Ref_IR_t_pkey PRIMARY KEY (uw_Id)
);

CREATE SEQUENCE uw_Ref_SR_s;

CREATE TABLE uw_Ref_SR_t (
    uw_Id int8 NOT NULL,
    uw_Data text NOT NULL,
    CONSTRAINT uw_Ref_SR_t_pkey PRIMARY KEY (uw_Id)
);


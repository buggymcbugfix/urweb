PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE uw_Undetermined_t (
    uw_Id integer NOT NULL,
    uw_Name text NOT NULL,
    CONSTRAINT uw_Undetermined_t_pkey PRIMARY KEY (uw_Id)
);


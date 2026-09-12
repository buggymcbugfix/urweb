PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE uw_Trigram_t (
    uw_Id integer NOT NULL,
    uw_Name text NOT NULL,
    CONSTRAINT uw_Trigram_t_pkey PRIMARY KEY (uw_Id)
);

CREATE INDEX uw_Trigram_t_uw_name_trigram ON uw_Trigram_t USING gist (uw_Name);


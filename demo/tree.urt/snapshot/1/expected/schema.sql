CREATE SEQUENCE uw_Tree_s;

CREATE TABLE uw_Tree_t (
    uw_Id int8 NOT NULL,
    uw_Parent int8,
    uw_Nam text NOT NULL,
    CONSTRAINT uw_Tree_t_pkey PRIMARY KEY (uw_Id),
    CONSTRAINT uw_Tree_t_F FOREIGN KEY (uw_Parent) REFERENCES uw_Tree_t (uw_Id) ON DELETE CASCADE
);


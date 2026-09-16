CREATE TABLE uw_View_t (
    uw_A int8 NOT NULL
);

CREATE VIEW uw_View_v AS
SELECT T_T.uw_A AS uw_A FROM uw_View_t AS T_T WHERE (T_T.uw_A > 7::int8);


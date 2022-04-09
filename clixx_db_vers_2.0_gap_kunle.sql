drop table operations;

create table operations(
OP_ID number,
OP_NAME varchar2(30),
OP_STARTTIME timestamp,
OP_ENDTIME timestamp,
RUNNER varchar2(6),
STATUS varchar2(10),
OP_TYPE varchar2(10),
UP_DATE varchar2(10));

commit;

create index IDX_OPERATIONS_OP_ID on operations(OP_ID);

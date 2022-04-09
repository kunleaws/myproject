----Sending feedback to STD OUT -----
set echo on feedback on term on

----Logging all SQL Statement into the Spool file.
spool '/home/oracle/scripts/practicedir_kunle_dec21/clixx_db_vers_1.0_gap_kunle.log'

---Showing who you are loggin in as
show user

select * from global_name;

select systimestamp from dual;

---Dropping  Existing vers_1.0 Table
drop table orders;
drop table products;
drop table tracking;
drop table credit_cards;
drop table demographics;
drop table customer;

--Creating vers_1.0 Tables
create table customer(
CUST_ID varchar2(26),
FNAME varchar2(26),
LNAME varchar2(26),
GENDER char,
DOB varchar2(26),
EMAIL varchar2(26));

create table demographics(
CUST_ID varchar2(26),
DEM_ID number,
ADDRESS varchar2(50),
ADDRESS_TYPE char,
DE_FAULT char);

create table credit_cards(
CUST_ID varchar2(26),
CC_NO number,
CC_EXP varchar2(10),
CC_CVV number,
CC_TYPE varchar2(10));

create table orders(
CUST_ID varchar2(26),
ORDER_ID varchar2(26),
ORDER_STATUS varchar2(26),
ORDER_DATE date,
DELIV_TYPE varchar2(26),
PROD_ID varchar2(26),
TRACK_ID varchar2(26));

create table products(
PROD_ID varchar2(26),
PROD_NAME varchar2(26),
PROD_TYPE varchar2(26),
QTY number,
SKU varchar2(26),
PRICE number);

create table tracking(
TRACK_ID varchar2(26),
TRACK_NO varchar2(26),
CUST_ID varchar2(26),
DELIV_TYPE varchar2(26),
ORDER_STATUS varchar2(26),
DELIV_DATE varchar2(26));

---Creating vers_1.- Constraint
alter TABLE CUSTOMER ADD CONSTRAINT PK_CUSTOMER_CUST_ID PRIMARY KEY(CUST_ID);

alter TABLE CREDIT_CARDS add constraint FK_CREDIT_CARDS_CUST_ID FOREIGN KEY(CUST_ID) REFERENCES CUSTOMER(CUST_ID);

alter TABLE DEMOGRAPHICS add constraint FK_DEMOGRAPHICS_CUST_ID FOREIGN KEY(CUST_ID) REFERENCES CUSTOMER(CUST_ID);

alter TABLE TRACKING ADD CONSTRAINT PK_TRACKING_TRACK_ID PRIMARY KEY(TRACK_ID);

alter TABLE TRACKING ADD CONSTRAINT FK_TRACKING_CUST_ID FOREIGN KEY(CUST_ID) REFERENCES CUSTOMER(CUST_ID);

alter TABLE PRODUCTS add constraint PK_PRODUCTS_PROD_ID PRIMARY KEY(PROD_ID);

alter TABLE ORDERS ADD CONSTRAINT FK_ORDERS_PROD_ID FOREIGN KEY(PROD_ID) REFERENCES PRODUCTS(PROD_ID);

alter TABLE ORDERS add constraint FK_ORDERS_CUST_ID FOREIGN KEY(CUST_ID) REFERENCES CUSTOMER(CUST_ID);

---alter table ORDERS add constraint FK_ORDERS_TRACK_ID FOREIGN KEY(TRACK_ID) REFERENCES TRACKING(TRACK_ID);

--- INSERTING INTO TABLES
insert into customer
values(1,'Tope','Alabi','M','28 Mar 2000','t.alabi@gmail.com');
insert into customer
values(2,'Lola','Johnson','F','16 Aug 1994','l.johnson@yahoo.com');
insert into customer
values(3,'John','Smith','M','21 Jul 1972','j.smith1@gmail.com');
insert into customer
values(4,'Giselle','Rojas','F','22 Nov 1983','grojas83@yahoo.com');
insert into customer
values(5,'Chris','Lunney','M','21 Jun 1992','clunney92@yahoo.com');
commit;

insert into demographics
values(1,1,'24 Brighton Street Houston TX 77077','B','Y');
insert into demographics
values(1,2,'1873 Crossfield Rd Chicago IL 23964','S','N');
insert into demographics
values(2,3,'254 Lazy Hollow Dallas TX 44326','B','Y');
insert into demographics
values(2,4,'14325 Mossy Gate Houston TX 77082','S','N');
insert into demographics
values(3,5,'57 Very Star Rd Austin TX 89542','B','Y');
insert into demographics
values(3,6,'38 Body Rd Houston TX 77082','S','N');
insert into demographics
values(4,7,'2456 Chris Lane Austin TX 89745','B','Y');
insert into demographics
values(4,8,'542 Right Lane Pearland TX 77865','S','N');
insert into demographics
values(5,9,'34501 Madison Rd Chicago IL 23147','B','Y');
insert into demographics
values(5,10,'246 River Rd Houston TX 77856','S','N');
commit;

insert into credit_cards
values(1,3247951036842665,'Mar 2025',236,'Visa');
insert into credit_cards
values(1,2475478968423541,'Aug 2024',354,'MasterCard');
insert into credit_cards
values(2,2147926824942702,'Jun 2026',654,'Platinum');
insert into credit_cards
values(2,9812453278645015,'May 2025',694,'Visa');
insert into credit_cards
values(3,7460453456056402,'Jan 2024',135,'Platinum');
insert into credit_cards
values(3,2650064536543754,'Feb 2024',862,'MasterCard');
insert into credit_cards
values(4,2073457023459057,'Apr 2025',644,'Visa');
insert into credit_cards
values(4,2094834573405867,'Dec 2024',642,'Visa');
insert into credit_cards
values(5,2340956504653052,'Oct 2023',964,'Rewards');
insert into credit_cards
values(5,8654425915494325,'Oct 2022',648,'Visa');
commit;

insert into products
values(1,'Computer','Office',15,2398,10);
insert into products
values(2,'Mouse','Office',20,3545,56);
insert into products
values(3,'Desk','Office',5,7366,21);
insert into products
values(4,'Pater','Supplies',2,3254,12);
insert into products
values(5,'Docking','Office',10,3678,6);
insert into products
values(6,'Keyboard','Office',2,7853,10);
insert into products
values(7,'Monitor','Office',5,8953,2);
insert into products
values(8,'Cat5_cable','Office',6,6543,58);
insert into products
values(9,'Mouse','Office',2,8689,4);
insert into products
values(10,'Lamp','Supplies',6,6779,2);
commit;

insert into orders
values(1,1,'complete','15-Mar-2022','Ground',1,1);
insert into orders
values(1,2,'complete','22-Apr-2024','Air',4,6);
insert into orders
values(2,3,'complete','10-Feb-2026','Freight',3,2);
insert into orders
values(2,4,'complete','24-Apr-2025','Ground',2,8);
insert into orders
values(3,5,'complete','11-Apr-2026','Air',2,3);
insert into orders
values(3,6,'complete','08-May-2022','Freight',4,9);
insert into orders
values(4,7,'inprogress','28-Nov-2022','Ground',5,4);
insert into orders
values(4,8,'complete','07-Jun-2024','Ground',6,7);
insert into orders
values(5,9,'inprogress','29-Aug-2026','Ground',8,5);
insert into orders
values(5,10,'complete','02-Dec-2025','Air',9,10);
commit;


insert into tracking
values(1,001,1,'Air','Completed','2021 Dec 18');
insert into tracking
values(2,002,2,'Ground','Out for Delivery','2022 Feb 19');
insert into tracking
values(3,003,3,'Air','Delivered','2022 Feb 23');
insert into tracking
values(4,004,4,'Ground','Out for Delivery','2022 Mar 25');
insert into tracking
values(5,005,5,'Air','Delivered','2022 Mar 30');
insert into tracking
values(6,006,1,'Air','Delivered','2022 Mar 23');
insert into tracking
values(7,007,4,'Ground','Out for Delivery','2022 Mar 23');
insert into tracking
values(8,008,2,'Air','Completed','2022 Mar 29');
insert into tracking
values(9,009,3,'Freight','En Route','2022 Feb 28');
insert into tracking
values(10,010,5,'Freight','Shipping Soon','2022 Mar 23');
commit;

---Creating View for the tables
create or replace view VW_customer as
select a.fname,a.lname,a.dob,a.gender,b.address,c.cc_no,c.cc_exp,c.cc_cvv,d.order_id,e.track_id,e.order_status
from customer a
join demographics b
on (a.cust_id=b.cust_id)
join credit_cards c
on (b.cust_id=c.cust_id)
join orders d
on (c.cust_id=d.cust_id)
join tracking e
on (d.cust_id=e.cust_id);

select systimestamp from dual;
spool off

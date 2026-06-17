select current_database();
create schema wrangling;

select * from wrangling.superstore;

create table superstore_stage as select * from superstore;

select * from superstore_stage;
/* 
1.Remove duplicates
2.Standardize data
3.Null values or blank values
4.Remove any columns if unnecessary (only if 100% sure that it is meaningless)
*/

/*alter table superstore_stage 
rename column "Row ID" to rowid;
alter table superstore_stage 
rename column "Order Date" to orderDate;
alter table superstore_stage 
rename column "Order ID" to orderId;
alter table superstore_stage
rename column "Ship Date" to shipDate;
alter table superstore_stage
rename column "Ship Mode" to shipMode;
alter table superstore_stage
rename column "Customer ID" to customerId;
alter table superstore_stage
rename column "Customer Name" to customerName;
alter table superstore_stage
rename column "Segment" to segment;
alter table superstore_stage
rename column "Country" to country;
alter table superstore_stage
rename column "City" to city;
alter table superstore_stage
rename column "State" to state;
alter table superstore_stage
rename column "Postal Code" to postalCode;
alter table superstore_stage
rename column "Region" to region;
alter table superstore_stage
rename column "Product ID" to productId;
alter table superstore_stage
rename column "Category" to category;
alter table superstore_stage
rename column "Sub-Category" to subCategory;
alter table superstore_stage
rename column "Product Name" to productName;
alter table superstore_stage
rename column "Sales" to sales;
alter table superstore_stage
rename column "Quantity" to quantity;
alter table superstore_stage
rename column "Discount" to discount;
alter table superstore_stage
rename column "Profit" to profit;*/

--check for duplicate records
with cte as
(
	select *,
	row_number() over (partition by orderid,orderdate,customerid,segment,country,city,state,postalcode,region,productid,
	category,subcategory,productname,quantity) as row_num 
	from superstore_stage
)
select * from cte where row_num>1 order by rowid;

--verify duplicate record and delete them.
select * from superstore_stage where orderid='US-2014-150119';

delete from superstore_stage where rowid='3406';

--check if 1 orderid is linked to multiples customers.
select orderid, count(distinct customerid) as customer_count from superstore_stage
group by orderid having count(distinct customerid)>1;

--check if one customer has multiples customer ids
select  customername, count(distinct customerid) from superstore_stage 
group by customername;

--check for discrepancy/bad data in all relevant columns

select distinct orderid from superstore_stage where orderid not like 'US%' and orderid not like 'CA%';

select distinct shipmode from superstore_stage;

select distinct customerid from superstore_stage;

select distinct customername from superstore_stage;

select distinct segment from superstore_stage;

select distinct country from superstore_stage;

select distinct city from superstore_stage;

select distinct state from superstore_stage;

select distinct postalcode from superstore_stage;

select distinct region from superstore_stage;

select distinct category from superstore_stage;

select distinct subcategory from superstore_stage;

select distinct productid, productname from superstore_stage order by 1;

select distinct productid,regexp_replace(productname,'[^a-zA-Z0-9/\*"'',''\.\-_]+',' ','g') from superstore_stage order by 1;

update superstore_stage 
set productname=regexp_replace(productname,'[^a-zA-Z0-9/\*"'',''\.\-_]+',' ','g');

update superstore_stage
set productname=trim(leading ' ' from productname);

select count(distinct "Product ID" ) from superstore
union all
select count(distinct productid) from superstore_stage;

select count(distinct "Product Name" ) from superstore
union all
select count(distinct productname) from superstore_stage;

select distinct productid, productname from superstore_stage where productid='FUR-BO-10002213' order by 1;

--check for duplicate product for same id
select  productid, count(distinct productname) from superstore_stage
group by productid having count(distinct productname)>1;

select * from superstore_stage where productid='FUR-CH-10001147';

/*updating duplicate productids*/

update superstore_stage 
set productid='FUR-BO-10002214'
where productname ='DMI Eclipse Executive Suite Bookcases';

update superstore_stage 
set productid='FUR-FU-10004019'
where productname ='Executive Impressions 13" Chairmont Wall Clock';

update superstore_stage 
set productname ='Executive Impressions 13" Clairmont Wall Clock'
where productid='FUR-FU-10004019';

update superstore_stage 
set productid='FUR-FU-10004092'
where productname ='Eldon 200 Class Desk Accessories, Black';

update superstore_stage 
set productid='FUR-FU-10004849'
where productname ='DAX Solid Wood Frames';

update superstore_stage 
set productid='FUR-FU-10004865'
where productname ='Eldon 500 Class Desk Accessories';

update superstore_stage 
set productid='OFF-AP-10000577'
where productname ='Belkin 7 Outlet SurgeMaster II';

update superstore_stage 
set productid='OFF-AR-10001148'
where productname ='Avery Hi-Liter Comfort Grip Fluorescent Highlighter, Yellow Ink';

update superstore_stage 
set productid='OFF-BI-10002027'
where productname ='Ibico Recycled Linen-Style Covers';

update superstore_stage 
set productid='OFF-BI-10004633'
where productname ='GBC Binding covers';

update superstore_stage 
set productid='OFF-BI-10004655'
where productname ='VariCap6 Expandable Binder';

update superstore_stage 
set productid='OFF-PA-10000358'
where productname ='Xerox 1888';

update superstore_stage 
set productid='OFF-PA-10000478'
where productname ='Xerox 1952';

update superstore_stage 
set productid='OFF-PA-10000658'
where productname ='TOPS Carbonless Receipt Book, Four 2-3/4 x 7-1/4 Money Receipts per Page';

update superstore_stage 
set productid='OFF-PA-10001971'
where productname ='Xerox 1908';

update superstore_stage 
set productid='OFF-PA-10002196'
where productname ='Xerox 1966';

update superstore_stage 
set productid='OFF-PA-10002197'
where productname ='Xerox 1916';

update superstore_stage 
set productid='OFF-PA-10002198'
where productname ='Xerox 1992';

update superstore_stage 
set productid='OFF-ST-10001229'
where productname ='Personal File Boxes with Fold-Down Carry Handle';

update superstore_stage 
set productid='OFF-ST-10004951'
where productname ='Acco Perma 3000 Stacking Storage Drawers';

update superstore_stage 
set productid='TEC-AC-10002048'
where productname ='Plantronics Savi W720 Multi-Device Wireless Headset System';

update superstore_stage 
set productid='TEC-AC-10002551'
where productname ='Maxell 4.7GB DVD-RW 3/Pack';

update superstore_stage 
set productid='TEC-AC-10003833'
where productname ='Imation 16GB Mini TravelDrive USB 2.0 Flash Drive';

update superstore_stage 
set productid='TEC-MA-10001149'
where productname ='Okidata MB491 Multifunction Printer';

update superstore_stage 
set productid='TEC-PH-10001531'
where productname ='Plantronics Voyager Pro Legend';

update superstore_stage 
set productid='TEC-PH-10001796'
where productname ='RCA H5401RE1 DECT 6.0 4-Line Cordless Handset With Caller ID/Call Waiting';

update superstore_stage 
set productid='TEC-PH-10002201'
where productname ='Samsung Galaxy Note 2';

update superstore_stage 
set productid='TEC-PH-10004532'
where productname ='AT T CL2909';

update superstore_stage 
set productid='FUR-CH-1000114'
where productname ='Global Task Chair, Black';

--check for duplicate id for same products
select  productname, count(distinct productid) from superstore_stage 
group by productname having count(distinct productid)>1;

--check productname that will have a changed productid
select s.productname, s.productid, m.correctedid
from superstore_stage s join 
(select ss.productname as pname , min(ss.productid ) as correctedid
from superstore_stage ss
group by ss.productname ) m 
on s.productname = m.pname
where s.productid <> m.correctedid;

--updating productids to distinct values
with mapping as
(
select productname, min(productid) as correctedid
from superstore_stage
group by productname 
)
update superstore_stage ss
set productid = m.correctedid
from mapping m
where ss.productname = m.productname and
ss.productid  <> m.correctedid;

/*convert orderdate and shipdate from varchar to date format*/

select to_date(orderdate, 'MM/DD/YYYY'), to_date(shipdate, 'MM/DD/YYYY') from superstore_stage ss ;

alter table superstore_stage  
alter column orderdate type date
using to_date(nullif(orderdate, ''), 'MM/DD/YYYY');

alter table superstore_stage  
alter column shipdate type date
using to_date(nullif(shipdate, ''), 'MM/DD/YYYY');

select * from superstore_stage where orderdate > shipdate;

select * from superstore_stage where sales <=0 or sales is null or quantity<=0 or quantity is null or discount<0 or discount is null;



















































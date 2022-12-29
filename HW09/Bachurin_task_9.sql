/*
������� ����������� � �������������� ���� ������ WideWorldImporters.
����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak
�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ����������� � ���� ���� ������� ��������� insert � ������� Customers ��� Suppliers 
*/


insert into Sales.Customers (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, 
DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold,
PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2,
DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo )
values (default, 'Tailspin Toys (Hambleton, WV)1',1, 3,1, 1099, 1100, 3, 14380, 14380, null, '2013-01-01', 0.000, 0, 0, 7, '(304) 555-0100', '(304) 555-0101', '',
	'', 'http://www.tailspintoys.com/Hambleton', 'Unit 257', '1715 Samaniego Street', '90087', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 1053', 'Chatterjeeville', '90087', 1, default, default),
(default, 'Tailspin Toys (Imlaystown, NJ)2', 1, 3, 1, 1001, 1002, 3, 16430, 16430, null, '2013-01-01', 0.000, 0, 0, 7, '(201) 555-0100', '(201) 555-0101',
	'', '', 'http://www.tailspintoys.com/Imlaystown', 'Suite 12', '1305 Kaleja Street', '90051', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 5129', 'Ghateville', '90051', 1, default, default),
(default, 'Tailspin Toys (Idria, CA)3', 1, 3, 1, 1103, 1104, 3, 16401, 16401, null, '2013-01-01', 0.000, 0, 0, 7, '(209) 555-0100', '(209) 555-0101',
	'', '', 'http://www.tailspintoys.com/Idria', 'Shop 99', '1189 Malakar Road', '90556', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 4080', 'RNairville', '90556', 1, default, default ),
(default, 'Tailspin Toys (Nanafalia, AL)4', 1, 3, 1, 1105, 1106, 3, 23560, 23560, null, '2013-01-01', 0.000, 0, 0, 7, '(205) 555-0100', '(205) 555-0101', '',
	'', 'http://www.tailspintoys.com/Nanafalia', 'Suite 217', 'G1729 Dey Road', '90783', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 3979', 'RJavanville', '90783', 1, default, default),
( default, 'Tailspin Toys (Railroad, PA)5', 1, 3, 1, 1107, 1108, 3, 28222, 28222, null, '2013-01-01', 0.000, 0, 0, 7, '(215) 555-0100', '(215) 555-0101',
	'', '', 'http://www.tailspintoys.com/Railroad', 'Suite 158', '1032 Duperre Street', '90586', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 9885', 'Novakovicville', '90586', 1, default, default)


select top 100 *
from Sales.Customers a
order by a.CustomerID DESC

/*
2. ������� ���� ������ �� Customers, ������� ���� ���� ���������
*/

create table #temp_Customers (id int)

insert into #temp_Customers (id)
select top 1 a.CustomerID
from Sales.Customers a
order by a.CustomerID DESC

delete Sales.Customers
where CustomerID = (select top 1 id 
 		from #temp_Customers)

select top 100 *
from Sales.Customers a
order by a.CustomerID DESC


drop table #temp_Customers

/*
3. �������� ���� ������, �� ����������� ����� UPDATE
*/

create table #temp_Customers (id int)

insert into #temp_Customers (id)
select top 1 a.CustomerID
from Sales.Customers a
order by a.CustomerID DESC


update Sales.Customers
set CustomerName = 'Tailspin Toys (Idria, CA)15'
where CustomerID = (select top 1 id 
 		from #temp_Customers)


select top 100 *
from Sales.Customers
order by CustomerID desc


drop table #temp_Customers

/*
4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
*/

create table #temp_Customers (Action varchar(100), id int)

merge Sales.Customers as a
using (select top 1 *
       from Sales.Customers
	   order by CustomerID desc) as b
	on (a.CustomerID = b.CustomerID)
when matched
	then update
		 set CustomerName = 'Old'
when not matched
	then insert (CustomerID,	CustomerName, BillToCustomerID,	CustomerCategoryID,	BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID,
DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage,
IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition,
WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1,
PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo)
values ( default, 'Tailspin Toys (Railroad, PA)100', 1, 3, 1, 1107, 1108, 3, 28222, 28222, null, '2013-01-01', 0.000, 0, 0, 7, '(215) 555-0100', '(215) 555-0101',
	'', '', 'http://www.tailspintoys.com/Railroad', 'Suite 158', '1032 Duperre Street', '90586', geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326),
	'PO Box 9885', 'Novakovicville', '90586', 1, default, default)
output 
	$action,
	inserted.CustomerID
into #temp_Customers;

select *
from #temp_Customers

select top 100 *
from Sales.Customers a
where a.CustomerID in (select id 
					   from #temp_Customers)

drop table #temp_Customers


/*
5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert
*/

�������� ����� ���� �������
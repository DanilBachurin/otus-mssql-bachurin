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
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT| Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2       |     2
01.02.2013   |      7             |        3           |      4      |      2       |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select p.*
from (
select OrderDate = format(cast(cast(year(OrderDate) as varchar) + '-' + cast(month(OrderDate) as varchar )+ '-01' as date), 'd', 'de-de'),
	   CustomerName = replace(replace(CustomerName, 
	   left(CustomerName, charindex('(', CustomerName, 0)), ''), ')', ''),
	   OrderID
from Sales.Customers Customers
cross apply (select OrderDate,
                    Orders.OrderID
			 from Sales.Orders Orders
			 join Sales.Invoices Invoices on Orders.OrderID = Invoices.OrderID
			 where exists (select Transactions.CustomerTransactionID
						   from Sales.CustomerTransactions Transactions
						   where Transactions.InvoiceID = Invoices.InvoiceID)
						   and Customers.CustomerID = Orders.CustomerID) as a
where Customers.CustomerID between 2 and 6) as b
pivot (count(OrderID) for CustomerName IN (
[Peeples Valley, AZ],
[Medicine Lodge, KS],
[Gasport, NY],
[Sylvanite, MT],
[Jessie, ND]) ) as p
order by convert(date, OrderDate)


/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.
������ ����������:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, p.AddressLine
from 
	(select Customers.CustomerName,
		   Customers.DeliveryAddressLine1,
		   Customers.DeliveryAddressLine2,
		   Customers.PostalAddressLine1,
		   Customers.PostalAddressLine2
	from Sales.Customers Customers
	where Customers.CustomerName like '%Tailspin Toys%') as a
unpivot
([AddressLine] for [AddressType] IN (
[DeliveryAddressLine1],
[DeliveryAddressLine2],
[PostalAddressLine1],
[PostalAddressLine2]
) ) p

/*
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.
������ ����������:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID,
	   CountryName,
	   a.Code
from Application.Countries Countries
OUTER APPLY (
	select CAST(IsoNumericCode as varchar(3)) as Code
	from Application.Countries Countries1
	where Countries.CountryID = Countries1.CountryID
	UNION
	select IsoAlpha3Code as Code
	from Application.Countries Countries1
	where Countries.CountryID = Countries1.CountryID) as a
order by CountryID, CountryName

/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

select aa.CustomerID as [�� ������],
	   aa.CustomerName as [��������],
	   aa.StockItemID as [�� ������],
	   aa.UnitPrice as [����],
	   b.TransactionDate as [���� �������]
from (
	select Customers.CustomerID,
	       Customers.CustomerName,
		   a.StockItemID,
		   a.UnitPrice
	from Sales.Customers Customers
	cross apply (
		select distinct top 2 StockItems.StockItemID, StockItems.UnitPrice
		from Sales.Orders Orders
		INNER join Sales.OrderLines OrderLines on Orders.OrderID = OrderLines.OrderID
		INNER join Warehouse.StockItems StockItems on OrderLines.StockItemID = StockItems.StockItemID
		INNER join Sales.Invoices Invoices on Orders.OrderID = Invoices.OrderID
		where Customers.CustomerID = Orders.CustomerID
				and exists (select InvoiceID
							from Sales.CustomerTransactions Transactions
							where Transactions.InvoiceID = Invoices.InvoiceID)
		order by StockItems.UnitPrice DESC
		) a
	) as aa
cross apply (
	select top 1 Transactions.TransactionDate
	from Sales.Orders Orders
	join Sales.OrderLines OrderLines on Orders.OrderID = OrderLines.OrderID
	join Sales.Invoices Invoices on Orders.OrderID = Invoices.OrderID
	join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
	where OrderLines.StockItemID = aa.StockItemID
		and Orders.CustomerID = aa.CustomerID
	order by Transactions.TransactionDate DESC) b
order by CustomerID, UnitPrice DESC
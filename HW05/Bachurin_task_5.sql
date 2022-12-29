/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "03 - ����������, CTE, ��������� �������".
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
-- ��� ���� �������, ��� ��������, �������� ��� �������� ��������:
--  1) ����� ��������� ������
--  2) ����� WITH (��� ����������� ������)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. 
������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/

--1) ��������� ������; 
select 
	PersonID as [��],
	FullName as [������ ���]
from Application.People People
where People.IsSalesPerson = 1 and People.PersonID not in (select distinct Invoices.SalespersonPersonID
														   from Sales.Invoices Invoices
														   join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
														   join Sales.OrderLines OrderLines on Invoices.OrderID = OrderLines.OrderID
														   where DATEPART(YEAR, Transactions.TransactionDate) = 2015
														   and DATEPART(MONTH, Transactions.TransactionDate) = 7
														   and DATEPART(DAY, Transactions.TransactionDate) = 4)

--2) ����� WITH.
WITH cte
AS (
select distinct Invoices.SalespersonPersonID
from Sales.Invoices Invoices
join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
join Sales.OrderLines OrderLines on Invoices.OrderID = OrderLines.OrderID
where DATEPART(YEAR, Transactions.TransactionDate) = 2015
and DATEPART(MONTH, Transactions.TransactionDate) = 7
and DATEPART(DAY, Transactions.TransactionDate) = 4
	)
select	
	PersonID as [��],
	FullName as [������ ���]
from cte as c
right join Application.People People on People.PersonID = c.SalespersonPersonID
where IsSalesPerson = 1 AND SalespersonPersonID IS NULL

/*
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/

--1.1) ��������� ������; 

select
	StockItemID as [�� ������],
	StockItemName as [������������ ������],
	UnitPrice as [����]
from Warehouse.StockItems StockItems
where UnitPrice = (select min(UnitPrice)
				   from Warehouse.StockItems)

--1.2) ��������� ������; 

select 	
	StockItemID as [�� ������],
	StockItemName as [������������ ������],
	UnitPrice as [����]
from Warehouse.StockItems StockItems
join (select min(UnitPrice) as MinUnitPrice
	  from Warehouse.StockItems) 
	  minPrice ON StockItems.UnitPrice = minPrice.MinUnitPrice

--2) ����� WITH.

WITH cte
as (select min(UnitPrice) as MinUnitPrice
	from Warehouse.StockItems)
select 
	StockItemID as [�� ������],
	StockItemName as [������������ ������],
	UnitPrice as [����]
from cte as c
join Warehouse.StockItems as StockItems on StockItems.UnitPrice = C.MinUnitPrice
/*
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� 
�� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE). 
*/

--1.1) ��������� ������; 

select distinct 
	Customers.CustomerName [���]
from (
	select top 5 Transactions.CustomerID
	from Sales.CustomerTransactions Transactions
	order by Transactions.TransactionAmount DESC
	) a
join Sales.Customers Customers ON a.CustomerID = Customers.CustomerID

--1.2) ��������� ������; 

select distinct 
	Customers.CustomerName [���]
from Sales.Customers
where CustomerID IN (select top  5 CustomerID
					 from Sales.CustomerTransactions
					 order by TransactionAmount DESC)

--2) ����� WITH.

WITH cte
as (select top 5 CustomerID
	from Sales.CustomerTransactions
	order by TransactionAmount desc)
select distinct 
	Customers.CustomerName [���]
from Sales.Customers Customers
JOIN cte as c on Customers.CustomerID = c.CustomerID

/*
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, 
�������� � ������ ����� ������� �������, � ����� ��� ����������, 
������� ����������� �������� ������� (PackedByPersonID).
*/

--1) ��������� ������; 

select 
	Cities.CityID as [�� ������],
	Cities.CityName as [�������� ������],
	People.FullName as [��� ����������]
from
(select top 3 StockItemID
from Warehouse.StockItems 
order by UnitPrice desc) Stock
join Sales.OrderLines OrderLines on Stock.StockItemID = OrderLines.StockItemID
join Sales.Orders Orders on OrderLines.OrderID = Orders.OrderID
join Sales.Customers Customers on Orders.CustomerID = Customers.CustomerID
join Application.People People on Orders.PickedByPersonID = People.PersonID
join Application.Cities Cities on Customers.DeliveryCityID = Cities.CityID

--2) ����� WITH.
WITH cte as (select top 3 StockItemID
			 from Warehouse.StockItems
			 order by UnitPrice DESC)
select distinct 
	Cities.CityID as [�� ������],
	Cities.CityName as [�������� ������],
	People.FullName as [��� ����������]
from cte AS stock
join Sales.OrderLines OrderLines on stock.StockItemID = OrderLines.StockItemID
join Sales.Orders Orders on OrderLines.OrderID = Orders.OrderID
join Sales.Customers Customers on Orders.CustomerID = Customers.CustomerID
join Application.People People on Orders.PickedByPersonID = People.PersonID
join Application.Cities Cities on Customers.DeliveryCityID = Cities.CityID


-- ---------------------------------------------------------------------------
-- ������������ �������
-- ---------------------------------------------------------------------------
-- ����� ��������� ��� � ������� ��������� ������������� �������, 
-- ��� � � ������� ��������� �����\���������. 
-- �������� ������������������ �������� ����� ����� SET STATISTICS IO, TIME ON. 
-- ���� ������� � ������� ��������, �� ����������� �� (����� � ������� ����� ��������� �����). 
-- �������� ���� ����������� �� ������ �����������. 

-- 5. ���������, ��� ������ � ������������� ������
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

SET STATISTICS TIME OFF
SET STATISTICS IO OFF


 --����� ������ SQL Server:
 --  ����� �� = 221 ��, ����������� ����� = 45 ��.


-- --
--1. ��������� ���������� �������;
--2. ��������� ������� ��  WITH;
--3. �� select ������� � from ���������

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

WITH SalesTotals as (SELECT 
					 InvoiceId,
					 SUM(Quantity * UnitPrice) AS TotalSumm
					 FROM Sales.InvoiceLines
					 GROUP BY InvoiceId
					 HAVING SUM(Quantity*UnitPrice) > 27000)
					 


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	TotalSummForPickedItems
FROM Sales.Invoices 
join Application.People People on People.PersonID = Invoices.SalespersonPersonID
JOIN SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
JOIN (
	SELECT 
		ol.OrderID,
		SUM(ol.PickedQuantity * ol.UnitPrice) AS TotalSummForPickedItems
	FROM Sales.Orders o
	JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
	WHERE o.PickingCompletedWhen IS NOT NULL
	GROUP BY ol.OrderID
	) ol ON Invoices.OrderID = ol.OrderID
ORDER BY TotalSumm DESC

SET STATISTICS TIME OFF
SET STATISTICS IO OFF


 --����� ������ SQL Server: 
 --  ����� �� = 47 ��, ����������� ����� = 41 ��.
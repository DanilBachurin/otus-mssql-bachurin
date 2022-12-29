/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "06 - ������� �������".

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
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
��������: id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������

������:
-------------+----------------------------
���� ������� | ����������� ���� �� ������
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
*/

select Invoices1.InvoiceID,
	   Customers1.CustomerName,
	   Invoices1.InvoiceDate,
	   Transactions1.TransactionAmount,
	   (select SUM(Transactions.TransactionAmount)
		from Sales.Invoices Invoices
		join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
		join Sales.Customers Customers on Invoices.CustomerID = Customers.CustomerID
		where Customers.CustomerID = Customers1.CustomerID
			and DATEPART(year, Transactions.TransactionDate) >= 2015
			and DATEPART(month, Transactions.TransactionDate) = DATEPART(month, Transactions1.TransactionDate)
			and DATEPART(year, Transactions.TransactionDate) = DATEPART(year, Transactions1.TransactionDate)
		group by Customers.CustomerID) as TotalSum
from Sales.Invoices Invoices1
join Sales.CustomerTransactions Transactions1 on Transactions1.InvoiceID = Invoices1.InvoiceID
join Sales.Customers Customers1 on Invoices1.CustomerID = Customers1.CustomerID
where DATEPART(year, Transactions1.TransactionDate) >= 2015
order by Customers1.CustomerName, Invoices1.InvoiceID

/*
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
   �������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/

--� ������� �������� 


SET STATISTICS TIME ON;
select Invoices1.InvoiceID,
	   Customers1.CustomerName,
	   Invoices1.InvoiceDate,
	   Transactions1.TransactionAmount,
	   sum(Transactions1.TransactionAmount) over (partition by year(Transactions1.TransactionDate),month(Transactions1.TransactionDate), Invoices1.CustomerID) as TotalSum
from Sales.Invoices Invoices1
join Sales.CustomerTransactions Transactions1 on Transactions1.InvoiceID = Invoices1.InvoiceID
join Sales.Customers Customers1 on Invoices1.CustomerID = Customers1.CustomerID
where DATEPART(year, Transactions1.TransactionDate) >= 2015
order by Customers1.CustomerName, Invoices1.InvoiceID

SET STATISTICS TIME OFF;

 --����� ������ SQL Server:
 --  ����� �� = 219 ��, ����������� ����� = 428 ��.

--��� ������� �������� 
SET STATISTICS TIME ON;
select Invoices1.InvoiceID,
	   Customers1.CustomerName,
	   Invoices1.InvoiceDate,
	   Transactions1.TransactionAmount,
	   (select SUM(Transactions.TransactionAmount)
		from Sales.Invoices Invoices
		join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
		join Sales.Customers Customers on Invoices.CustomerID = Customers.CustomerID
		where Customers.CustomerID = Customers1.CustomerID
			and DATEPART(year, Transactions.TransactionDate) >= 2015
			and DATEPART(month, Transactions.TransactionDate) = DATEPART(month, Transactions1.TransactionDate)
			and DATEPART(year, Transactions.TransactionDate) = DATEPART(year, Transactions1.TransactionDate)
		group by Customers.CustomerID) as TotalSum
from Sales.Invoices Invoices1
join Sales.CustomerTransactions Transactions1 on Transactions1.InvoiceID = Invoices1.InvoiceID
join Sales.Customers Customers1 on Invoices1.CustomerID = Customers1.CustomerID
where DATEPART(year, Transactions1.TransactionDate) >= 2015
order by Customers1.CustomerName, Invoices1.InvoiceID

SET STATISTICS TIME OFF;

 --����� ������ SQL Server:
 --  ����� �� = 36250 ��, ����������� ����� = 36786 ��.


 --�����: � ������� �������� ������ �������� �������

/*
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
*/

select 
	b.Month as [�����],
	b.StockItemName as [�������� ������],
	b.Quantity as [���-��]
from (select a.*,
	  row_number() over (partition by a.Month order by a.[Quantity] desc) as [Count]
from (
	select distinct month(Transactions.TransactionDate) as [Month],	
					Stock.StockItemName,
					SUM(Invoice.Quantity) over (partition by month(ct.TransactionDate), si.StockItemName) as [Quantity]
from Sales.InvoiceLines Invoice
join Sales.CustomerTransactions Transactions ON Invoice.InvoiceID = Transactions.InvoiceID
join Warehouse.StockItems Stock ON Invoice.StockItemID = Stock.StockItemID
where year(Transactions.TransactionDate) = 2016) as a 
) as b
where [Count] <= 2
order by b.Month, b.Quantity desc


/*
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
* ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
* ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
* ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
* ���������� �� ������ � ��� �� �������� ����������� (�� �����)
* �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
* ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��

��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
*/

--* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
select row_number() over (partition by left(StockItemName, 1) order by StockItemName),
	   StockItemID as [�� ������],
	   StockItemName as [�������� ������],
	   Brand as [�����],
	   UnitPrice as [����]
from Warehouse.StockItems

--* ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
select row_number() over (partition by left(StockItemName, 1) order by StockItemName),
	   StockItems.StockItemID as [�� ������],
	   StockItems.StockItemName as [�������� ������],
	   StockItems.Brand as [�����],
	   StockItems.UnitPrice as [����],
	   SUM(StockItemHoldings.QuantityOnHand) over (partition by StockItems.StockItemName) as [QuantityStockItem]
from Warehouse.StockItems StockItems
join Warehouse.StockItemHoldings StockItemHoldings ON StockItems.StockItemID = StockItemHoldings.StockItemID

--* ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
select distinct left(StockItems.StockItemName, 1),
	   SUM(StockItemHoldings.QuantityOnHand) over (partition by left(StockItems.StockItemName, 1) order by left(StockItems.StockItemName, 1)) as [���-�� ������]
from Warehouse.StockItems StockItems
join Warehouse.StockItemHoldings StockItemHoldings ON StockItems.StockItemID = StockItemHoldings.StockItemID;

--* ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
select StockItemID,
	   StockItemName,
	   lead(StockItemID) over (order by StockItemName)
from Warehouse.StockItems si

--* ���������� �� ������ � ��� �� �������� ����������� (�� �����)
select SI.StockItemID
	,si.StockItemName
	,lag(si.StockItemID) over (
		order by si.StockItemName
		) as [PreviousStockItemID]
from Warehouse.StockItems si

--* �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
select StockItemID,
       StockItemName,
	   isnull(lag(StockItemName, 2) over (order by StockItemName), 'No items')
from Warehouse.StockItems

--* ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
select StockItemID,
	   StockItemName,
	   TypicalWeightPerUnit,
	   ntile(30) over (order by TypicalWeightPerUnit)
from Warehouse.StockItems

/*
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
   � ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/

select a.SalespersonPersonID,
	   a.FullName,
	   Customers.CustomerID,
	   Customers.CustomerName,
	   Transactions1.TransactionDate,
	   Transactions1.TransactionAmount
from (select distinct Orders.SalespersonPersonID,
					  People.FullName,
					  max(Transactions.CustomerTransactionID) over (partition by Orders.SalespersonPersonID) as [TransactionID]
from Application.People People
join Sales.Orders Orders ON People.PersonID = Orders.SalespersonPersonID
join Sales.Invoices Invoices ON Orders.OrderID = Invoices.OrderID
join Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions.InvoiceID) as a
join Sales.CustomerTransactions Transactions1 ON a.TransactionID = Transactions1.CustomerTransactionID
join Sales.Invoices Invoices1 ON Transactions1.InvoiceID = Invoices1.InvoiceID
join Sales.Customers Customers ON Invoices1.CustomerID = Customers.CustomerID
order by a.SalespersonPersonID


/*
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/
--����������� ������ ��� ������� ������� ��� ������� ������� ������� ������� �������� � �������� ��������� � �������� �� ������������������. 

select distinct a.CustomerID
	,a.CustomerName
	,a.StockItemID
	,a.UnitPrice
	,a.[����]
from (
	select Customers.CustomerID,
		   Customers.CustomerName,
		   StockItems.StockItemID,
		   StockItems.UnitPrice,
		   max(Transactions .TransactionDate) over (partition by Customers.CustomerID, StockItems.StockItemID) as [����], 
		   dense_rank() over (partition by Customers.CustomerID order by StockItems.UnitPrice desc) as [Count]
	from Sales.Orders Orders
	 join Sales.OrderLines OrderLines ON Orders.OrderID = OrderLines.OrderID
	 join Warehouse.StockItems StockItems ON OrderLines.StockItemID = StockItems.StockItemID
	 join Sales.Invoices Invoices ON Orders.OrderID = Invoices.OrderID
	 join Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions .InvoiceID
	 join Sales.Customers Customers ON Orders.CustomerID = Customers.CustomerID
	) a
where a.Count <= 2
order by a.CustomerID, a.UnitPrice desc


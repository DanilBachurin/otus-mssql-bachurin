

/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".
*/
------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/


select 
	item.StockItemID as [�� ������], 
	item.StockItemName as [������������ ������]
	from Warehouse.StockItems item
where item.StockItemName like '%urgent%' 
	or item.StockItemName like 'Animal%'

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

select 
	sup.SupplierID as [�� ����������], 
	sup.SupplierName as [������������ ����������]
from Purchasing.Suppliers sup
LEFT OUTER JOIN Purchasing.PurchaseOrders pur on pur.SupplierID = sup.SupplierID
where pur.PurchaseOrderID is null


/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.
���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).
�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
SELECT DISTINCT Orders.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [���� ������]
	,datename(month, CustomerTransactions.TransactionDate) AS [�������� ������]
	,datepart(quarter, CustomerTransactions.TransactionDate) AS [����� ��������]
	,CASE 
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (1, 2, 3, 4) THEN 1
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (5, 6, 7, 8) THEN 2
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (9, 10, 11, 12)	THEN 3
	 END AS [����� ����]
	,Customers.CustomerName AS [��� ���������]
FROM Sales.Orders Orders
INNER JOIN Sales.Invoices Invoices ON Orders.OrderID = Invoices.OrderID
INNER JOIN Sales.CustomerTransactions CustomerTransactions ON Invoices.InvoiceID = CustomerTransactions.InvoiceID
INNER JOIN Sales.InvoiceLines InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
INNER JOIN Sales.Customers Customers ON Orders.CustomerID = Customers.CustomerID
WHERE (
		InvoiceLines.UnitPrice > 100
		OR Orders.OrderID IN (
			SELECT dt.OrderID
			FROM (
				SELECT so.OrderID
					,count(sol.OrderLineID) AS [OrderLinesQuantity]
				FROM Sales.Orders so
				INNER JOIN Sales.OrderLines sol ON sol.OrderID = so.OrderID
				GROUP BY so.OrderID
				HAVING count(sol.OrderLineID) > 20
				) dt
			)
		)
	AND CustomerTransactions.TransactionDate IS NOT NULL
	AND Orders.PickingCompletedWhen IS NOT NULL
ORDER BY [����� ��������]
	,[����� ����]
	,[���� ������] ASC

-- � ������������ ��������
SELECT DISTINCT Orders.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [���� ������]
	,datename(month, CustomerTransactions.TransactionDate) AS [�������� ������]
	,datepart(quarter, CustomerTransactions.TransactionDate) AS [����� ��������]
	,CASE 
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (1,2,3,4) THEN 1
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (5,6,7,8) THEN 2
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (9, 10, 11, 12)THEN 3
	 END AS [����� ����]
	,Customers.CustomerName AS [��� ���������]
FROM Sales.Orders Orders
INNER JOIN Sales.Invoices Invoices ON Orders.OrderID = Invoices.OrderID
INNER JOIN Sales.CustomerTransactions CustomerTransactions ON Invoices.InvoiceID = CustomerTransactions.InvoiceID
INNER JOIN Sales.InvoiceLines InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
INNER JOIN Sales.Customers Customers ON Orders.CustomerID = Customers.CustomerID
WHERE (
		InvoiceLines.UnitPrice > 100
		OR Orders.OrderID IN (
			SELECT a.OrderID
			FROM (
				SELECT o.OrderID
					,count(OrderLines.OrderLineID) AS [OrderLinesQuantity]
				FROM Sales.Orders o
				INNER JOIN Sales.OrderLines OrderLines ON OrderLines.OrderID = o.OrderID
				GROUP BY Orders.OrderID
				HAVING count(OrderLines.OrderLineID) > 20
				) a
			)
		)
	AND CustomerTransactions.TransactionDate IS NOT NULL
	AND Orders.PickingCompletedWhen IS NOT NULL
ORDER BY [����� ��������]
	,[����� ����]
	,[���� ������] ASC OFFSET 1000 ROWS
FETCH NEXT 1000 ROWS ONLY




/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/


select  DeliveryMethods.DeliveryMethodName as [������ ��������], 
		PurchaseOrders.ExpectedDeliveryDate as [���� ��������],
		Suppliers.SupplierName as [��� ����������], 
		People.FullName as [��� ����������� ���� ������������ �����]
from Purchasing.PurchaseOrders PurchaseOrders
LEFT OUTER JOIN Purchasing.Suppliers Suppliers on PurchaseOrders.SupplierID = Suppliers.SupplierID
INNER JOIN Application.DeliveryMethods DeliveryMethods on DeliveryMethods.DeliveryMethodID = PurchaseOrders.DeliveryMethodID
LEFT OUTER JOIN Application.People People on People.PersonID = PurchaseOrders.LastEditedBy
where DATEPART(YEAR, PurchaseOrders.ExpectedDeliveryDate) = 2013 
and DATEPART(MONTH, PurchaseOrders.ExpectedDeliveryDate) = 01
and (DeliveryMethods.DeliveryMethodName = 'Air Freight' 
	 or DeliveryMethods.DeliveryMethodName = 'Refrigerated Air Freight')
and PurchaseOrders.IsOrderFinalized = 1




/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

SELECT TOP 10 
	 Customers.CustomerName AS [��� ����������],
	 People.FullName AS [��� ��������]
FROM Sales.Orders AS Orders
LEFT OUTER JOIN Sales.Customers Customers ON Orders.CustomerID = Customers.CustomerID
LEFT OUTER JOIN Application.People People ON Orders.SalespersonPersonID = People.PersonID
ORDER BY Orders.OrderID DESC


/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/

SELECT DISTINCT 
	 Customers.CustomerID as [��]
	,Customers.CustomerName as [��� �������]
	,Customers.PhoneNumber as [����� ��������]
FROM Warehouse.StockItems StockItems
INNER JOIN Sales.OrderLines sol ON StockItems.StockItemID = sol.StockItemID
INNER JOIN Sales.Orders Orders ON sol.OrderID = Orders.OrderID
INNER JOIN Sales.Customers Customers ON Customers.CustomerID = Orders.CustomerID
WHERE StockItems.StockItemID in (SELECT StockItemID
								 FROM Warehouse.StockItems StockItems
								 WHERE StockItems.StockItemName = 'Chocolate frogs 250g'
								)
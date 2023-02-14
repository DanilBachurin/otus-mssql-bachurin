

/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
*/
------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/


select 
	item.StockItemID as [ИД товара], 
	item.StockItemName as [Наименование товара]
	from Warehouse.StockItems item
where item.StockItemName like '%urgent%' 
	or item.StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select 
	sup.SupplierID as [ИД поставщика], 
	sup.SupplierName as [Наименование поставщика]
from Purchasing.Suppliers sup
LEFT OUTER JOIN Purchasing.PurchaseOrders pur on pur.SupplierID = sup.SupplierID
where pur.PurchaseOrderID is null


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
SELECT DISTINCT Orders.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [дата заказа]
	,datename(month, CustomerTransactions.TransactionDate) AS [название месяца]
	,datepart(quarter, CustomerTransactions.TransactionDate) AS [номер квартала]
	,CASE 
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (1, 2, 3, 4) THEN 1
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (5, 6, 7, 8) THEN 2
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (9, 10, 11, 12)	THEN 3
	 END AS [треть года]
	,Customers.CustomerName AS [имя заказчика]
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
ORDER BY [номер квартала]
	,[треть года]
	,[дата заказа] ASC

-- С постраничной выборкой
SELECT DISTINCT Orders.OrderID
	,CONVERT(VARCHAR, OrderDate, 104) AS [дата заказа]
	,datename(month, CustomerTransactions.TransactionDate) AS [название месяца]
	,datepart(quarter, CustomerTransactions.TransactionDate) AS [номер квартала]
	,CASE 
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (1,2,3,4) THEN 1
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (5,6,7,8) THEN 2
		WHEN MONTH(CustomerTransactions.TransactionDate) IN (9, 10, 11, 12)THEN 3
	 END AS [треть года]
	,Customers.CustomerName AS [имя заказчика]
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
ORDER BY [номер квартала]
	,[треть года]
	,[дата заказа] ASC OFFSET 1000 ROWS
FETCH NEXT 1000 ROWS ONLY




/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/


select  DeliveryMethods.DeliveryMethodName as [Способ доставки], 
		PurchaseOrders.ExpectedDeliveryDate as [Дата доставки],
		Suppliers.SupplierName as [Имя поставщика], 
		People.FullName as [Имя контактного лица принимавшего заказ]
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
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10 
	 Customers.CustomerName AS [Имя сотрудника],
	 People.FullName AS [Имя продавца]
FROM Sales.Orders AS Orders
LEFT OUTER JOIN Sales.Customers Customers ON Orders.CustomerID = Customers.CustomerID
LEFT OUTER JOIN Application.People People ON Orders.SalespersonPersonID = People.PersonID
ORDER BY Orders.OrderID DESC


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT 
	 Customers.CustomerID as [ИД]
	,Customers.CustomerName as [Имя клиенка]
	,Customers.PhoneNumber as [Номер телефона]
FROM Warehouse.StockItems StockItems
INNER JOIN Sales.OrderLines sol ON StockItems.StockItemID = sol.StockItemID
INNER JOIN Sales.Orders Orders ON sol.OrderID = Orders.OrderID
INNER JOIN Sales.Customers Customers ON Customers.CustomerID = Orders.CustomerID
WHERE StockItems.StockItemID in (SELECT StockItemID
								 FROM Warehouse.StockItems StockItems
								 WHERE StockItems.StockItemName = 'Chocolate frogs 250g'
								)
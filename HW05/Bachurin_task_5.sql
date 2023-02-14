/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "03 - Подзапросы, CTE, временные таблицы".
Задания выполняются с использованием базы данных WideWorldImporters.
Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

--1) Вложеныый запрос; 
select 
	PersonID as [ИД],
	FullName as [Полное имя]
from Application.People People
where People.IsSalesPerson = 1 and People.PersonID not in (select distinct Invoices.SalespersonPersonID
														   from Sales.Invoices Invoices
														   join Sales.CustomerTransactions Transactions on Invoices.InvoiceID = Transactions.InvoiceID
														   join Sales.OrderLines OrderLines on Invoices.OrderID = OrderLines.OrderID
														   where DATEPART(YEAR, Transactions.TransactionDate) = 2015
														   and DATEPART(MONTH, Transactions.TransactionDate) = 7
														   and DATEPART(DAY, Transactions.TransactionDate) = 4)

--2) Через WITH.
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
	PersonID as [ИД],
	FullName as [Полное имя]
from cte as c
right join Application.People People on People.PersonID = c.SalespersonPersonID
where IsSalesPerson = 1 AND SalespersonPersonID IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

--1.1) Вложеныый запрос; 

select
	StockItemID as [ИД товара],
	StockItemName as [наименование товара],
	UnitPrice as [цена]
from Warehouse.StockItems StockItems
where UnitPrice = (select min(UnitPrice)
				   from Warehouse.StockItems)

--1.2) Вложеныый запрос; 

select 	
	StockItemID as [ИД товара],
	StockItemName as [наименование товара],
	UnitPrice as [цена]
from Warehouse.StockItems StockItems
join (select min(UnitPrice) as MinUnitPrice
	  from Warehouse.StockItems) 
	  minPrice ON StockItems.UnitPrice = minPrice.MinUnitPrice

--2) Через WITH.

WITH cte
as (select min(UnitPrice) as MinUnitPrice
	from Warehouse.StockItems)
select 
	StockItemID as [ИД товара],
	StockItemName as [наименование товара],
	UnitPrice as [цена]
from cte as c
join Warehouse.StockItems as StockItems on StockItems.UnitPrice = C.MinUnitPrice
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

--1.1) Вложеныый запрос; 

select distinct 
	Customers.CustomerName [ФИО]
from (
	select top 5 Transactions.CustomerID
	from Sales.CustomerTransactions Transactions
	order by Transactions.TransactionAmount DESC
	) a
join Sales.Customers Customers ON a.CustomerID = Customers.CustomerID

--1.2) Вложеныый запрос; 

select distinct 
	Customers.CustomerName [ФИО]
from Sales.Customers
where CustomerID IN (select top  5 CustomerID
					 from Sales.CustomerTransactions
					 order by TransactionAmount DESC)

--2) Через WITH.

WITH cte
as (select top 5 CustomerID
	from Sales.CustomerTransactions
	order by TransactionAmount desc)
select distinct 
	Customers.CustomerName [ФИО]
from Sales.Customers Customers
JOIN cte as c on Customers.CustomerID = c.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

--1) Вложеныый запрос; 

select 
	Cities.CityID as [ид города],
	Cities.CityName as [Название города],
	People.FullName as [Имя сотрудника]
from
(select top 3 StockItemID
from Warehouse.StockItems 
order by UnitPrice desc) Stock
join Sales.OrderLines OrderLines on Stock.StockItemID = OrderLines.StockItemID
join Sales.Orders Orders on OrderLines.OrderID = Orders.OrderID
join Sales.Customers Customers on Orders.CustomerID = Customers.CustomerID
join Application.People People on Orders.PickedByPersonID = People.PersonID
join Application.Cities Cities on Customers.DeliveryCityID = Cities.CityID

--2) Через WITH.
WITH cte as (select top 3 StockItemID
			 from Warehouse.StockItems
			 order by UnitPrice DESC)
select distinct 
	Cities.CityID as [ид города],
	Cities.CityName as [Название города],
	People.FullName as [Имя сотрудника]
from cte AS stock
join Sales.OrderLines OrderLines on stock.StockItemID = OrderLines.StockItemID
join Sales.Orders Orders on OrderLines.OrderID = Orders.OrderID
join Sales.Customers Customers on Orders.CustomerID = Customers.CustomerID
join Application.People People on Orders.PickedByPersonID = People.PersonID
join Application.Cities Cities on Customers.DeliveryCityID = Cities.CityID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос
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


 --Время работы SQL Server:
 --  Время ЦП = 221 мс, затраченное время = 45 мс.


-- --
--1. Повышенна читаемость запроса;
--2. Подзапрос заменен на  WITH;
--3. Из select перенес в from подзапрос

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


 --Время работы SQL Server: 
 --  Время ЦП = 47 мс, затраченное время = 41 мс.
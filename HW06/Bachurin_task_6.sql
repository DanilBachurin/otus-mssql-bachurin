/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
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
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

--с оконной функцией 


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

 --Время работы SQL Server:
 --  Время ЦП = 219 мс, затраченное время = 428 мс.

--без оконной функцией 
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

 --Время работы SQL Server:
 --  Время ЦП = 36250 мс, затраченное время = 36786 мс.


 --Вывод: С оконной функцией селект работает быстрее

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select 
	b.Month as [Месяц],
	b.StockItemName as [Название товара],
	b.Quantity as [Кол-во]
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
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

--* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
select row_number() over (partition by left(StockItemName, 1) order by StockItemName),
	   StockItemID as [ид товара],
	   StockItemName as [Название товара],
	   Brand as [Брэнд],
	   UnitPrice as [Цена]
from Warehouse.StockItems

--* посчитайте общее количество товаров и выведете полем в этом же запросе
select row_number() over (partition by left(StockItemName, 1) order by StockItemName),
	   StockItems.StockItemID as [ид товара],
	   StockItems.StockItemName as [Название товара],
	   StockItems.Brand as [Брэнд],
	   StockItems.UnitPrice as [Цена],
	   SUM(StockItemHoldings.QuantityOnHand) over (partition by StockItems.StockItemName) as [QuantityStockItem]
from Warehouse.StockItems StockItems
join Warehouse.StockItemHoldings StockItemHoldings ON StockItems.StockItemID = StockItemHoldings.StockItemID

--* посчитайте общее количество товаров в зависимости от первой буквы названия товара
select distinct left(StockItems.StockItemName, 1),
	   SUM(StockItemHoldings.QuantityOnHand) over (partition by left(StockItems.StockItemName, 1) order by left(StockItems.StockItemName, 1)) as [Кол-во товара]
from Warehouse.StockItems StockItems
join Warehouse.StockItemHoldings StockItemHoldings ON StockItems.StockItemID = StockItemHoldings.StockItemID;

--* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
select StockItemID,
	   StockItemName,
	   lead(StockItemID) over (order by StockItemName)
from Warehouse.StockItems si

--* предыдущий ид товара с тем же порядком отображения (по имени)
select SI.StockItemID
	,si.StockItemName
	,lag(si.StockItemID) over (
		order by si.StockItemName
		) as [PreviousStockItemID]
from Warehouse.StockItems si

--* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
select StockItemID,
       StockItemName,
	   isnull(lag(StockItemName, 2) over (order by StockItemName), 'No items')
from Warehouse.StockItems

--* сформируйте 30 групп товаров по полю вес товара на 1 шт
select StockItemID,
	   StockItemName,
	   TypicalWeightPerUnit,
	   ntile(30) over (order by TypicalWeightPerUnit)
from Warehouse.StockItems

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
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
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 

select distinct a.CustomerID
	,a.CustomerName
	,a.StockItemID
	,a.UnitPrice
	,a.[Дата]
from (
	select Customers.CustomerID,
		   Customers.CustomerName,
		   StockItems.StockItemID,
		   StockItems.UnitPrice,
		   max(Transactions .TransactionDate) over (partition by Customers.CustomerID, StockItems.StockItemID) as [Дата], 
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


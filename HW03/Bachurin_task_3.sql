/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".
Задания выполняются с использованием базы данных WideWorldImporters.
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	DATEPART(YEAR, Invoices.InvoiceDate) AS [Год продажи],
	DATEPART(MONTH, Invoices.InvoiceDate) AS [Месяц продажи],
	AVG(OrderLines.UnitPrice) AS [Средняя цена за месяц],
	SUM(Transactions.TransactionAmount) AS [Сумма за месяц]
FROM Sales.Invoices Invoices
INNER JOIN Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions.InvoiceID
INNER JOIN Sales.OrderLines OrderLines ON Invoices.OrderID = OrderLines.OrderID
GROUP BY DATEPART(MONTH, Invoices.InvoiceDate), DATEPART(YEAR, Invoices.InvoiceDate)
ORDER BY [Год продажи], [Месяц продажи]


/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	DATEPART(YEAR, Invoices.InvoiceDate) AS [Год продажи],
	DATEPART(MONTH, Invoices.InvoiceDate) AS [Месяц продажи],
	SUM(Transactions.TransactionAmount) AS [Сумма]
FROM Sales.Invoices Invoices
INNER JOIN Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions.InvoiceID
INNER JOIN Sales.OrderLines OrderLines ON Invoices.OrderID = OrderLines.OrderID
GROUP BY DATEPART(YEAR, Invoices.InvoiceDate), DATEPART(MONTH, Invoices.InvoiceDate)
HAVING SUM(Transactions.TransactionAmount) >  4600000



/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.
Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

-- напишите здесь свое решение

SELECT 
	DATEPART(YEAR, Transactions.TransactionDate) AS [Год продажи],
	DATEPART(MONTH, Transactions.TransactionDate) AS [Месяц продажи],
	StockItems.StockItemName AS [Название товара],
	SUM(Transactions.TransactionAmount) AS [Сумма продаж],
	MIN(Transactions.TransactionDate) AS [Дата первой продажи],
	COUNT(InvoiceLines.Quantity) AS [Кол-во проданного]
FROM Sales.InvoiceLines InvoiceLines
INNER JOIN Warehouse.StockItems StockItems ON InvoiceLines.StockItemID = StockItems.StockItemID
INNER JOIN Sales.CustomerTransactions Transactions ON InvoiceLines.InvoiceID = Transactions.InvoiceID
GROUP BY StockItems.StockItemName
	,DATEPART(YEAR, Transactions.TransactionDate)
	,DATEPART(MONTH, Transactions.TransactionDate)
HAVING COUNT(InvoiceLines.Quantity) < 50
ORDER BY [Год продажи], [Месяц продажи]



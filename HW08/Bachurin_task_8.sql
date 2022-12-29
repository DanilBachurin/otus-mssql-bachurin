--/*
--Домашнее задание по курсу MS SQL Server Developer в OTUS.
--Занятие "07 - Динамический SQL".
--Задания выполняются с использованием базы данных WideWorldImporters.
--Бэкап БД можно скачать отсюда:
--https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
--Нужен WideWorldImporters-Full.bak
--Описание WideWorldImporters от Microsoft:
--* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
--* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
--*/
---- ---------------------------------------------------------------------------
---- Задание - написать выборки для получения указанных ниже данных.
---- ---------------------------------------------------------------------------
--USE WideWorldImporters

/*
Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.
Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.
Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


declare @str as varchar(MAX) = '',
		@Dsql as varchar(MAX) = ''

select @str = @str + + CustomerName
from (select distinct CustomerName = QUOTENAME(replace(replace(CustomerName, left(CustomerName, charindex('(', CustomerName, 0)), ''), ')', '')) + ','
from Sales.Customers) as g 

select @str = substring(@str, 0, len(@str))


SET @Dsql = 'select p.*
from (
	select OrderDate = FORMAT(CAST(CAST(YEAR([OrderDate]) as varchar) + ''-'' + CAST(MONTH([OrderDate]) as varchar )+ ''-01'' as DATE), ''d'', ''de-de'') ,
		   CustomerName = replace(replace([CustomerName], left([CustomerName], charindex(''('', [CustomerName], 0)), ''''), '')'', ''''),
		   OrderID
	from [Sales].[Customers] Customers
	cross apply (
		select [OrderDate] = CONVERT(varchar, OrderDate, 104),
			   Orders.[OrderID]
		from Sales.Orders Orders
		JOIN Sales.Invoices Invoices on Orders.OrderID = Invoices.OrderID
		where exists (select Transactions.CustomerTransactionID
					  from Sales.CustomerTransactions Transactions
					  where Transactions.InvoiceID = Invoices.InvoiceID)
					  and Customers.CustomerID = Orders.CustomerID) a
				) b
pivot 
(
    count(OrderID) for CustomerName in (' + @str + ')
) p
order by cast(OrderDate as date)'

exec (@Dsql)
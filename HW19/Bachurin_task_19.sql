/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".
Задания выполняются с использованием базы данных WideWorldImporters.
Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters
 go
/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
 
create or alter function CustomerNameWithMaxSum  ()
returns nvarchar(100)
as
begin 
	declare @CustomerName nvarchar(100);

	select top 1 @CustomerName = CustomerName
	from Sales.Orders so
	inner join Sales.Invoices si ON so.OrderID = si.OrderID
	inner join Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	inner join Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	inner join Sales.Customers c ON so.CustomerID = c.CustomerID
	group by CustomerName
	order by SUM(TransactionAmount) DESC
	  
	return @CustomerName

end


select dbo.CustomerNameWithMaxSum()

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/


create or alter procedure SumAmountForCustomerName
	@CustomerName nvarchar(100),
	@TransactionAmount decimal(18,2) OUTPUT
as
begin

	set nocount on;

	select @TransactionAmount = SUM(TransactionAmount)
	from Sales.Orders so
	inner join Sales.Invoices si ON so.OrderID = si.OrderID
	inner join Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	inner join Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	inner join Sales.Customers c ON so.CustomerID = c.CustomerID
	group by CustomerName 
	having CustomerName = @CustomerName
	order by SUM(TransactionAmount) DESC 

end

 
declare @sum decimal(25, 6),
		@CustomerName nvarchar(100); 

select @CustomerName = CustomerName 
from Sales.Customers
where CustomerName like '%Tailspin Toys (Great Neck Estates, NY)%' 

exec SumAmountForCustomerName
@CustomerName = @CustomerName,
@TransactionAmount = @sum OUTPUT

select @sum

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

/*
Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/ 
 
create or alter procedure SumAmountInvoices
	@Sum decimal(18,2)  
as
begin
	select DATEPART(YEAR,ct.TransactionDate) as YearTransactionDate,
		   DATEPART(MONTH,ct.TransactionDate) as MonthTransactionDate, 
		   SUM(ct.TransactionAmount) as SUM_Sales
	from Sales.Invoices i
	inner join Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	inner join Sales.OrderLines ol ON i.OrderID = ol.OrderID
	group by DATEPART(YEAR,ct.TransactionDate),
		DATEPART(MONTH,ct.TransactionDate) 
	having SUM(ct.TransactionAmount) > @Sum
	order by YearTransactionDate, MonthTransactionDate

end


create or alter function  fn_SumAmountInvoices 
(	
	@Sum decimal(18,2)
)
returns TABLE 
as
return 
(
	select DATEPART(YEAR,ct.TransactionDate) as YearTransactionDate,
			DATEPART(MONTH,ct.TransactionDate) as MonthTransactionDate, 
			SUM(ct.TransactionAmount) as SUM_Sales
	from Sales.Invoices i
	inner join Sales.CustomerTransactions ct ON i.InvoiceID = ct.InvoiceID
	inner join Sales.OrderLines ol ON i.OrderID = ol.OrderID
	group by DATEPART(YEAR,ct.TransactionDate),
		DATEPART(MONTH,ct.TransactionDate) 
	having SUM(ct.TransactionAmount) > @Sum 
)


SET STATISTICS TIME ON
declare @Sum DECIMAL(25, 6) = 4600000
select * 
from fn_SumAmountInvoices (@Sum)
order by YearTransactionDate, 
		 MonthTransactionDate
SET STATISTICS TIME OFF
go
/*
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(41 rows affected)

 Время работы SQL Server:
   Время ЦП = 62 мс, затраченное время = 64 мс.
*/
 
SET STATISTICS TIME ON
declare @Sum DECIMAL(18,2) = 4600000
EXEC SumAmountInvoices @Sum = @Sum
SET STATISTICS TIME OFF

/*
 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

(41 rows affected)

 Время работы SQL Server:
   Время ЦП = 47 мс, затраченное время = 55 мс.

 Время работы SQL Server:
   Время ЦП = 47 мс, затраченное время = 55 мс.
*/

--Функции работают быстрее, оптимизатор может переписывать и оптимизировать запросы при использованием функций.


/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
 
 
create or alter function CustomerTotalAmount
(
    @CustomerID INT
)
returns table
as
return
(
    select  SUM(TransactionAmount) as TotalAmount
	from Sales.Orders so
	inner join Sales.Invoices si ON so.OrderID = si.OrderID
	inner join Sales.CustomerTransactions sct ON si.InvoiceID = sct.InvoiceID
	inner join Sales.InvoiceLines sil ON si.InvoiceID = sil.InvoiceID
	inner join Sales.Customers c ON so.CustomerID = c.CustomerID
	group by  c.CustomerID 
	having c.CustomerID = @CustomerID
)

select CustomerName, cta.TotalAmount
from Sales.Customers c
CROSS APPLY CustomerTotalAmount(c.CustomerID) as cta


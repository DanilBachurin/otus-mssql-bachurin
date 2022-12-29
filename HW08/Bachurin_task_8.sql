--/*
--�������� ������� �� ����� MS SQL Server Developer � OTUS.
--������� "07 - ������������ SQL".
--������� ����������� � �������������� ���� ������ WideWorldImporters.
--����� �� ����� ������� ������:
--https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
--����� WideWorldImporters-Full.bak
--�������� WideWorldImporters �� Microsoft:
--* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
--* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
--*/
---- ---------------------------------------------------------------------------
---- ������� - �������� ������� ��� ��������� ��������� ���� ������.
---- ---------------------------------------------------------------------------
--USE WideWorldImporters

/*
��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.
��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
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
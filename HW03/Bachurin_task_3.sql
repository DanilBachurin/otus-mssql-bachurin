/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, GROUP BY, HAVING".
������� ����������� � �������������� ���� ������ WideWorldImporters.
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT 
	DATEPART(YEAR, Invoices.InvoiceDate) AS [��� �������],
	DATEPART(MONTH, Invoices.InvoiceDate) AS [����� �������],
	AVG(OrderLines.UnitPrice) AS [������� ���� �� �����],
	SUM(Transactions.TransactionAmount) AS [����� �� �����]
FROM Sales.Invoices Invoices
INNER JOIN Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions.InvoiceID
INNER JOIN Sales.OrderLines OrderLines ON Invoices.OrderID = OrderLines.OrderID
GROUP BY DATEPART(MONTH, Invoices.InvoiceDate), DATEPART(YEAR, Invoices.InvoiceDate)
ORDER BY [��� �������], [����� �������]


/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT 
	DATEPART(YEAR, Invoices.InvoiceDate) AS [��� �������],
	DATEPART(MONTH, Invoices.InvoiceDate) AS [����� �������],
	SUM(Transactions.TransactionAmount) AS [�����]
FROM Sales.Invoices Invoices
INNER JOIN Sales.CustomerTransactions Transactions ON Invoices.InvoiceID = Transactions.InvoiceID
INNER JOIN Sales.OrderLines OrderLines ON Invoices.OrderID = OrderLines.OrderID
GROUP BY DATEPART(YEAR, Invoices.InvoiceDate), DATEPART(MONTH, Invoices.InvoiceDate)
HAVING SUM(Transactions.TransactionAmount) >  4600000



/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.
�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

-- �������� ����� ���� �������

SELECT 
	DATEPART(YEAR, Transactions.TransactionDate) AS [��� �������],
	DATEPART(MONTH, Transactions.TransactionDate) AS [����� �������],
	StockItems.StockItemName AS [�������� ������],
	SUM(Transactions.TransactionAmount) AS [����� ������],
	MIN(Transactions.TransactionDate) AS [���� ������ �������],
	COUNT(InvoiceLines.Quantity) AS [���-�� ����������]
FROM Sales.InvoiceLines InvoiceLines
INNER JOIN Warehouse.StockItems StockItems ON InvoiceLines.StockItemID = StockItems.StockItemID
INNER JOIN Sales.CustomerTransactions Transactions ON InvoiceLines.InvoiceID = Transactions.InvoiceID
GROUP BY StockItems.StockItemName
	,DATEPART(YEAR, Transactions.TransactionDate)
	,DATEPART(MONTH, Transactions.TransactionDate)
HAVING COUNT(InvoiceLines.Quantity) < 50
ORDER BY [��� �������], [����� �������]



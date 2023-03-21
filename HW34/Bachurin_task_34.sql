/*
Цель:
В этом ДЗ вы выберете таблицу-кандидат для секционирования и научитесь добавлять партиционирование.
Описание/Пошаговая инструкция выполнения домашнего задания:
Выбираем в своем проекте таблицу-кандидат для секционирования и добавляем партиционирование.
Если в проекте нет такой таблицы, то делаем анализ базы данных из первого модуля, выбираем таблицу и делаем ее секционирование,
с переносом данных по секциям (партициям) - исходя из того, что таблица большая, пишем скрипты миграции в секционированную таблицу
*/



ALTER DATABASE PrivateMail
ADD FILEGROUP PrivateMail_FileGroup;
GO
ALTER DATABASE PrivateMail
ADD FILE
(
 NAME = PrivateMail_FileGroup_1,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PrivateMail_FileGroup_1.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
), 


( 
 NAME = PrivateMail_FileGroup_2,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateMail_FileGroup_2.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
) 
TO FILEGROUP PrivateMail_FileGroup;
GO


ALTER DATABASE PrivateMail
ADD FILEGROUP PrivateMail_FileGroup_2;
GO
ALTER DATABASE PrivateMail
ADD FILE
(
 NAME = PrivateMail_FileGroup_3,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateMail_FileGroup_3.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
), 
( 
 NAME = PrivateMail_FileGroup_4,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateMail_FileGroup_4.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
) 
TO FILEGROUP PrivateMail_FileGroup_2;
GO

ALTER DATABASE PrivateMail
ADD FILEGROUP PrivateMail_FileGroup_3;
GO
ALTER DATABASE PrivateMail
ADD FILE
(
 NAME = PrivateMail_FileGroup_5,
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateMail_FileGroup_5.ndf',
 SIZE = 5MB,
 MAXSIZE = 100MB,
 FILEGROWTH = 5MB
)
TO FILEGROUP PrivateMail_FileGroup_3;
GO


SELECT tid,		
	   SendingPoint_id,
	   ReceptionPoint_id,
	   PackageType_id,
	   Addressee_id,
	   Addresser_id,
	   Insurance_id,
	   Delivery_id,
	   DateDispatch,
	   Received,
	   Cost
FROM PrivateMail..Orders
 

create  partition function part (datetime) as range
for values ('20221101', '20221201')


create partition scheme pPrivateMail
as partition part 
to ([PrivateMail_FileGroup], [PrivateMail_FileGroup_2], [PrivateMail_FileGroup_FG_3]); 


SELECT name, physical_name,name
FROM sys.master_files
WHERE database_id = DB_ID('PrivateMail');
GO

CREATE NONCLUSTERED INDEX [ix_OrdersFG] ON [dbo].Orders
(
	[DateDispatch] ASC
)
INCLUDE([Addressee_id],[Addresser_id])  
ON pPrivateMail (recorddate)

--созданные индексы
SELECT 
	OBJECT_NAME(ps.[object_id]) AS [Имя таблицы],
	indx.[name] AS [Имя индекса],
	ps.[partition_id] AS [Идентификатор секции],
	ps.[partition_number] AS [Номер секции],
	ps.[in_row_data_page_count] AS [Количество страниц для хранения данных] 
FROM sys.dm_db_partition_stats ps
JOIN sys.indexes indx ON ps.object_id = indx.object_id
						 AND ps.index_id = indx.index_id
WHERE OBJECT_NAME(ps.object_id) = 'Orders'

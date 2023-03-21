/*
Цель:
В этом ДЗ вы поработаете с индексами.
Описание/Пошаговая инструкция выполнения домашнего задания:
Думаем какие запросы у вас будут в базе и добавляем для них индексы. Проверяем, что они используются в запросе.
*/


CREATE INDEX ix_Сlient_MiddleName ON dbo.Сlient (MiddleName)
INCLUDE (Number, Name, Surname)

CREATE INDEX ix_Citys_Country_id ON dbo.Citys (Country_id)
INCLUDE (NameCity, CityСode)

CREATE INDEX ix_Insurance_NameType ON dbo.Insurance (NameType)
INCLUDE (Cost)

-------------------------------------ЗАПРОСЫ-------------------------------------

select Number, Name, Surname
from Сlient 
where MiddleName Like '%Иванов%'

select NameCity, CityСode 
from Citys  
where Country_id = 154

select Cost
from Insurance  
where NameType = '%посылка%'

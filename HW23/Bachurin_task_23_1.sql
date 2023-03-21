alter VIEW v_OrdersBarcode
 AS 
 select d.Barcode as [Штрихкод]
 from Orders o
 join Delivery d on o.Delivery_id = d.tid 
  GO
 select * from v_OrdersBarcode
  GO

  select *
  from v_OrdersBarcode

CREATE VIEW v_Delivery
 AS 
 select c1.MiddleName as [Фамилия отправителя], 
		c1.Name as [Имя отправителя], 
		c1.Surname as [Отчетсво отправителя], 
		c2.MiddleName as [Фамилия получателя], 
		c2.Name as [Имя получателя], 
		c2.Surname as [Отчетсво получателя]
 from Orders o
 join Сlient c1 on o.Addressee_id = c1.tid 
 join Сlient c2 on o.Addresser_id = c2.tid 
  GO
 select * 
 from v_Delivery
  GO

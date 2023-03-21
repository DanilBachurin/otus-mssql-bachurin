alter VIEW v_OrdersBarcode
 AS 
 select d.Barcode as [��������]
 from Orders o
 join Delivery d on o.Delivery_id = d.tid 
  GO
 select * from v_OrdersBarcode
  GO

  select *
  from v_OrdersBarcode

CREATE VIEW v_Delivery
 AS 
 select c1.MiddleName as [������� �����������], 
		c1.Name as [��� �����������], 
		c1.Surname as [�������� �����������], 
		c2.MiddleName as [������� ����������], 
		c2.Name as [��� ����������], 
		c2.Surname as [�������� ����������]
 from Orders o
 join �lient c1 on o.Addressee_id = c1.tid 
 join �lient c2 on o.Addresser_id = c2.tid 
  GO
 select * 
 from v_Delivery
  GO

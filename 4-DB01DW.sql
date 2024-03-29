
-- Script que crea la base de datos DB01DW
------------------------------------------

-- 1. Crea la base de datos vacía DB01DW
----------------------------------------

-- Conecta con master
USE master;

-- borra la base de datos si existe
IF DB_ID('DB01DW') IS NOT NULL DROP DATABASE DB01DW;

-- si está abierta la conexión y no la puede abrir, aborta 
IF @@ERROR = 3702 
   RAISERROR('La base de datos no se puede crear porque está la conexión abierta.', 127, 127) WITH NOWAIT, LOG;

-- Crea DB01DW
CREATE DATABASE DB01DW;
GO

USE DB01DW;
GO


--2. Crea tablas
------------------------------
CREATE -- Dimensión Clientes
TABLE DimClientes
(	ClaveCliente int Not Null CONSTRAINT [pkDimClientes] PRIMARY KEY Identity(1,1)
	, clienteId int Not Null
	, nombreEmpresa nvarchar(40) Not NULL
	, nombreContacto nvarchar(30) Not NULL
	, ciudad nvarchar(15) Not NULL
	, pais nvarchar(15) Not NULL
);
go

CREATE -- Dimensión Productos  
TABLE DimProductos	
(	ClaveProducto int Not Null CONSTRAINT [pkDimProductos] PRIMARY KEY Identity(1,1)
	, productoId int Not Null 
	, productoNombre nvarchar(40) Not Null
	, categoriaId int Not Null
	, nombreCategoria nVarchar(50) Not Null
);
go

CREATE -- Dimensión Pedidos  
TABLE DimPedidos	
(	ClavePedido int Not Null CONSTRAINT [pkDimPedidos] PRIMARY KEY Identity(1,1)
	, pedidoId int Not Null 
	, productoId int Not Null
	, fechaPedido datetime Not NULL
	, fechaEntrega datetime Not NULL 
	, ciudadEnvio nvarchar(15) Not Null 
	, paisEnvio nvarchar(15) Not Null
	, precioUnitario money Not Null
	, cantidad smallint Not Null
	, descuento numeric(4,3) Not Null
);
go

CREATE -- Tabla de Hechos primaria para el Data Mart Ventas
TABLE FactVentas
( ClavePedido int -- FK para DimPedidos
, ClaveCliente int -- FK para DimClientes
, ClaveProducto int -- FK para DimProductos
, cantidad smallint
, precio money
, descuento money
, CONSTRAINT [pkFactSales] PRIMARY KEY 
	(
	  ClavePedido
	, ClaveCliente
	, ClaveProducto
	)
);
go

-- Crear Constaints de Claves foraneas
--------------------------------------
ALTER TABLE dbo.FactVentas ADD CONSTRAINT 
	fkFactVentasADimPedidos FOREIGN KEY (ClavePedido) 
	REFERENCES dbo.DimPedidos (ClavePedido);
go

ALTER TABLE dbo.FactVentas ADD CONSTRAINT
	fkFactVentasADimProductos FOREIGN KEY (ClaveProducto) 
	REFERENCES dbo.DimProductos	(ClaveProducto);
go

ALTER TABLE dbo.FactVentas ADD CONSTRAINT 
	fkFactVentasADimClientes FOREIGN KEY (ClaveCliente) 
	REFERENCES dbo.DimClientes (ClaveCliente);
go

Select 'Versión 1 de la base de datos creada';
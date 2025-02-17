USE [TermProject];
GO

-- B1 Answer:
SELECT 
	OrderDetails.[OrderID],
	OrderDetails.[Quantity],
	Products.[ProductID],
	Products.[ReorderLevel],
	Suppliers.[SupplierID]
	FROM Products 
	JOIN OrderDetails
		ON OrderDetails.[ProductID] = Products.[ProductID]
	JOIN Suppliers
		ON Products.[SupplierID] = Suppliers.[SupplierID]
	WHERE Quantity BETWEEN 90 AND 100
	ORDER BY OrderDetails.[OrderID];
GO

-- B2 Answer:
SELECT ProductID, ProductName, EnglishName, FORMAT(UnitPrice, 'C', 'en-us') AS [UnitPrice] FROM Products
WHERE UnitPrice < 10
ORDER BY ProductID;
GO

-- B3 Answer:
SELECT CustomerID, CompanyName, Country, Phone FROM [TermProject].[dbo].[Customers] AS Customers
WHERE Country = 'Canada' OR Country = 'USA'
ORDER BY CompanyName; 
GO

-- B4 Answer: 
SELECT 
	Suppliers.[SupplierID],
	Suppliers.[Name],
	Products.[ProductName],
	Products.[ReorderLevel],
	Products.[UnitsInStock]
	FROM Products 
	JOIN Suppliers
	ON Products.[SupplierID] = Suppliers.[SupplierID]
	WHERE UnitsInStock > ReorderLevel AND UnitsInStock - ReorderLevel <= 10
	ORDER BY ProductName;
GO

-- B5 Answer: 
SELECT 
	Customers.[CompanyName],
	COUNT(Orders.[OrderID]) AS Amount
	FROM Orders
	JOIN Customers
	ON Customers.[CustomerID] = Orders.[CustomerID]
	WHERE month(OrderDate) = '12' AND year(OrderDate) = '1993'
	GROUP BY Customers.[CompanyName]
	ORDER BY CompanyName;
GO

-- B6 Answer: 
SELECT 
	TOP 10 Products.[ProductName],
	COUNT(Products.[ProductName]) AS Amount
	FROM Products 
	JOIN OrderDetails 
	ON OrderDetails.[ProductID] = Products.[ProductID]
	GROUP BY Products.[ProductName]
	ORDER BY Amount DESC;
GO


-- B7 Answer: 
SELECT 
	TOP 10 Products.[ProductName],
	SUM(OrderDetails.[Quantity]) AS Quantity
	FROM Products 
	JOIN OrderDetails 
	ON OrderDetails.[ProductID] = Products.[ProductID]
	GROUP BY ProductName
	ORDER BY Quantity DESC;
GO

-- B8 Answer:
SELECT 
	Orders.[OrderID],
	FORMAT(OrderDetails.[UnitPrice], 'C', 'en-us') AS [UnitPrice], 
	OrderDetails.[Quantity]
	FROM Orders
	JOIN OrderDetails
	ON OrderDetails.[OrderID] = Orders.[OrderID]
	WHERE ShipCity = 'Vancouver'
	ORDER BY OrderID;
GO

-- B9 Answer:
SELECT
	Customers.[CustomerID],
	Customers.[CompanyName],
	Orders.[OrderID],
	FORMAT(Orders.[OrderDate], 'MMMM dd, yyyy') AS [OrderDate]
	FROM Orders
	JOIN Customers
	ON Orders.[CustomerID] = Customers.[CustomerID]
	WHERE [ShippedDate] IS NULL
	ORDER BY CustomerID, OrderDate; 
GO

-- B10 Answer:
SELECT ProductID, ProductName, QuantityPerUnit, FORMAT(UnitPrice, 'C', 'en-us') AS [UnitPrice] FROM Products
WHERE ProductName like '%choc%' OR ProductName like '%chok%'
ORDER BY ProductName;
GO

-- B11 Answer:
SELECT SUBSTRING(ProductName, 1, 1) AS Character, COUNT(Products.[ProductName]) AS Total FROM Products 
GROUP BY SUBSTRING(ProductName, 1, 1)
HAVING COUNT(Products.[ProductName]) > 1;
GO


-- C1 Answer:
CREATE OR ALTER VIEW [dbo].[vProductsUnder10]
AS
SELECT
	p.[ProductName] AS [ProductName]
	, FORMAT(p.[UnitPrice], 'C', 'en-us') AS [UnitPrice]
	, suppliers.[SupplierID] AS [SupplierID]
	, suppliers.[Name] AS [Name]
FROM [TermProject].[dbo].[Products] AS p
JOIN [TermProject].[dbo].[Suppliers] AS suppliers
	ON p.[SupplierID] = suppliers.[SupplierID]
WHERE [UnitPrice] < 10;
GO

SELECT * FROM [TermProject].[dbo].[vProductsUnder10]
	ORDER BY [Name];
GO

-- C2 Answer:
CREATE OR ALTER VIEW [dbo].[vOrdersByEmployee]
AS
SELECT
	MAX(CONCAT(e.[FirstName], ' ', e.[LastName])) AS [Name]
	, COUNT(DISTINCT orders.[OrderID]) AS [Orders]
FROM [TermProject].[dbo].[Employees] AS e
JOIN [TermProject].[dbo].[Orders] AS orders
	ON orders.[EmployeeID] = e.[EmployeeID]
JOIN [TermProject].[dbo].[OrderDetails] AS od
	ON orders.[OrderID] = od.[OrderID]
GROUP BY e.[EmployeeID]; 
GO

SELECT * FROM [TermProject].[dbo].[vOrdersByEmployee]
ORDER BY [Orders] DESC;
GO

-- C3 Answer:
UPDATE [TermProject].[dbo].[Customers]
SET [Fax] = 'Unknown'
WHERE [Fax] IS NULL;
GO

SELECT @@ROWCOUNT AS [Rows Affected];
GO

-- C4 Answer:
CREATE OR ALTER VIEW [dbo].[vOrderCost]
AS
SELECT
	orders.[OrderID]
	, MAX(FORMAT(orders.[OrderDate], 'MMMM dd, yyyy')) AS [OrderDate]
	, MAX(customers.[CompanyName]) AS [CompanyName]
	, SUM((OrderDetails.[Quantity] * OrderDetails.[UnitPrice])) AS [OrderCost]
FROM [TermProject].[dbo].[Orders] AS orders
JOIN [TermProject].[dbo].[Customers] AS customers
	ON customers.[CustomerID] = orders.[CustomerID]
JOIN [TermProject].[dbo].[OrderDetails] AS OrderDetails
	ON orders.[OrderID] = OrderDetails.[OrderID]
GROUP BY orders.[OrderID];
GO

SELECT TOP(5) [OrderID]
		,[OrderDate]
		,[CompanyName]
		,FORMAT([OrderCost], 'C2') AS [Cost]
	FROM [TermProject].[dbo].[vOrderCost]
	ORDER BY [OrderCost] DESC;
GO

-- C5 Answer:
INSERT INTO [TermProject].[dbo].[Suppliers]
	(
	[SupplierID]
	, [Name]
	)
VALUES
	(
	16
	, 'Supplier P'
	);
GO

SELECT [SupplierID], [Name] FROM [TermProject].[dbo].[Suppliers]
WHERE [SupplierID] > 10
ORDER BY [SupplierID];
GO

-- C6 Answer: 
UPDATE [TermProject].[dbo].[Products]
SET [UnitPrice] = [UnitPrice] * 1.15
WHERE [UnitPrice] < 5;
GO 

SELECT @@ROWCOUNT AS [Rows Affected];
GO


-- D1 Answer:
CREATE OR ALTER FUNCTION CustomersByCountry(@country NVARCHAR(255))
RETURNS TABLE
AS
RETURN
	SELECT [CustomerID], [CompanyName], [City], [Address]
	FROM [TermProject].[dbo].[Customers]
	WHERE @country = [Country];
GO

SELECT * FROM [TermProject].[dbo].[CustomersByCountry]('Germany')
ORDER BY [CompanyName];
GO

-- D2 Answer:
CREATE OR ALTER FUNCTION ProductsInRange(@firstPrice INT, @secondPrice INT)
RETURNS TABLE
AS 
RETURN
	SELECT [ProductID], [ProductName], [EnglishName], FORMAT([UnitPrice], 'C', 'en-us') AS [UnitPrice]
	FROM [TermProject].[dbo].[Products] 
	WHERE @firstPrice <= [UnitPrice] AND [UnitPrice] <= @secondPrice;
GO

SELECT * FROM [TermProject].[dbo].[ProductsInRange](30, 50)
ORDER BY [UnitPrice];
GO

-- D3 Answer:
CREATE OR ALTER PROCEDURE EmployeeInfo(@empID INT)
AS
SELECT 
	[EmployeeID]
	, [LastName]
	, [FirstName]
	, [Address]
	, [City]
	, [Province]
	, [PostalCode]
	, [Phone]
	, DATEDIFF(yy, [BirthDate], '1994-01-01') AS [Age]
	FROM [TermProject].[dbo].[Employees]
	WHERE @empID = [EmployeeID];
GO

EXEC [TermProject].[dbo].[EmployeeInfo] 9;
GO

-- D4 Answer:
CREATE OR ALTER PROCEDURE CustomersByCity(@city NVARCHAR(255))
AS
SELECT [CustomerID], [CompanyName], [Address], [City], [Phone]
	FROM [TermProject].[dbo].[Customers]
	WHERE @city = [City]
	ORDER BY [CustomerID];
GO

EXEC [TermProject].[dbo].[CustomersByCity] 'London';
GO

-- D5 Answer:
CREATE OR ALTER PROCEDURE UnitPriceByRange(@firstPrice INT, @secondPrice INT)
AS
SELECT [ProductID], [ProductName], [EnglishName], FORMAT([UnitPrice], 'C', 'EN-US') AS [UnitPrice]
	FROM [TermProject].[dbo].[Products]
	WHERE @firstPrice <= [UnitPrice] AND [UnitPrice] <= @secondPrice 
	ORDER BY [Products].[UnitPrice];
GO

EXEC [TermProject].[dbo].[UnitPriceByRange] 6.00, 12.00;
GO

-- D6 Answer:
CREATE OR ALTER PROCEDURE OrdersByDates(@firstDate DATETIME, @secondDate DATETIME)
AS
SELECT
	o.[OrderID]
	, c.[CompanyName] AS [Customer]
	, [TermProject].[dbo].[Shippers].[CompanyName] AS [Shipper]
	, FORMAT(o.[ShippedDate], 'MMMM dd, yyyy') AS [ShippedDate] 
	FROM [TermProject].[dbo].[Orders] AS o
	JOIN [TermProject].[dbo].[Customers] AS c
		ON c.[CustomerID] = o.[CustomerID]
	JOIN [TermProject].[dbo].[Shippers] 
		ON [TermProject].[dbo].[Shippers].[ShipperID] = o.[ShipperID]
	WHERE @firstDate <= [ShippedDate] AND [ShippedDate] <= @secondDate
	ORDER BY o.[ShippedDate];
GO

EXEC [TermProject].[dbo].[OrdersByDates] '1991-05-15', '1991-05-31';
GO

-- D7 Answer:
CREATE OR ALTER PROCEDURE  ProductsByMonthAndYear
	(@product NVARCHAR(255), @month NVARCHAR(255), @year DATETIME)
AS
SELECT
	DISTINCT p.[EnglishName]
	, FORMAT(p.[UnitPrice], 'C', 'en-us') AS [UnitPrice]
	, p.[UnitsInStock]
	, s.[Name]
	FROM [TermProject].[dbo].[Products] AS p
	JOIN [TermProject].[dbo].[Suppliers] AS s
		ON p.[SupplierID] = s.[SupplierID]
	JOIN [TermProject].[dbo].[OrderDetails] AS od
		ON p.[ProductID] = od.[ProductID]
	JOIN [TermProject].[dbo].[Orders] AS o
		ON od.[OrderID] = o.[OrderID]
	WHERE 
		p.[EnglishName] LIKE @product AND
		@month = FORMAT(o.[OrderDate], 'MMMM') AND
		@year = YEAR(o.[OrderDate]);
GO

EXEC [TermProject].[dbo].[ProductsByMonthAndYear] '%cheese', 'December', 1992;
GO

-- D8 Answer: 
CREATE OR ALTER PROCEDURE ReorderQuantity(@value INT)
AS
SELECT p.[ProductID], p.[ProductName], s.[Name], p.[UnitsInStock], p.[ReorderLevel]
	FROM [TermProject].[dbo].[Products] AS p
	JOIN [TermProject].[dbo].[Suppliers] AS s
		ON p.[SupplierID] = s.[SupplierID]
	WHERE (p.[UnitsInStock] - p.[ReorderLevel]) < @value
	ORDER BY p.[ProductName];
GO

EXEC [TermProject].[dbo].[ReorderQuantity] 5;
GO

-- D9 Answer:
CREATE OR ALTER PROCEDURE ShippingDelay(@cutoffDate DATETIME)
AS
SELECT
	o.[OrderID]
	, c.[CompanyName] AS [CustomerName]
	, s.[CompanyName] AS [ShipperName]
	, FORMAT(o.[OrderDate], 'MMMM dd, yyyy') AS [OrderDate]
	, FORMAT(o.[RequiredDate], 'MMMM dd, yyyy') AS [RequiredDate]
	, FORMAT(o.[ShippedDate], 'MMMM dd, yyyy') AS [ShippedDate]
	, DATEDIFF(dd, o.[RequiredDate], o.[ShippedDate]) AS [DaysDelayedBy]
	FROM [TermProject].[dbo].[Orders] AS o
	JOIN [TermProject].[dbo].[Customers] AS c
		ON o.[CustomerID] = c.[CustomerID]
	JOIN [TermProject].[dbo].[Shippers] AS s
		ON o.[ShipperID] = s.[ShipperID]
	WHERE @cutoffDate < o.[OrderDate] AND DATEDIFF(dd, o.[RequiredDate], o.[ShippedDate]) > 0
	ORDER BY o.[OrderDate];
GO

EXEC [TermProject].[dbo].[ShippingDelay] '1993-12-01';
GO

-- D10 Answer:
CREATE OR ALTER PROCEDURE DeleteInactiveCustomers
AS
DELETE c
	FROM [TermProject].[dbo].[Customers] AS c
	WHERE c.[CustomerID] NOT IN 
		(SELECT [CustomerID] FROM [TermProject].[dbo].[Orders]);
GO 

EXEC DeleteInactiveCustomers;
GO
SELECT COUNT(*) AS [ActiveCustomers] FROM [TermProject].[dbo].[Customers];
GO

-- D11 Answer:
CREATE TRIGGER InsertShippers
ON [dbo].[Shippers]
INSTEAD OF INSERT
AS
BEGIN
DECLARE @ID INT, @NAME NVARCHAR(255)
SELECT @ID = [ShipperID], @NAME = [CompanyName] FROM INSERTED
	IF NOT EXISTS
	(
	SELECT * FROM [TermProject].[dbo].[Shippers] AS Shippers 
	WHERE @ID = Shippers.[ShipperID] OR @NAME = Shippers.[CompanyName]
	)
	BEGIN
	INSERT INTO Shippers(ShipperID, CompanyName)
	SELECT ShipperID, CompanyName
	FROM INSERTED
	END
	ELSE
	BEGIN
	RETURN
	END
END
;
GO 

INSERT INTO [TermProject].[dbo].[Shippers]
VALUES (4, 'Federal Shipping');
GO
SELECT * FROM [TermProject].[dbo].[Shippers];
GO
INSERT INTO [TermProject].[dbo].[Shippers]
VALUES (4, 'On-Time Delivery');
GO
SELECT * FROM [TermProject].[dbo].[Shippers];
GO

-- D12 Answer (Still needs work!):
/*
use IF...ELSE
IF UnitsInStock > Quantity: update the table
ELSE Print Error(Ordered: Quantity, Available: UnitsInStock)
*/
CREATE TRIGGER CheckQuantity ON [dbo].[OrderDetails]
INSTEAD OF INSERT, UPDATE
AS
BEGIN
DECLARE @orderId INT, @productId INT, @quantity INT
SELECT
      @productId = [ProductID],
      @orderId = [OrderID],
      @quantity = [Quantity]
      FROM INSERTED;
DECLARE @units int = (SELECT [UnitsInStock]
      FROM [TermProject].[dbo].[Products]
      WHERE [ProductID] = @productId);
IF @quantity > @units
	SELECT CONCAT('Ordered: ', @quantity, '; available: ', @units) AS [Error]
ELSE
	UPDATE [TermProject].[dbo].[OrderDetails]
	SET [Quantity] = @quantity
	WHERE @orderId = [OrderID] AND @productId = [ProductID]
END;
GO

UPDATE [TermProject].[dbo].[OrderDetails]
SET [Quantity] = 50
WHERE [OrderID] = 10044 AND [ProductID] = 77;
GO

SELECT [Quantity] FROM [TermProject].[dbo].[OrderDetails]
WHERE [OrderID] = 10044 AND [ProductID] = 77;
GO

UPDATE [TermProject].[dbo].[OrderDetails]
SET [Quantity] = 30
WHERE [OrderID] = 10044 AND [ProductID] = 77;
GO

SELECT [Quantity] FROM [TermProject].[dbo].[OrderDetails]
WHERE [OrderID] = 10044 AND [ProductID] = 77;
GO
/*
** Author: Soham Chinchalkar
*/

SELECT GETDATE();
SELECT @@VERSION;

DROP VIEW IF EXISTS vw_AvgUsageByType;
DROP VIEW IF EXISTS vw_UpcomingMaintenance;
DROP VIEW IF EXISTS vw_YearlyCostPerBook;
DROP TRIGGER IF EXISTS trg_BookResources_Audit;
DROP PROCEDURE IF EXISTS sp_AddBook;
DROP FUNCTION IF EXISTS udf_EstimateCost;

-- Transactional Tables --
DROP TABLE IF EXISTS BorrowingUsageConsumption;
DROP TABLE IF EXISTS BookResourceAlerts;
DROP TABLE IF EXISTS MaintenanceRecords;

-- Audit Table --
DROP TABLE IF EXISTS BookResources_Audit;

-- Dimension Tables --
DROP TABLE IF EXISTS UserSettings;
DROP TABLE IF EXISTS BorrowingUsagePricing;
DROP TABLE IF EXISTS LibraryUsers;
DROP TABLE IF EXISTS BookResources;

USE master;
DROP DATABASE IF EXISTS Group27_LibraryManagementSystem;

-- Create a new database for Group 27 --
CREATE DATABASE Group27_LibraryManagementSystem;
GO
USE Group27_LibraryManagementSystem;
GO

-- Table: BookResources --
CREATE TABLE BookResources (
    BookResourceID INT PRIMARY KEY,
    BookResourceName VARCHAR(50) NOT NULL,
    BookResourceType VARCHAR(30) NOT NULL,
    Location VARCHAR(50) NOT NULL,
    Manufacturer VARCHAR(50) NULL,
    ReturnDueDate DATE NOT NULL
);

-- Table: LibraryUsers --
CREATE TABLE LibraryUsers (
    UserID INT PRIMARY KEY,
    UserAddress VARCHAR(100) NOT NULL,
    UserName VARCHAR(50) NOT NULL,
    UserContact VARCHAR(15) NOT NULL
);

-- Table: BorrowingUsageConsumption --
CREATE TABLE BorrowingUsageConsumption (
    ConsumptionID INT PRIMARY KEY,
    BookResourceID INT,
    UserID INT,
    Timestamp DATETIME NOT NULL,
    BorrowingUsageUsed FLOAT NOT NULL,
    FOREIGN KEY (BookResourceID) REFERENCES BookResources(BookResourceID),
    FOREIGN KEY (UserID) REFERENCES LibraryUsers(UserID)
);

-- Table: BookResourceAlerts --
CREATE TABLE BookResourceAlerts (
    AlertID INT PRIMARY KEY,
    BookResourceID INT,
    AlertType VARCHAR(50) NOT NULL,
    Timestamp DATETIME NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (BookResourceID) REFERENCES BookResources(BookResourceID)
);

-- Table: MaintenanceRecords
CREATE TABLE MaintenanceRecords (
    LogID INT PRIMARY KEY,
    BookResourceID INT,
    MaintenanceDate DATE NOT NULL,
    LibrarianName VARCHAR(50) NULL,
    Description TEXT NULL,
    Cost DECIMAL(10, 2) NULL,
    FOREIGN KEY (BookResourceID) REFERENCES BookResources(BookResourceID)
);

-- Table: BorrowingUsagePricing --
CREATE TABLE BorrowingUsagePricing (
    PriceID INT PRIMARY KEY,
    Timestamp DATETIME NOT NULL,
    FeeAmount DECIMAL(5, 2) NOT NULL
);

-- Table: UserSettings --
CREATE TABLE UserSettings (
    PreferenceID INT PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES LibraryUsers(UserID),
    PreferredGenre VARCHAR(50),
    PreferredFormat VARCHAR(20),
    BorrowingUsageSavingMode BIT DEFAULT 0
);
INSERT INTO BookResources VALUES
(1, 'Clean Code', 'Book', 'Shelf A1', 'Prentice Hall', '2025-12-01'),
(2, 'The Pragmatic Programmer', 'Book', 'Shelf A2', 'Addison-Wesley', '2025-11-15'),
(3, 'AI 101', 'Book', 'Shelf B1', 'OReilly', '2026-01-01'),
(4, 'Data Structures DVD', 'DVD', 'Media Rack 1', 'TechMedia', '2025-09-10'),
(5, 'Python Crash Course', 'Book', 'Shelf C1', 'No Starch Press', '2025-10-20'),
(6, 'JavaScript Guide', 'Book', 'Shelf B3', 'Mozilla Foundation', '2025-08-12'),
(7, 'Networking Basics', 'Book', 'Shelf A3', 'Cisco', '2025-07-25'),
(8, 'Cloud Essentials', 'Book', 'Shelf B2', 'AWS Press', '2025-11-10'),
(9, 'Linux Command Line', 'Book', 'Shelf D1', 'No Starch Press', '2026-02-01'),
(10, 'Cybersecurity 101', 'Book', 'Shelf C2', 'McGraw-Hill', '2026-01-15');
INSERT INTO LibraryUsers VALUES
(1, '101 Elm St', 'Ravi', '555-0011'),
(2, '202 Oak Ave', 'Aisha', '555-0022'),
(3, '303 Pine Dr', 'Liam', '555-0033'),
(4, '404 Maple Blvd', 'Maya', '555-0044'),
(5, '505 Birch Ln', 'Noah', '555-0055'),
(6, '606 Cedar Rd', 'Emma', '555-0066'),
(7, '707 Spruce Ct', 'Olivia', '555-0077'),
(8, '808 Ash Pkwy', 'Elijah', '555-0088'),
(9, '909 Beech Trl', 'Ava', '555-0099'),
(10, '1001 Fir Way', 'James', '555-0100');
INSERT INTO BorrowingUsagePricing VALUES
(1, '2025-04-01 08:00:00', 1.50),
(2, '2025-04-01 12:00:00', 1.25),
(3, '2025-04-01 16:00:00', 1.75),
(4, '2025-04-02 08:00:00', 1.20),
(5, '2025-04-02 12:00:00', 1.10),
(6, '2025-04-02 16:00:00', 1.80),
(7, '2025-04-03 08:00:00', 1.30),
(8, '2025-04-03 12:00:00', 1.40),
(9, '2025-04-03 16:00:00', 1.60),
(10, '2025-04-04 08:00:00', 1.55);
INSERT INTO UserSettings VALUES
(1, 1, 1.1, 'Paperback', 1), -- 1 represents TRUE
(2, 2, 2.2, 'Hardcover', 0), -- 0 represents FALSE
(3, 3, 1.3, 'eBook', 1),
(4, 4, 3.0, 'Paperback', 0),
(5, 5, 2.1, 'eBook', 1),
(6, 6, 1.0, 'Hardcover', 0),
(7, 7, 2.2, 'Paperback', 1),
(8, 8, 1.1, 'eBook', 1),
(9, 9, 3.2, 'Paperback', 1),
(10, 10, 2.0, 'Hardcover', 1);
INSERT INTO BorrowingUsageConsumption VALUES
(1, 1, 1, '2025-04-01 08:00:00', 3.5),
(2, 2, 2, '2025-04-01 09:30:00', 1.2),
(3, 3, 3, '2025-04-01 10:00:00', 2.8),
(4, 4, 4, '2025-04-01 11:00:00', 4.0),
(5, 5, 5, '2025-04-01 13:00:00', 5.0),
(6, 6, 6, '2025-04-01 14:00:00', 3.0),
(7, 7, 7, '2025-04-01 15:00:00', 2.2),
(8, 8, 8, '2025-04-01 16:00:00', 1.1),
(9, 9, 9, '2025-04-01 17:00:00', 4.5),
(10, 10, 10, '2025-04-01 18:00:00', 2.0),
(11, 1, 2, '2025-04-02 08:30:00', 1.0),
(12, 2, 3, '2025-04-02 09:00:00', 2.5),
(13, 3, 4, '2025-04-02 10:00:00', 3.1),
(14, 4, 5, '2025-04-02 11:00:00', 1.9),
(15, 5, 6, '2025-04-02 12:00:00', 3.3),
(16, 6, 7, '2025-04-02 13:00:00', 2.6),
(17, 7, 8, '2025-04-02 14:00:00', 1.4),
(18, 8, 9, '2025-04-02 15:00:00', 4.1),
(19, 9, 10, '2025-04-02 16:00:00', 3.7),
(20, 10, 1, '2025-04-02 17:00:00', 2.3),
(21, 1, 3, '2025-04-03 08:00:00', 2.0),
(22, 2, 4, '2025-04-03 09:15:00', 1.6),
(23, 3, 5, '2025-04-03 10:30:00', 3.2),
(24, 4, 6, '2025-04-03 11:45:00', 2.7),
(25, 5, 7, '2025-04-03 13:00:00', 1.9);
INSERT INTO BookResourceAlerts VALUES
(1, 1, 'Overdue', '2025-04-01 10:00:00', 'Pending'),
(2, 2, 'Maintenance', '2025-04-01 11:00:00', 'Resolved'),
(3, 3, 'Malfunction', '2025-04-01 12:00:00', 'Pending'),
(4, 4, 'Overdue', '2025-04-01 13:00:00', 'Pending'),
(5, 5, 'Maintenance', '2025-04-01 14:00:00', 'Resolved'),
(6, 6, 'Malfunction', '2025-04-01 15:00:00', 'Pending'),
(7, 7, 'Overdue', '2025-04-01 16:00:00', 'Resolved'),
(8, 8, 'Maintenance', '2025-04-01 17:00:00', 'Pending'),
(9, 9, 'Malfunction', '2025-04-01 18:00:00', 'Resolved'),
(10, 10, 'Overdue', '2025-04-01 19:00:00', 'Pending'),
(11, 1, 'Maintenance', '2025-04-02 08:30:00', 'Resolved'),
(12, 2, 'Overdue', '2025-04-02 09:00:00', 'Pending'),
(13, 3, 'Malfunction', '2025-04-02 10:15:00', 'Resolved'),
(14, 4, 'Overdue', '2025-04-02 11:30:00', 'Pending'),
(15, 5, 'Maintenance', '2025-04-02 12:00:00', 'Pending'),
(16, 6, 'Overdue', '2025-04-02 13:00:00', 'Resolved'),
(17, 7, 'Malfunction', '2025-04-02 14:00:00', 'Pending'),
(18, 8, 'Overdue', '2025-04-02 15:00:00', 'Resolved'),
(19, 9, 'Maintenance', '2025-04-02 15:30:00', 'Pending'),
(20, 10, 'Overdue', '2025-04-02 16:00:00', 'Pending'),
(21, 1, 'Malfunction', '2025-04-03 08:00:00', 'Resolved'),
(22, 2, 'Overdue', '2025-04-03 09:00:00', 'Pending'),
(23, 3, 'Maintenance', '2025-04-03 10:00:00', 'Resolved');
INSERT INTO MaintenanceRecords VALUES
(1, 1, '2025-03-01', 'John Doe', 'Rebinding', 15.00),
(2, 2, '2025-03-02', 'Jane Smith', 'DVD cleaning', 10.00),
(3, 3, '2025-03-03', 'Paul Adams', 'Page restoration', 18.50),
(4, 4, '2025-03-04', 'Emily Zhang', 'Case replacement', 12.00),
(5, 5, '2025-03-05', 'Liam Patel', 'Spine fix', 14.75),
(6, 6, '2025-03-06', 'Olivia Brown', 'Cover lamination', 9.25),
(7, 7, '2025-03-07', 'Noah Davis', 'Water damage repair', 20.00),
(8, 8, '2025-03-08', 'Emma Wilson', 'DVD reburn', 11.50),
(9, 9, '2025-03-09', 'James Taylor', 'Binding glue reapplication', 13.80),
(10, 10, '2025-03-10', 'Ava Lee', 'Loose pages fix', 8.90),
(11, 1, '2025-03-11', 'John Doe', 'Cover restoration', 16.00),
(12, 2, '2025-03-12', 'Jane Smith', 'Label replacement', 7.25),
(13, 3, '2025-03-13', 'Paul Adams', 'Dust jacket repair', 6.90),
(14, 4, '2025-03-14', 'Emily Zhang', 'Disk scan and resurface', 10.00),
(15, 5, '2025-03-15', 'Liam Patel', 'Stain removal', 5.50),
(16, 6, '2025-03-16', 'Olivia Brown', 'Protective film replacement', 9.70),
(17, 7, '2025-03-17', 'Noah Davis', 'Book jacket repair', 6.60),
(18, 8, '2025-03-18', 'Emma Wilson', 'Chapter rebind', 12.40),
(19, 9, '2025-03-19', 'James Taylor', 'Edge trimming', 4.90),
(20, 10, '2025-04-01', 'Michael West', 'Cover replacement', 7.50),
(21, 1, '2025-04-02', 'John Doe', 'Ink smudge cleanup', 6.25),
(22, 2, '2025-04-03', 'Jane Smith', 'Barcode replacement', 5.75),
(23, 3, '2025-04-04', 'Paul Adams', 'Gloss finish touch-up', 8.10),
(24, 4, '2025-04-05', 'Emily Zhang', 'Binding thread fix', 9.40),
(25, 5, '2025-04-06', 'Liam Patel', 'Library tag reprint', 6.95),
(26, 6, '2025-04-26', 'Olivia Brown', 'Dust removal', 5.50),
(27, 7, '2025-04-30', 'Noah Davis', 'Page straightening', 7.20),
(28, 8, '2025-05-05', 'Emma Wilson', 'Cover polish', 6.80),
(29, 9, '2025-05-10', 'James Taylor', 'DVD label refresh', 5.60),
(30, 10, '2025-05-20', 'Ava Lee', 'Protective cover fix', 8.30);

Go


-- Views and Queries with WHERE Clause --

-- View 1: Avg usage per resource type --
CREATE VIEW vw_AvgUsageByType AS
SELECT br.BookResourceType, AVG(buc.BorrowingUsageUsed) AS AvgUsage
FROM BorrowingUsageConsumption buc
JOIN BookResources br ON buc.BookResourceID = br.BookResourceID
WHERE buc.Timestamp >= DATEADD(MONTH, -1, GETDATE())
GROUP BY br.BookResourceType;
Go

-- View 2: Resources needing maintenance --
CREATE VIEW vw_UpcomingMaintenance AS
SELECT br.BookResourceName, mr.MaintenanceDate, mr.Description
FROM MaintenanceRecords mr
JOIN BookResources br ON br.BookResourceID = mr.BookResourceID
WHERE mr.MaintenanceDate BETWEEN GETDATE() AND DATEADD(MONTH, 1, GETDATE());
Go
-- View 3: Yearly borrowing cost per book --
CREATE VIEW vw_YearlyCostPerBook AS
SELECT br.BookResourceName, SUM(buc.BorrowingUsageUsed * bp.FeeAmount) AS TotalCost
FROM BorrowingUsageConsumption buc
JOIN BookResources br ON br.BookResourceID = buc.BookResourceID
JOIN BorrowingUsagePricing bp ON CAST(buc.Timestamp AS DATE) = CAST(bp.Timestamp AS DATE)
WHERE buc.Timestamp >= DATEADD(YEAR, -1, GETDATE())
GROUP BY br.BookResourceName;

Go


-- Audit Table for BookResources --

CREATE TABLE BookResources_Audit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BookResourceID INT,
    ActionType VARCHAR(100),
    ActionDateTime DATETIME DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_BookResources_Audit
ON BookResources
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Capture Insert and Update actions (INSERT and UPDATE are handled separately) --
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Handle INSERT actions --
        IF NOT EXISTS (SELECT * FROM deleted)  -- INSERT case, no DELETE
        BEGIN
            INSERT INTO BookResources_Audit (BookResourceID, ActionType)
            SELECT BookResourceID, 'INSERT' FROM inserted;
        END
        -- Handle UPDATE actions --
        ELSE
        BEGIN
            INSERT INTO BookResources_Audit (BookResourceID, ActionType)
            SELECT BookResourceID, 'UPDATE' FROM inserted;
        END
    END

    -- Capture DELETE actions --
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO BookResources_Audit (BookResourceID, ActionType)
        SELECT BookResourceID, 'DELETE' FROM deleted;
    END
END;

Go
--Stored Procedure & UDF --

-- Stored Procedure: Add book --
CREATE PROCEDURE sp_AddBook
    @Name VARCHAR(50),
    @Type VARCHAR(30),
    @Location VARCHAR(50),
    @Manufacturer VARCHAR(50),
    @ReturnDueDate DATE
AS
BEGIN
    INSERT INTO BookResources (BookResourceID, BookResourceName, BookResourceType, Location, Manufacturer, ReturnDueDate)
    VALUES ((SELECT ISNULL(MAX(BookResourceID), 0) + 1 FROM BookResources), @Name, @Type, @Location, @Manufacturer, @ReturnDueDate);
END;

Go


-- UDF: Estimate cost --
CREATE FUNCTION udf_EstimateCost (
    @ResourceID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(10,2)
    SELECT @TotalCost = SUM(buc.BorrowingUsageUsed * bp.FeeAmount)
    FROM BorrowingUsageConsumption buc
    JOIN BorrowingUsagePricing bp ON CAST(buc.Timestamp AS DATE) = CAST(bp.Timestamp AS DATE)
    WHERE buc.BookResourceID = @ResourceID

    RETURN ISNULL(@TotalCost, 0)
END;
Go

-- Cursor to notify high usage --
DECLARE @ResourceID INT, @Usage FLOAT

DECLARE usage_cursor CURSOR FOR
SELECT BookResourceID, SUM(BorrowingUsageUsed)
FROM BorrowingUsageConsumption
GROUP BY BookResourceID
HAVING SUM(BorrowingUsageUsed) > 10;

OPEN usage_cursor
FETCH NEXT FROM usage_cursor INTO @ResourceID, @Usage

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Resource ID ' + CAST(@ResourceID AS VARCHAR) + ' exceeded threshold with usage ' + CAST(@Usage AS VARCHAR)
    FETCH NEXT FROM usage_cursor INTO @ResourceID, @Usage
END

CLOSE usage_cursor
DEALLOCATE usage_cursor;


-- Cursor to notify Maintainance alerts and status --

-- Declare variables to hold column data --
DECLARE @AlertID INT, @BookResourceID INT, @AlertType VARCHAR(50), @Timestamp DATETIME, @Status VARCHAR(20);

-- Declare a cursor to loop through the BookResourceAlerts table --
DECLARE alert_cursor CURSOR FOR
SELECT AlertID, BookResourceID, AlertType, Timestamp, Status
FROM BookResourceAlerts;

-- Open the cursor --
OPEN alert_cursor;

-- Fetch the first row into variables --
FETCH NEXT FROM alert_cursor INTO @AlertID, @BookResourceID, @AlertType, @Timestamp, @Status;

-- Loop through the records and print each alert --
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Alert ID: ' + CAST(@AlertID AS NVARCHAR(10)) +
          ' | Book Resource ID: ' + CAST(@BookResourceID AS NVARCHAR(10)) +
          ' | Type: ' + @AlertType +
          ' | Timestamp: ' + CAST(@Timestamp AS NVARCHAR(50)) +
          ' | Status: ' + ISNULL(@Status, 'Pending');

    -- Fetch the next record --
    FETCH NEXT FROM alert_cursor INTO @AlertID, @BookResourceID, @AlertType, @Timestamp, @Status;
END

-- Close and deallocate the cursor --
CLOSE alert_cursor;
DEALLOCATE alert_cursor;



--Test Scripts --
-- Test: Average usage by resource type (e.g., Book, DVD) --
SELECT * FROM vw_AvgUsageByType;
-- This view shows average borrowing/usage for each resource type in the past month --

-- Test: Upcoming maintenance events within the next month --
SELECT * FROM vw_UpcomingMaintenance;
-- This view lists upcoming maintenance dates for resources --

-- Test: Total cost per book over the past year --
SELECT * FROM vw_YearlyCostPerBook;
-- This view calculates cost per book based on usage and daily fee --


-- Test: Insert triggers audit log --
INSERT INTO BookResources (BookResourceID, BookResourceName, BookResourceType, Location, Manufacturer, ReturnDueDate)
VALUES (11, 'Test Book', 'Book', 'Test Shelf', 'Test Publisher', '2025-12-31');

-- Test: Update triggers audit log --
UPDATE BookResources SET Location = 'New Shelf' WHERE BookResourceID = 11;

-- Test: Delete triggers audit log --
DELETE FROM BookResources WHERE BookResourceID = 11;

-- Check audit table --
SELECT * FROM BookResources_Audit;
-- This trigger tracks insert/update/delete actions on BookResources table --

-- Test: Add new book via stored procedure --
EXEC sp_AddBook 
    @Name = 'Stored Proc Book',
    @Type = 'Book',
    @Location = 'Shelf Z9',
    @Manufacturer = 'Test Publisher',
    @ReturnDueDate = '2025-12-25';

-- Check if book was inserted --
SELECT * FROM BookResources WHERE BookResourceName = 'Stored Proc Book';
-- This procedure adds a new book with auto-incremented BookResourceID --

-- Test: Estimate borrowing cost for a specific resource --
SELECT dbo.udf_EstimateCost(1) AS EstimatedCost;
-- This function returns total cost for a given BookResourceID --


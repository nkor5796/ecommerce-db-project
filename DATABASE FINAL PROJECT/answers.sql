/* answers.sql
   E-commerce Store Database Schema
   - Includes: Users (one-to-one UserProfile, one-to-many Addresses), Categories,
     Products (many-to-many Categories), Orders (one-to-many OrderItems),
     Payments (one-to-one Order -> Payment), Reviews.
   - Engine: InnoDB for FK support
*/

/* 1) Create database and switch to it */
CREATE DATABASE IF NOT EXISTS ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;


-- Cleanup existing objects (drop in child->parent order)

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS ProductCategories;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS UserProfiles;
DROP TABLE IF EXISTS Users;

SET FOREIGN_KEY_CHECKS = 1;

-
-- 2) Core tables


/* Users: stores authentication / basic account info */
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL, -- hashed password
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    -- business rule: email must be unique
    INDEX (Email)
) ENGINE=InnoDB;

/* UserProfiles: one-to-one extension of Users (example One-to-One) */
CREATE TABLE UserProfiles (
    UserID INT PRIMARY KEY,  -- also FK to Users -> enforces 1:1
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Phone VARCHAR(30),
    DateOfBirth DATE,
    CONSTRAINT fk_userprofiles_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* Addresses: one user can have many addresses (One-to-Many) */
CREATE TABLE Addresses (
    AddressID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    AddressLine1 VARCHAR(255) NOT NULL,
    AddressLine2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100) NOT NULL,
    IsDefault TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_addresses_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX (UserID)
) ENGINE=InnoDB;

-- 
-- Product and Category (many-to-many)


CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(500),
    ParentCategoryID INT DEFAULT NULL,
    CONSTRAINT fk_category_parent FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    StockQty INT NOT NULL DEFAULT 0,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

/* Junction table ProductCategories for many-to-many between Products and Categories */
CREATE TABLE ProductCategories (
    ProductID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (ProductID, CategoryID),
    CONSTRAINT fk_pc_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pc_category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Orders and OrderItems (Order <-> Items many-to-many with quantity)


CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    OrderStatus ENUM('Pending','Processing','Shipped','Delivered','Cancelled') NOT NULL DEFAULT 'Pending',
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ShippingAddressID INT NULL, -- FK to Addresses
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_orders_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orders_address FOREIGN KEY (ShippingAddressID) REFERENCES Addresses(AddressID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX (UserID)
) ENGINE=InnoDB;

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_orderitems_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderitems_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Payments (One-to-One with Orders) - enforce unique OrderID

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE, -- unique ensures one-to-one (at most one payment per order here)
    PaymentMethod ENUM('Card','PayPal','BankTransfer','Cash') NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    PaidAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending','Completed','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_payments_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Reviews: Users can review Products (one user many reviews; one product many reviews)

CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Helpful indexes

CREATE INDEX idx_products_name ON Products(Name);
CREATE INDEX idx_orders_status ON Orders(OrderStatus);
CREATE INDEX idx_reviews_product ON Reviews(ProductID);


-- Sample INSERTs (small dataset for testing)


-- Users
INSERT INTO Users (Email, PasswordHash) VALUES
('john.doe@example.com', 'hashed_pw_1'),
('jane.smith@example.com', 'hashed_pw_2'),
('emily.clark@example.com', 'hashed_pw_3');

-- UserProfiles (1:1)
INSERT INTO UserProfiles (UserID, FirstName, LastName, Phone) VALUES
(1, 'John', 'Doe', '0711000001'),
(2, 'Jane', 'Smith', '0711000002'),
(3, 'Emily', 'Clark', '0711000003');

-- Addresses
INSERT INTO Addresses (UserID, AddressLine1, City, Country, IsDefault) VALUES
(1, '12 Baker Street', 'Nairobi', 'Kenya', 1),
(2, '55 Market Ave', 'Nakuru', 'Kenya', 1),
(3, '7 River Road', 'Eldoret', 'Kenya', 1);

-- Categories
INSERT INTO Categories (Name, Description) VALUES
('Electronics','Electronic gadgets and devices'),
('Accessories','Computer accessories'),
('Phones','Mobile phones');

-- Products
INSERT INTO Products (SKU, Name, Description, Price, StockQty) VALUES
('SKU-1001','Laptop Model X','15-inch laptop', 850.00, 10),
('SKU-2001','Wireless Mouse','Ergonomic wireless mouse', 25.50, 150),
('SKU-3001','Smartphone A1','5.5-inch smartphone', 299.99, 50);

-- ProductCategories relationships
INSERT INTO ProductCategories (ProductID, CategoryID) VALUES
(1, 1), -- Laptop -> Electronics
(2, 2), -- Mouse -> Accessories
(3, 3); -- Smartphone -> Phones

-- Create an order and items
INSERT INTO Orders (UserID, OrderStatus, ShippingAddressID, TotalAmount) VALUES
(1, 'Pending', 1, 0.00);

-- Suppose the auto-generated OrderID is 1 (we can fetch it in an application; here we assume)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 850.00),
(1, 2, 2, 25.50);

-- Update order total (normally computed by application or triggers)
UPDATE Orders
SET TotalAmount = (SELECT IFNULL(SUM(Quantity * UnitPrice),0) FROM OrderItems WHERE OrderItems.OrderID = Orders.OrderID)
WHERE OrderID = 1;

-- Payment for order 1
INSERT INTO Payments (OrderID, PaymentMethod, Amount, Status) VALUES
(1, 'Card', 901.00, 'Completed');

CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NULL,  -- allow NULL for ON DELETE SET NULL
    Rating TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


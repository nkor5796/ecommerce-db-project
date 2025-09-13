# ecommerce-db-project
Final project for Database module: A relational database design and implementation for an E-commerce Store using MySQL.




# E-commerce Database Project

**Final Project – Database Module**

## Project Overview

This project demonstrates the design and implementation of a **relational database management system (RDBMS)** for an **E-commerce Store** using **MySQL**.  

The database is designed to handle common e-commerce operations such as:  

- Managing users and their profiles  
- Storing addresses  
- Managing products and categories  
- Processing orders and order items  
- Handling payments  
- Managing product reviews  

The database follows **normalization principles (1NF, 2NF, 3NF)** to ensure minimal redundancy and maintain data integrity.  

## Features

- **Well-structured tables** with appropriate data types  
- **Primary Keys**, **Foreign Keys**, **NOT NULL**, **UNIQUE** constraints  
- **Relationships**:
  - One-to-One (Users → UserProfiles, Orders → Payments)
  - One-to-Many (Users → Addresses, Orders → OrderItems)
  - Many-to-Many (Products ↔ Categories via ProductCategories)
- Sample data included for testing  

## Database Schema

**Main Tables:**

| Table Name       | Description                                      |
|-----------------|--------------------------------------------------|
| `Users`          | Stores user account info                          |
| `UserProfiles`   | One-to-one profile details                        |
| `Addresses`      | Multiple addresses per user                       |
| `Products`       | Product catalog                                   |
| `Categories`     | Product categories (supports hierarchy)          |
| `ProductCategories` | Many-to-many relation between products & categories |
| `Orders`         | Orders placed by users                             |
| `OrderItems`     | Items included in each order                       |
| `Payments`       | Payment info for orders (one-to-one)              |
| `Reviews`        | User reviews for products                          |

## Technologies Used

- **MySQL** – Database engine  
- **InnoDB** – Storage engine for referential integrity  
- **SQL** – DDL (CREATE, ALTER) and DML (INSERT, UPDATE, SELECT) statements  
- **Optional**: MySQL Workbench for design visualization  

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ecommerce-db-project.git
Open MySQL Workbench or your preferred MySQL client.

Run the answers.sql script to create the database, tables, and sample data.

Test queries or explore the database using SELECT statements.

Normalization
The database is normalized as follows:

1NF: Atomic values in all columns (no multiple products in one field)

2NF: Removed partial dependencies (CustomerName moved to Orders table)

3NF: Removed transitive dependencies (e.g., separating Products, Categories, Users, Addresses)

ERD (Entity-Relationship Diagram)
A simplified ERD of the database relationships:

ruby
Copy code
Users --1:1--> UserProfiles
Users --1:M--> Addresses
Users --1:M--> Orders --1:M--> OrderItems --M:1--> Products --M:M--> Categories
Orders --1:1--> Payments
Products --1:M--> Reviews <--M:1-- Users
Author
Nkor Martine
Final Project – Database Module
power learn project july cohort

License
This project is for academic purposes and does not include a license.

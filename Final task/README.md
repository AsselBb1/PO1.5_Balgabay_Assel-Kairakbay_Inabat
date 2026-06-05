Coffee Shop Database
his project implements a Coffee Shop database using PostgreSQL.

The database stores information about:

* Customers
* Drinks
* Categories
* Orders
* Order Items
* Employees
* Loyalty Cards
* Payments

The system allows the coffee shop to manage customer orders, employee activities, payments, and loyalty programs.

Database Information

Database Name: coffee_shop_db

Schema Name: coffee_shop

Tables

1. customers
2. categories
3. drinks
4. employees
5. orders
6. order_items
7. loyalty_cards
8. payments

Relationships

* Customer → Orders (1:N)
* Employee → Orders (1:N)
* Category → Drinks (1:N)
* Orders → Order_Items (1:N)
* Drinks → Order_Items (1:N)
* Customer → Loyalty_Card (1:1)
* Orders → Payments (1:N)

Orders and Drinks have a many-to-many relationship resolved through the Order_Items junction table.

Run Instructions

1. Open PostgreSQL in DBeaver.
2. Create a new SQL script.
3. Copy the contents of 02_final.sql.
4. Execute the script from top to bottom.
5. Verify that all tables and sample data are created successfully.
Notes

* The project satisfies 3NF requirements.
* Foreign keys use ON DELETE rules.
* The script is re-runnable.
* Sample data is included for all tables.
* UPDATE, DELETE, GRANT, and REVOKE statements are implemented.

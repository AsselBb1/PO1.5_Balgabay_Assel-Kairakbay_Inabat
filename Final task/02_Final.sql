CREATE SCHEMA IF NOT EXISTS coffee_shop;
SET search_path TO coffee_shop;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS drinks (
    drink_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    drink_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    size VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    drink_id INT NOT NULL REFERENCES drinks(drink_id) ON DELETE RESTRICT,
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE IF NOT EXISTS loyalty_cards (
    card_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT UNIQUE REFERENCES customers(customer_id) ON DELETE CASCADE,
    points INT DEFAULT 0,
    membership_level VARCHAR(20) DEFAULT 'bronze'
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='coffee_shop' AND table_name='customers' AND column_name='birth_date') THEN
        ALTER TABLE customers ADD COLUMN birth_date DATE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='coffee_shop' AND table_name='customers' AND column_name='loyalty_points') THEN
        ALTER TABLE customers ADD COLUMN loyalty_points INT DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='coffee_shop' AND table_name='employees' AND column_name='email') THEN
        ALTER TABLE employees ADD COLUMN email VARCHAR(150);
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'customers_status_check') THEN ALTER TABLE customers DROP CONSTRAINT customers_status_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'drinks_price_check') THEN ALTER TABLE drinks DROP CONSTRAINT drinks_price_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'drinks_size_check') THEN ALTER TABLE drinks DROP CONSTRAINT drinks_size_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_drink_name') THEN ALTER TABLE drinks DROP CONSTRAINT uq_drink_name; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'employees_salary_check') THEN ALTER TABLE employees DROP CONSTRAINT employees_salary_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'employees_hire_date_check') THEN ALTER TABLE employees DROP CONSTRAINT employees_hire_date_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'orders_status_check') THEN ALTER TABLE orders DROP CONSTRAINT orders_status_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'orders_order_date_check') THEN ALTER TABLE orders DROP CONSTRAINT orders_order_date_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'order_items_quantity_check') THEN ALTER TABLE order_items DROP CONSTRAINT order_items_quantity_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'order_items_unit_price_check') THEN ALTER TABLE order_items DROP CONSTRAINT order_items_unit_price_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'loyalty_cards_points_check') THEN ALTER TABLE loyalty_cards DROP CONSTRAINT loyalty_cards_points_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'loyalty_cards_membership_level_check') THEN ALTER TABLE loyalty_cards DROP CONSTRAINT loyalty_cards_membership_level_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'payments_amount_check') THEN ALTER TABLE payments DROP CONSTRAINT payments_amount_check; END IF;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'payments_payment_method_check') THEN ALTER TABLE payments DROP CONSTRAINT payments_payment_method_check; END IF;
END $$;

ALTER TABLE customers ADD CONSTRAINT customers_status_check CHECK (status IN ('active','inactive'));
ALTER TABLE drinks ADD CONSTRAINT drinks_price_check CHECK (price >= 0);
ALTER TABLE drinks ADD CONSTRAINT drinks_size_check CHECK (size IN ('small','medium','large'));
ALTER TABLE drinks ADD CONSTRAINT uq_drink_name UNIQUE (drink_name);
ALTER TABLE employees ADD CONSTRAINT employees_salary_check CHECK (salary >= 0);
ALTER TABLE employees ADD CONSTRAINT employees_hire_date_check CHECK (hire_date > DATE '2026-01-01');
ALTER TABLE orders ADD CONSTRAINT orders_status_check CHECK (status IN ('pending','completed','cancelled'));
ALTER TABLE orders ADD CONSTRAINT orders_order_date_check CHECK (order_date > DATE '2026-01-01');
ALTER TABLE order_items ADD CONSTRAINT order_items_quantity_check CHECK (quantity > 0);
ALTER TABLE order_items ADD CONSTRAINT order_items_unit_price_check CHECK (unit_price >= 0);
ALTER TABLE loyalty_cards ADD CONSTRAINT loyalty_cards_points_check CHECK (points >= 0);
ALTER TABLE loyalty_cards ADD CONSTRAINT loyalty_cards_membership_level_check CHECK (membership_level IN ('bronze','silver','gold'));
ALTER TABLE payments ADD CONSTRAINT payments_amount_check CHECK (amount >= 0);
ALTER TABLE payments ADD CONSTRAINT payments_payment_method_check CHECK (payment_method IN ('cash','card','mobile'));

TRUNCATE TABLE payments, loyalty_cards, order_items, orders, employees, drinks, categories, customers RESTART IDENTITY CASCADE;

INSERT INTO customers (full_name, email, phone, registration_date, birth_date) VALUES
('Aruzhan Sadykova','aruzhan@mail.kz','87010000001','2026-02-01','2002-04-10'),
('Dias Nurlybek','dias@mail.kz','87010000002','2026-02-03','2001-05-11'),
('Alina Omarova','alina@mail.kz','87010000003','2026-02-05','2000-06-15'),
('Nursultan Bek','nursultan@mail.kz','87010000004','2026-02-07','1999-07-18'),
('Dana Akhmet','dana@mail.kz','87010000005','2026-02-09','2003-08-21'),
('Aigerim Tolegen','aigerim@mail.kz','87010000006','2026-02-10','2001-01-01'),
('Madi Serik','madi@mail.kz','87010000007','2026-02-11','2000-02-02'),
('Sanzhar Ali','sanzhar@mail.kz','87010000008','2026-02-12','1999-03-03'),
('Madina Askar','madina@mail.kz','87010000009','2026-02-13','2002-04-04'),
('Arman Kairat','arman@mail.kz','87010000010','2026-02-14','2003-05-05');

INSERT INTO categories (category_name) VALUES
('Coffee'), ('Tea'), ('Cold Drinks'), ('Dessert'), ('Seasonal');

INSERT INTO drinks (category_id, drink_name, price, size) VALUES
((SELECT category_id FROM categories WHERE category_name='Coffee'),'Latte',1200,'medium'),
((SELECT category_id FROM categories WHERE category_name='Coffee'),'Cappuccino',1300,'medium'),
((SELECT category_id FROM categories WHERE category_name='Coffee'),'Espresso',900,'small'),
((SELECT category_id FROM categories WHERE category_name='Tea'),'Green Tea',800,'medium'),
((SELECT category_id FROM categories WHERE category_name='Tea'),'Black Tea',850,'medium'),
((SELECT category_id FROM categories WHERE category_name='Cold Drinks'),'Iced Coffee',1500,'large'),
((SELECT category_id FROM categories WHERE category_name='Cold Drinks'),'Lemonade',1000,'large'),
((SELECT category_id FROM categories WHERE category_name='Dessert'),'Hot Chocolate',1400,'medium'),
((SELECT category_id FROM categories WHERE category_name='Seasonal'),'Pumpkin Latte',1700,'large'),
((SELECT category_id FROM categories WHERE category_name='Coffee'),'Americano',1100,'medium');

INSERT INTO employees (full_name, position, hire_date, salary, email) VALUES
('Asylai Zhumakulova','Barista','2026-06-01',250000,'asylai@coffee.kz'),
('Assel Balgabay','Cashier','2026-06-02',220000,'assel@coffee.kz'),
('Aiken Amanbay','Manager','2026-05-29',400000,'manager@coffee.kz'),
('Inabat Kairakbay','Barista','2026-06-02',240000,'inabat@coffee.kz'),
('Aruzhan Tulegenova','Cashier','2026-05-22',230000,'aruzhan@coffee.kz');

INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
((SELECT customer_id FROM customers WHERE email='alina@mail.kz'), (SELECT employee_id FROM employees WHERE email='asylai@coffee.kz'), '2026-02-15', 'completed'),
((SELECT customer_id FROM customers WHERE email='dias@mail.kz'), (SELECT employee_id FROM employees WHERE email='aruzhan@coffee.kz'), '2026-02-16', 'completed'),
((SELECT customer_id FROM customers WHERE email='aigerim@mail.kz'), (SELECT employee_id FROM employees WHERE email='assel@coffee.kz'), '2026-02-17', 'pending'),
((SELECT customer_id FROM customers WHERE email='nursultan@mail.kz'), (SELECT employee_id FROM employees WHERE email='manager@coffee.kz'), '2026-02-18', 'completed'),
((SELECT customer_id FROM customers WHERE email='dana@mail.kz'), (SELECT employee_id FROM employees WHERE email='inabat@coffee.kz'), '2026-02-19', 'cancelled'),
((SELECT customer_id FROM customers WHERE email='madi@mail.kz'), (SELECT employee_id FROM employees WHERE email='manager@coffee.kz'), '2026-02-20', 'completed'),
((SELECT customer_id FROM customers WHERE email='madi@mail.kz'), (SELECT employee_id FROM employees WHERE email='assel@coffee.kz'), '2026-02-21', 'completed'),
((SELECT customer_id FROM customers WHERE email='sanzhar@mail.kz'), (SELECT employee_id FROM employees WHERE email='inabat@coffee.kz'), '2026-02-22', 'pending'),
((SELECT customer_id FROM customers WHERE email='madina@mail.kz'), (SELECT employee_id FROM employees WHERE email='manager@coffee.kz'), '2026-02-23', 'completed'),
((SELECT customer_id FROM customers WHERE email='arman@mail.kz'), (SELECT employee_id FROM employees WHERE email='asylai@coffee.kz'), '2026-02-24', 'completed');

INSERT INTO order_items (order_id, drink_id, quantity, unit_price) VALUES
((SELECT order_id FROM orders ORDER BY order_id LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Latte'), 2, 1200),
((SELECT order_id FROM orders ORDER BY order_id LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Espresso'), 1, 900),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 1 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Cappuccino'), 1, 1300),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 2 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Green Tea'), 2, 800),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 3 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Iced Coffee'), 2, 1500),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 4 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Lemonade'), 1, 1000),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 5 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Hot Chocolate'), 1, 1400),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 6 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Pumpkin Latte'), 2, 1700),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 7 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Americano'), 1, 1100),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 8 LIMIT 1), (SELECT drink_id FROM drinks WHERE drink_name='Latte'), 1, 1200);

INSERT INTO loyalty_cards (customer_id, points, membership_level)
SELECT customer_id, 50, 'bronze' FROM customers;

INSERT INTO payments (order_id, payment_date, amount, payment_method) VALUES
((SELECT order_id FROM orders ORDER BY order_id LIMIT 1), '2026-02-15', 3300, 'card'),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 1 LIMIT 1), '2026-02-16', 2900, 'cash'),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 3 LIMIT 1), '2026-02-18', 3000, 'mobile'),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 5 LIMIT 1), '2026-02-20', 1400, 'card'),
((SELECT order_id FROM orders ORDER BY order_id OFFSET 6 LIMIT 1), '2026-02-21', 3400, 'cash');

UPDATE customers SET status = 'inactive' WHERE email = 'dana@mail.kz';

UPDATE loyalty_cards lc
SET points = lc.points + 50
FROM customers c
WHERE lc.customer_id = c.customer_id AND c.status = 'active';

BEGIN;
DELETE FROM orders WHERE status = 'cancelled' RETURNING order_id;
ROLLBACK;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'coffee_shop_readonly') THEN
        CREATE ROLE coffee_shop_readonly;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'coffee_shop_writer') THEN
        CREATE ROLE coffee_shop_writer;
    END IF;
END $$;

GRANT USAGE ON SCHEMA coffee_shop TO coffee_shop_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA coffee_shop TO coffee_shop_readonly;
GRANT INSERT, UPDATE ON orders TO coffee_shop_writer;
REVOKE UPDATE ON orders FROM coffee_shop_writer;

SELECT * FROM orders;
SELECT * FROM drinks;
SELECT * FROM payments;
SELECT * FROM loyalty_cards;
SELECT * FROM categories;
SELECT COUNT(*) AS total_rows FROM order_items;


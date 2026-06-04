CREATE schema if NOT exists coffee_shop;
set search_path to coffee_shop;

create table if not exists customers (
    customer_id int generated always as identity primary key,
    full_name varchar(100) not null,
    email varchar(150) not null unique,
    phone varchar(20) not null,
    registration_date date default current_date,
    status varchar(20) default 'active',
    check (status in ('active','inactive'))
);

create table if not exists categories (
    category_id int generated always as identity primary key,
    category_name varchar(50) not null unique
);

create table if not exists drinks (
    drink_id int generated always as identity primary key,
    category_id int not null,
    drink_name varchar(100) not null,
    price numeric(10,2) not null,
    size varchar(20) not null,
    foreign key (category_id)
        references categories(category_id)
        on delete restrict,
    check (price >= 0),
    check (size in ('small','medium','large'))
);

create table if not exists employees (
    employee_id int generated always as identity primary key,
    full_name varchar(100) not null,
    position varchar(50) not null,
    hire_date date not null,
    salary numeric(10,2) not null,
    check (salary >= 0),
    check (hire_date > date '2026-01-01')
);

create table if not exists orders (
    order_id int generated always as identity primary key,
    customer_id int not null,
    employee_id int,
    order_date date not null,
    status varchar(20) default 'pending',
    foreign key (customer_id)
        references customers(customer_id)
        on delete cascade,
    foreign key (employee_id)
        references employees(employee_id)
        on delete set null,
    check (status in ('pending','completed','cancelled')),
    check (order_date > date '2026-01-01')
);

create table if not exists order_items (
    order_item_id int generated always as identity primary key,
    order_id int not null,
    drink_id int not null,
    quantity int not null,
    unit_price numeric(10,2) not null,
    total_price numeric(10,2)
        generated always as (quantity * unit_price) stored,
    foreign key (order_id)
        references orders(order_id)
        on delete cascade,
    foreign key (drink_id)
        references drinks(drink_id)
        on delete restrict,
    check (quantity > 0),
    check (unit_price >= 0)
);

create table if not exists loyalty_cards (
    card_id int generated always as identity primary key,
    customer_id int unique,
    points int default 0,
    membership_level varchar(20) default 'bronze',
    foreign key (customer_id)
        references customers(customer_id)
        on delete cascade,
    check (points >= 0),
    check (membership_level in ('bronze','silver','gold'))
);

create table if not exists payments (
    payment_id int generated always as identity primary key,
    order_id int not null,
    payment_date date not null,
    amount numeric(10,2) not null,
    payment_method varchar(20) not null,
    foreign key (order_id)
        references orders(order_id)
        on delete cascade,
    check (amount >= 0),
    check (payment_method in ('cash','card','mobile'))
);


alter table customers
add column birth_date date;


alter table customers
alter column phone type varchar(25);

alter table customers
add column loyalty_points int default 0;


alter table drinks
add constraint uq_drink_name unique (drink_name);

alter table employees
add column email varchar(150);




truncate table payments,
               loyalty_cards,
               order_items,
               orders,
               employees,
               drinks,
               categories,
               customers
restart identity cascade;

insert into customers
(full_name,email,phone,registration_date,birth_date)
values
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


insert into categories(category_name)
values
('Coffee'),
('Tea'),
('Cold Drinks'),
('Dessert'),
('Seasonal');

insert into drinks
(category_id,drink_name,price,size)
values
((select category_id from categories where category_name='Coffee'),'Latte',1200,'medium'),
((select category_id from categories where category_name='Coffee'),'Cappuccino',1300,'medium'),
((select category_id from categories where category_name='Coffee'),'Espresso',900,'small'),
((select category_id from categories where category_name='Tea'),'Green Tea',800,'medium'),
((select category_id from categories where category_name='Tea'),'Black Tea',850,'medium'),
((select category_id from categories where category_name='Cold Drinks'),'Iced Coffee',1500,'large'),
((select category_id from categories where category_name='Cold Drinks'),'Lemonade',1000,'large'),
((select category_id from categories where category_name='Dessert'),'Hot Chocolate',1400,'medium'),
((select category_id from categories where category_name='Seasonal'),'Pumpkin Latte',1700,'large'),
((select category_id from categories where category_name='Coffee'),'Americano',1100,'medium');

insert into employees
(full_name,position,hire_date,salary,email)
values
('Asylai Zhumakulova','Barista','2026-06-01',250000,'asylai@coffee.kz'),
('Assel Balgabay','Cashier','2026-06-02',220000,'assel@coffee.kz'),
('Aiken Amanbay','Manager','2026-05-29',400000,'manager@coffee.kz'),
('Inabat Kairakbay','Barista','2026-06-02',240000,'inabat@coffee.kz'),
('Aruzhan Tulegenova','Cashier','2026-05-22',230000,'aruzhan@coffee.kz');

insert into orders
(customer_id, employee_id, order_date, status)
values
(
    (select customer_id from customers where email='alina@mail.kz'),
    (select employee_id from employees where email='asylai@coffee.kz'),
    '2026-02-15',
    'completed'
),
(
    (select customer_id from customers where email='dias@mail.kz'),
    (select employee_id from employees where email='aruzhan@coffee.kz'),
    '2026-02-16',
    'completed'
),
(
    (select customer_id from customers where email='aigerim@mail.kz'),
    (select employee_id from employees where email='assel@coffee.kz'),
    '2026-02-17',
    'pending'
),
(
    (select customer_id from customers where email='nursultan@mail.kz'),
    (select employee_id from employees where email='manager@coffee.kz'),
    '2026-02-18',
    'completed'
),
(
    (select customer_id from customers where email='dana@mail.kz'),
    (select employee_id from employees where email='inabat@coffee.kz'),
    '2026-02-19',
    'cancelled'
),
(
    (select customer_id from customers where email='madi@mail.kz'),
    (select employee_id from employees where email='manager@coffee.kz'),
    '2026-02-20',
    'completed'
),
(
    (select customer_id from customers where email='madi@mail.kz'),
    (select employee_id from employees where email='assel@coffee.kz'),
    '2026-02-21',
    'completed'
),
(
    (select customer_id from customers where email='sanzhar@mail.kz'),
    (select employee_id from employees where email='inabat@coffee.kz'),
    '2026-02-22',
    'pending'
),
(
    (select customer_id from customers where email='madina@mail.kz'),
    (select employee_id from employees where email='manager@coffee.kz'),
    '2026-02-23',
    'completed'
),
(
    (select customer_id from customers where email='arman@mail.kz'),
    (select employee_id from employees where email='asylai@coffee.kz'),
    '2026-02-24',
    'completed'
);


insert into order_items
(order_id, drink_id, quantity, unit_price)
values
(
    (select order_id from orders order by order_id limit 1),
    (select drink_id from drinks where drink_name='Latte'),
    2,
    1200
),
(
    (select order_id from orders order by order_id limit 1),
    (select drink_id from drinks where drink_name='Espresso'),
    1,
    900
),
(
    (select order_id from orders order by order_id offset 1 limit 1),
    (select drink_id from drinks where drink_name='Cappuccino'),
    1,
    1300
),
(
    (select order_id from orders order by order_id offset 2 limit 1),
    (select drink_id from drinks where drink_name='Green Tea'),
    2,
    800
),
(
    (select order_id from orders order by order_id offset 3 limit 1),
    (select drink_id from drinks where drink_name='Iced Coffee'),
    2,
    1500
),
(
    (select order_id from orders order by order_id offset 4 limit 1),
    (select drink_id from drinks where drink_name='Lemonade'),
    1,
    1000
),
(
    (select order_id from orders order by order_id offset 5 limit 1),
    (select drink_id from drinks where drink_name='Hot Chocolate'),
    1,
    1400
),
(
    (select order_id from orders order by order_id offset 6 limit 1),
    (select drink_id from drinks where drink_name='Pumpkin Latte'),
    2,
    1700
),
(
    (select order_id from orders order by order_id offset 7 limit 1),
    (select drink_id from drinks where drink_name='Americano'),
    1,
    1100
),
(
    (select order_id from orders order by order_id offset 8 limit 1),
    (select drink_id from drinks where drink_name='Latte'),
    1,
    1200
);

insert into loyalty_cards
(customer_id, points, membership_level)
select
    customer_id,
    50,
    'bronze'
from customers;

insert into payments
(order_id,payment_date,amount,payment_method)
values
(
    (select order_id from orders order by order_id limit 1),
    '2026-02-15',
    3300,
    'card'
),
(
    (select order_id from orders order by order_id offset 1 limit 1),
    '2026-02-16',
    2900,
    'cash'
),
(
    (select order_id from orders order by order_id offset 3 limit 1),
    '2026-02-18',
    3000,
    'mobile'
),
(
    (select order_id from orders order by order_id offset 5 limit 1),
    '2026-02-20',
    1400,
    'card'
),
(
    (select order_id from orders order by order_id offset 6 limit 1),
    '2026-02-21',
    3400,
    'cash'
);


update customers
set status = 'inactive'
where email = 'dana@mail.kz';

update loyalty_cards lc
set points = lc.points + 50
from customers c
where lc.customer_id = c.customer_id
and c.status = 'active';


begin;

delete from orders
where status = 'cancelled'
returning order_id;

rollback;


create role coffee_shop_readonly;

create role coffee_shop_writer;

grant usage on schema coffee_shop
to coffee_shop_readonly;

grant select on all tables in schema coffee_shop
to coffee_shop_readonly;

grant insert, update on orders
to coffee_shop_writer;

revoke update on orders
from coffee_shop_writer;

select * from orders;
select * from drinks;
SELECT * FROM payments;
SELECT * FROM loyalty_cards;
SELECT * FROM Categories;



SELECT COUNT(*) AS total_rows
FROM order_items;


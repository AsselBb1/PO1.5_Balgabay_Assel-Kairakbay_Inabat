drop schema if exists coffee_shop cascade;
create schema coffee_shop;
set search_path to coffee_shop;

drop table if exists payments cascade;
drop table if exists loyalty_cards cascade;
drop table if exists order_items cascade;
drop table if exists orders cascade;
drop table if exists employees cascade;
drop table if exists drinks cascade;
drop table if exists categories cascade;
drop table if exists customers cascade;

create table customers (
    customer_id int generated always as identity primary key,
    full_name varchar(100) not null,
    email varchar(150) not null unique,
    phone varchar(20) not null,
    registration_date date default current_date,
    status varchar(20) default 'active',
    check (status in ('active','inactive'))
);

create table categories (
    category_id int generated always as identity primary key,
    category_name varchar(50) not null unique
);

create table drinks (
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

create table employees (
    employee_id int generated always as identity primary key,
    full_name varchar(100) not null,
    position varchar(50) not null,
    hire_date date not null,
    salary numeric(10,2) not null,
    check (salary >= 0),
    check (hire_date > date '2026-01-01')
);

create table orders (
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

create table order_items (
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

create table loyalty_cards (
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

create table payments (
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
('Dana Akhmet','dana@mail.kz','87010000005','2003-08-21','2003-08-21'),
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
('Ali Omarov','Barista','2026-02-01',250000,'ali@coffee.kz'),
('Dana Serik','Cashier','2026-02-05',220000,'dana@coffee.kz'),
('Aruzhan Bek','Manager','2026-02-10',400000,'manager@coffee.kz'),
('Nurlan Tolegen','Barista','2026-02-15',240000,'nurlan@coffee.kz'),
('Madina Sapar','Cashier','2026-02-20',230000,'madina@coffee.kz');


insert into orders (customer_id, employee_id, order_date, status)
values
(1, 1, '2026-02-15', 'completed'),
(2, 2, '2026-02-16', 'completed'),
(3, 1, '2026-02-17', 'pending'),
(4, 3, '2026-02-18', 'completed'),
(5, 2, '2026-02-19', 'cancelled'),
(6, 4, '2026-02-20', 'completed'),
(7, 5, '2026-02-21', 'completed'),
(8, 1, '2026-02-22', 'pending'),
(9, 3, '2026-02-23', 'completed'),
(10, 4, '2026-02-24', 'completed');


insert into order_items (order_id, drink_id, quantity, unit_price)
values
(1, 1, 2, 1200),
(1, 3, 1, 900),

(2, 2, 1, 1300),
(2, 4, 2, 800),

(3, 5, 1, 850),
(4, 6, 2, 1500),

(5, 7, 1, 1000),
(6, 8, 1, 1400),

(7, 9, 2, 1700),
(8, 10, 1, 1100),

(9, 1, 1, 1200),
(10, 2, 2, 1300);

insert into loyalty_cards (customer_id, points, membership_level)
values
(1, 120, 'silver'),
(2, 80, 'bronze'),
(3, 200, 'gold'),
(4, 150, 'silver'),
(5, 50, 'bronze'),
(6, 300, 'gold'),
(7, 90, 'bronze'),
(8, 110, 'silver'),
(9, 400, 'gold'),
(10, 70, 'bronze');

insert into payments (order_id, payment_date, amount, payment_method)
values
(1, '2026-02-15', 3300, 'card'),
(2, '2026-02-16', 2900, 'cash'),
(4, '2026-02-18', 3000, 'mobile'),
(6, '2026-02-20', 1400, 'card'),
(7, '2026-02-21', 3400, 'cash'),
(9, '2026-02-23', 1200, 'card'),
(10, '2026-02-24', 2600, 'mobile');

update customers
set status = 'inactive'
where customer_id = 5;

update loyalty_cards
set points = points + 50
where membership_level = 'silver';

update orders
set status = 'completed'
where status = 'pending';

delete from payments
where payment_method = 'cash';

delete from orders
where status = 'cancelled';

create role coffee_reader;

grant select on all tables in schema coffee_shop to coffee_reader;

grant usage on schema coffee_shop to coffee_reader;


select * from customers;
select * from orders;
select * from drinks;


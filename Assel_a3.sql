drop role if exists db_reader_user;
drop role if exists db_admin_user;

drop role if exists library_readonly;
drop role if exists library_admin;

drop schema if exists library cascade;
create schema library;
set search_path to library;

create table genres (
    genre_id int generated always as identity primary key,
    genre_name varchar(100) not null unique,
    description text
);

create table publishers (
    publisher_id int generated always as identity primary key,
    publisher_name varchar(100) not null unique,
    country varchar(50)
);

create table branches (
    branch_id int generated always as identity primary key,
    branch_name varchar(50) not null,
    address varchar(100),
    email varchar(50) not null unique,
    city varchar(50) not null,
    phone varchar(50) not null,
    opened_date date check (opened_date > date '2020-01-01'),
    is_active boolean not null default true
);

create table authors (
    author_id int generated always as identity primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    full_name varchar(101) generated always as (first_name || ' ' || last_name) stored,
    birth_date date,
    country varchar(50)
);

create table books (
    book_id int generated always as identity primary key,
    isbn varchar(20) not null unique,
    title varchar(225) not null,
    publisher_id int references publishers(publisher_id) on delete set null,
    pub_year int check (pub_year is null or pub_year > 0),
    edition varchar(50),
    language varchar(50)
);

create table book_authors (
    author_id int references authors(author_id) on delete cascade,
    book_id int references books(book_id) on delete cascade,
    primary key (author_id, book_id)
);

create table book_genres (
    book_id int references books(book_id) on delete cascade,
    genre_id int references genres(genre_id) on delete cascade,
    primary key (book_id, genre_id)
);

create table book_copies (
    copy_id int generated always as identity primary key,
    book_id int references books(book_id) on delete cascade,
    branch_id int references branches(branch_id) on delete set null,
    status varchar(20) check (status in ('Available','Loaned','Reserved','Damaged','Lost')),
    condition varchar(50),
    acquired_date date check (acquired_date > date '2020-01-01')
);

create table borrowers (
    borrower_id int generated always as identity primary key,
    first_name varchar(50),
    last_name varchar(50),
    full_name varchar(101) generated always as (first_name || ' ' || last_name) stored,
    gender varchar(10) check (gender in ('Male','Female','Other')),
    email varchar(100) unique,
    phone varchar(50),
    registration_date date default current_date,
    birth_date date,
    is_active boolean default true
);

create table staff (
    staff_id int generated always as identity primary key,
    branch_id int references branches(branch_id) on delete set null,
    first_name varchar(50),
    last_name varchar(50),
    full_name varchar(101) generated always as (first_name || ' ' || last_name) stored,
    position varchar(50),
    hire_date date,
    phone varchar(50)
);

create table loans (
    loan_id int generated always as identity primary key,
    copy_id int references book_copies(copy_id),
    borrower_id int references borrowers(borrower_id),
    staff_id int references staff(staff_id),
    loan_date date default current_date,
    due_date date,
    return_date date
);

create table reservations (
    reservation_id int generated always as identity primary key,
    book_id int references books(book_id),
    borrower_id int references borrowers(borrower_id),
    branch_id int references branches(branch_id),
    reservation_date date default current_date,
    expiry_date date,
    status varchar(20)
);

create table fines (
    fine_id int generated always as identity primary key,
    loan_id int references loans(loan_id),
    borrower_id int references borrowers(borrower_id),
    amount decimal(8,2),
    paid_status boolean default false,
    due_date date,
    fine_reason text
);

create table payments (
    payment_id int generated always as identity primary key,
    fine_id int references fines(fine_id),
    borrower_id int references borrowers(borrower_id),
    payment_date date default current_date,
    amount decimal(8,2),
    payment_method varchar(30)
);

create role library_admin;
create role library_readonly;

grant usage on schema public to library_admin, library_readonly;
grant usage on schema library to library_admin, library_readonly;

grant select, insert, update, delete on all tables in schema library to library_admin;
grant select on all tables in schema library to library_readonly;

revoke update, delete on all tables in schema library from library_readonly;

create user db_admin_user with password 'admin123';
create user db_reader_user with password 'reader123';

grant library_admin to db_admin_user;
grant library_readonly to db_reader_user;

truncate table payments, fines, reservations, loans,
book_copies, book_authors, book_genres, books,
borrowers, staff, authors, publishers, genres, branches cascade;

insert into genres (genre_name, description) values
('Fiction','Stories'),
('Science','Science books'),
('History','History'),
('Technology','IT books'),
('Biography','Life stories');

insert into publishers (publisher_name, country) values
('Penguin','UK'),
('HarperCollins','USA'),
('O''Reilly','USA'),
('MIT Press','USA'),
('Springer','Germany');

insert into branches (branch_name,address,email,city,phone,opened_date) values
('Central','A1','c1@mail.com','Atyrau','111','2026-02-01'),
('North','A2','c2@mail.com','Atyrau','222','2026-03-01'),
('South','A3','c3@mail.com','Atyrau','333','2026-04-01'),
('East','A4','c4@mail.com','Atyrau','444','2026-05-01'),
('West','A5','c5@mail.com','Atyrau','555','2026-06-01');

insert into authors(first_name,last_name,country) values
('John','Doe','USA'),
('Jane','Smith','UK'),
('Alan','Turing','UK'),
('Isaac','Newton','UK'),
('Albert','Einstein','Germany');

insert into books(isbn,title,publisher_id,pub_year,edition,language) values
('B1','SQL Basics',(select publisher_id from publishers where publisher_name='Penguin'),2022,'1','EN'),
('B2','Physics',(select publisher_id from publishers where publisher_name='Springer'),2021,'1','EN'),
('B3','Algorithms',(select publisher_id from publishers where publisher_name='MIT Press'),2020,'1','EN'),
('B4','History World',(select publisher_id from publishers where publisher_name='HarperCollins'),2019,'1','EN'),
('B5','AI Guide',(select publisher_id from publishers where publisher_name='O''Reilly'),2023,'1','EN');

insert into book_authors values
(1,1),(2,2),(3,3),(4,4),(5,5);

insert into book_genres values
(1,4),(2,2),(3,4),(4,3),(5,4);

insert into book_copies(book_id,branch_id,status,condition,acquired_date) values
(1,1,'Available','New','2026-02-10'),
(2,2,'Available','Good','2026-02-11'),
(3,3,'Available','Good','2026-02-12'),
(4,4,'Available','New','2026-02-13'),
(5,5,'Available','New','2026-02-14');

insert into borrowers(first_name,last_name,gender,email,phone) values
('Ali','Khan','Male','a@mail.com','111'),
('Aru','Aman','Female','b@mail.com','222'),
('Dana','Lee','Other','c@mail.com','333'),
('Nina','Kim','Female','d@mail.com','444'),
('Max','Stone','Male','e@mail.com','555');

insert into staff(branch_id,first_name,last_name,position,hire_date,phone) values
(1,'Sam','Wilson','Manager','2026-02-15','999'),
(2,'Anna','Bell','Librarian','2026-03-15','888'),
(3,'John','Wayne','Staff','2026-04-15','777'),
(4,'Kate','Brown','Staff','2026-05-15','666'),
(5,'Tom','Hardy','Staff','2026-06-15','555');

insert into loans(copy_id,borrower_id,staff_id,loan_date,due_date) values
(1,1,1,'2026-04-01','2026-04-10'),
(2,2,2,'2026-04-02','2026-04-11'),
(3,3,3,'2026-04-03','2026-04-12'),
(4,4,4,'2026-04-04','2026-04-13'),
(5,5,5,'2026-04-05','2026-04-14');

insert into reservations(book_id,borrower_id,branch_id,status) values
(1,1,1,'Pending'),
(2,2,2,'Pending'),
(3,3,3,'Pending'),
(4,4,4,'Pending'),
(5,5,5,'Pending');

insert into fines(loan_id,borrower_id,amount,due_date,fine_reason) values
(1,1,100,'2026-05-01','Late'),
(2,2,200,'2026-05-02','Late'),
(3,3,300,'2026-05-03','Late'),
(4,4,400,'2026-05-04','Late'),
(5,5,500,'2026-05-05','Late');

insert into payments(fine_id,borrower_id,amount,payment_method) values
(1,1,100,'Cash'),
(2,2,200,'Card'),
(3,3,300,'Online'),
(4,4,400,'Cash'),
(5,5,500,'Card');

update borrowers
set phone='999999'
where email='a@mail.com';

update books
set edition='2'
where title='SQL Basics';

update fines f
set amount = f.amount + 50
from borrowers b
where f.borrower_id = b.borrower_id;

begin;
delete from fines
where amount < 150;
rollback;

set role db_admin_user;

select current_user;
select count(*) from books;

insert into books(isbn,title,publisher_id,pub_year,edition,language)
values ('TESTX','Admin Test',(select publisher_id from publishers limit 1),2024,'1','EN');

update books set edition='X' where isbn='TESTX';

delete from books where isbn='TESTX';

reset role;

set role db_reader_user;

select current_user;
select count(*) from books;

begin;
insert into books(isbn,title,publisher_id,pub_year,edition,language)
values ('FAIL','Reader Test',(select publisher_id from publishers limit 1),2024,'1','EN');
rollback;

begin;
update books set edition='X' where isbn='B1';
rollback;

begin;
delete from books where isbn='B1';
rollback;

reset role;
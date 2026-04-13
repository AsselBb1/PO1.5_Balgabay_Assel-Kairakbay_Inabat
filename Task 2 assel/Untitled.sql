DROP SCHEMA IF EXISTS library CASCADE;
CREATE SCHEMA library;
SET search_path TO library;

CREATE TABLE library.genres (
    genre_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    genre_name  VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE library.publishers (
    publisher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50)
);

CREATE TABLE library.branches (
    branch_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    email VARCHAR(50) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    opened_date DATE CHECK (opened_date > DATE '2026-01-01'),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE library.authors (
    author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    birth_date DATE,
    country VARCHAR(50)
);

CREATE TABLE library.books (
    book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(225) NOT NULL,
    publisher_id INT REFERENCES library.publishers(publisher_id) ON DELETE SET NULL,
    pub_year INT CHECK (pub_year IS NULL OR pub_year > 0),
    edition VARCHAR(50),
    language VARCHAR(50)
);

CREATE TABLE library.book_authors (
    author_id INT NOT NULL REFERENCES library.authors(author_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES library.books(book_id) ON DELETE CASCADE,
    PRIMARY KEY (author_id, book_id)
);

CREATE TABLE library.book_genres (
    book_id INT NOT NULL REFERENCES library.books(book_id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES library.genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE library.book_copies (
    copy_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL REFERENCES library.books(book_id) ON DELETE CASCADE,
    branch_id INT REFERENCES library.branches(branch_id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Available'
        CHECK (status IN ('Available', 'Loaned', 'Reserved', 'Damaged', 'Lost')),
    condition VARCHAR(50),
    acquired_date DATE CHECK (acquired_date > DATE '2026-01-01')
);

CREATE TABLE library.borrowers (
    borrower_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(50),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (registration_date > DATE '2026-01-01'),
    birth_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE library.staff (
    staff_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id INT REFERENCES library.branches(branch_id) ON DELETE SET NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    position VARCHAR(50),
    hire_date DATE CHECK (hire_date > DATE '2026-01-01'),
    phone VARCHAR(50)
);

CREATE TABLE library.loans (
    loan_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    copy_id INT NOT NULL REFERENCES library.book_copies(copy_id) ON DELETE RESTRICT,
    borrower_id INT NOT NULL REFERENCES library.borrowers(borrower_id) ON DELETE RESTRICT,
    staff_id INT REFERENCES library.staff(staff_id) ON DELETE SET NULL,
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (loan_date > DATE '2026-01-01'),
    due_date DATE NOT NULL
        CHECK (due_date > DATE '2026-01-01'),
    return_date DATE,
    CONSTRAINT chk_loan_dates CHECK (due_date >= loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

CREATE TABLE library.reservations (
    reservation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id INT NOT NULL REFERENCES library.books(book_id) ON DELETE CASCADE,
    borrower_id INT NOT NULL REFERENCES library.borrowers(borrower_id) ON DELETE CASCADE,
    branch_id INT REFERENCES library.branches(branch_id) ON DELETE SET NULL,
    reservation_date DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (reservation_date > DATE '2026-01-01'),
    expiry_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Fulfilled', 'Cancelled', 'Expired')),
    CONSTRAINT chk_expiry_date CHECK (expiry_date IS NULL OR expiry_date >= reservation_date)
);

CREATE TABLE library.fines (
    fine_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id INT NOT NULL REFERENCES library.loans(loan_id) ON DELETE RESTRICT,
    borrower_id INT NOT NULL REFERENCES library.borrowers(borrower_id) ON DELETE RESTRICT,
    amount DECIMAL(8,2) NOT NULL CHECK (amount >= 0),
    paid_status BOOLEAN NOT NULL DEFAULT FALSE,
    due_date DATE CHECK (due_date IS NULL OR due_date > DATE '2026-01-01'),
    fine_reason TEXT
);

CREATE TABLE library.payments (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fine_id INT NOT NULL REFERENCES library.fines(fine_id) ON DELETE RESTRICT,
    borrower_id INT NOT NULL REFERENCES library.borrowers(borrower_id) ON DELETE RESTRICT,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (payment_date > DATE '2026-01-01'),
    amount DECIMAL(8,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30)
        CHECK (payment_method IN ('Cash', 'Card', 'Online', 'Other')),
    notes TEXT
);

INSERT INTO library.genres (genre_name, description) VALUES
('Fiction', 'Stories that are not real'),
('Science', 'Scientific books'),
('History', 'Historical events');

INSERT INTO library.publishers (publisher_name, country) VALUES
('Penguin Books', 'UK'),
('HarperCollins', 'USA');

INSERT INTO library.branches (branch_name, address, email, city, phone, opened_date)
VALUES
('Central Library', 'Main St 1', 'central@lib.com', 'Atyrau', '+77000000001', '2026-02-01'),
('West Branch', 'West St 5', 'west@lib.com', 'Atyrau', '+77000000002', '2026-03-01');

INSERT INTO library.authors (first_name, last_name, birth_date, country) VALUES
('John', 'Doe', '1980-05-10', 'USA'),
('Jane', 'Smith', '1975-08-20', 'UK');

INSERT INTO library.books (isbn, title, publisher_id, pub_year, edition, language) VALUES
('ISBN001', 'Learning SQL', 1, 2022, '1st', 'English'),
('ISBN002', 'History of Time', 2, 2020, '2nd', 'English');

INSERT INTO library.book_authors (author_id, book_id) VALUES
(1,1),
(2,2);

INSERT INTO library.book_genres (book_id, genre_id) VALUES
(1,2),
(2,3);

INSERT INTO library.book_copies (book_id, branch_id, status, condition, acquired_date) VALUES
(1,1,'Available','New','2026-02-10'),
(2,2,'Available','Good','2026-03-10');

INSERT INTO library.borrowers (first_name, last_name, gender, email, phone, registration_date)
VALUES
('Ali', 'Khan', 'Male', 'ali@mail.com', '+77000000003', '2026-04-01'),
('Aruzhan', 'Aman', 'Female', 'aru@mail.com', '+77000000004', '2026-04-02');

INSERT INTO library.staff (branch_id, first_name, last_name, position, hire_date, phone)
VALUES
(1, 'Sam', 'Wilson', 'Manager', '2026-02-15', '+77000000005');

INSERT INTO library.loans (copy_id, borrower_id, staff_id, loan_date, due_date)
VALUES
(1,1,1,'2026-04-05','2026-04-15');

INSERT INTO library.reservations (book_id, borrower_id, branch_id, reservation_date, status)
VALUES
(2,2,2,'2026-04-06','Pending');

INSERT INTO library.fines (loan_id, borrower_id, amount, due_date, fine_reason)
VALUES
(1,1,500.00,'2026-04-20','Late return');

INSERT INTO library.payments (fine_id, borrower_id, payment_date, amount, payment_method)
VALUES
(1,1,'2026-04-10',500.00,'Cash');

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'library';

SELECT * FROM library.genres;
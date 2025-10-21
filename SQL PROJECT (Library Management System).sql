create database lib_prj
use lib_prj

-- Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

select * from Category
INSERT INTO Category (category_id, category_name)
VALUES (1, 'English'), (2, 'Science'), (3, 'Mathematics');


-- Book Table
CREATE TABLE Book (
    book_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    category_id INT,
    total_copies INT,
    available_copies INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

select * from Book
INSERT INTO Book (book_id, title, author, category_id, total_copies, available_copies)
VALUES (1, 'The Great Gatsby', 'F. Scott Fitzgerald', 1, 5, 5),
       (2, 'The Theory of Everything', 'Stephen Hawking', 2, 3, 3),
       (3, 'Calculus', 'James Stewart', 3, 4, 4);

-- User Table
CREATE TABLE Userr 
   ( user_id INT PRIMARY KEY,
    user_type varchar(10) NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255),
    contact VARCHAR(20)
);

select * from Userr
INSERT INTO Userr (user_id, user_type, name, email, contact)
VALUES (1, 'Student', 'Ankit', 'ankit5@gmail.com', '1234765780'),
       (2, 'Teacher', 'Dr.Aakash', 'draakash87@gmail.com', '0987432321');


-- Fine Table
CREATE TABLE Fine (
    fine_id INT PRIMARY KEY,
    amount DECIMAL(10,2) CHECK (amount >= 0),
    fine_date DATE,
    is_paid varchar(10) DEFAULT ('FALSE')
);

select * from Fine
INSERT INTO Fine (fine_id, amount, fine_date, is_paid)
VALUES (1, 0.00, '2024-12-10', 'FALSE');

-- transaction table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Userr(user_id),
    BookID INT FOREIGN KEY REFERENCES book(book_id),
    IssueDate DATE DEFAULT GETDATE(),
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    FineAmount DECIMAL(5,2) )


-- Issue Table
CREATE TABLE Issue (
    issue_id INT PRIMARY KEY,
    book_id INT,
    user_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    fine_id INT,
    FOREIGN KEY (book_id) REFERENCES Book(book_id),
    FOREIGN KEY (user_id) REFERENCES Userr(user_id),
    FOREIGN KEY (fine_id) REFERENCES Fine(fine_id),
    CHECK (due_date > issue_date)
);

select * from Issue
INSERT INTO Issue (issue_id, book_id, user_id, issue_date, due_date, return_date, fine_id)
VALUES (1, 1, 1, '2024-12-01', '2024-12-15', '2024-12-16', 1);


-- Create Procedures for Required Functions
--Procedure to Issue a Book
CREATE PROCEDURE IssueBook
    @UserID INT,
    @BookID INT
AS
BEGIN
    DECLARE @UserType NVARCHAR(10), @DueDays INT;

    -- Get user type
    SELECT @UserType = user_type FROM Userr WHERE user_id = @UserID;

    -- Set due date based on user type
    SET @DueDays = CASE WHEN @UserType = 'Student' THEN 14 ELSE 30 END;

    -- Check book availability
    IF (SELECT available_copies FROM Book WHERE book_id = @BookID) > 0
    BEGIN
        -- Issue book
        INSERT INTO Transactions (UserID, BookID, DueDate)
        VALUES (@UserID, @BookID, DATEADD(DAY, @DueDays, GETDATE()));

        -- Reduce available copies
        UPDATE Book SET available_copies = available_copies - 1 WHERE book_id = @BookID;

        PRINT 'Book Issued Successfully!';
    END
    ELSE
    BEGIN
        PRINT 'Book Not Available!';
    END
END;


--Procedure to Return a Book & Calculate Fine
CREATE PROCEDURE ReturnBook
    @TransactionID INT
AS
BEGIN
    DECLARE @DueDate DATE, @Fine DECIMAL(5,2);

    -- Get DueDate
    SELECT @DueDate = DueDate FROM Transactions WHERE TransactionID = @TransactionID;

    -- Calculate Fine (if returned late)
    SET @Fine = CASE 
        WHEN GETDATE() > @DueDate THEN DATEDIFF(DAY, @DueDate, GETDATE()) * 5
        ELSE 0 
    END;

    -- Update Transaction
    UPDATE Transactions 
    SET ReturnDate = GETDATE(), FineAmount = @Fine 
    WHERE TransactionID = @TransactionID;

    -- Record Fine if applicable
    IF @Fine > 0
    BEGIN
        INSERT INTO Fine (fine_id, Amount, is_paid) 
        VALUES (@TransactionID, @Fine, 'Pending');
    END;

    -- Increase available copies
    UPDATE book SET available_copies = available_copies + 1 WHERE book_id = 
        (SELECT BookID FROM Transactions WHERE TransactionID = @TransactionID);

    PRINT 'Book Returned Successfully!';
END;


--Total Books Issued Per User Type
SELECT USER_ID , COUNT(t.TransactionID) AS TotalBooksIssued
FROM Userr u
JOIN Transactions t ON u.user_id = t.UserID
GROUP BY u.user_type;


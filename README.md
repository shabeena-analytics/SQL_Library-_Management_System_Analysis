# SQL_Library-_Management_System_Analysis

## Description
The **Library Database Management System (SQL)** is a project designed to efficiently manage library operations. It tracks books, categories, and users while maintaining data integrity. The system allows librarians to issue and return books, calculate fines for late returns, and generate reports on book circulation. This project demonstrates skills in **SQL, relational database design, stored procedures, and database management**, making it an excellent showcase for data management and database projects.

---

## Features
- **Relational Database Design**: Tables for books, categories, users, fines, transactions, and issues.
- **Book Management**: Track total and available copies of books.
- **User Management**: Maintain records of students and teachers borrowing books.
- **Transaction Management**: Issue and return books using SQL stored procedures.
- **Fine Calculation**: Automatically calculate fines for late returns.
- **Reports**: Generate reports like total books issued per user type.

---

## Database Schema
### Tables:
1. **Category** – Stores book categories.  
2. **Book** – Stores book details with availability tracking.  
3. **Userr** – Stores user information and user type (Student/Teacher).  
4. **Fine** – Stores fines for late returns.  
5. **Transactions** – Tracks all book issue and return transactions.  
6. **Issue** – Tracks individual book issues linked with fines.  

---

## Stored Procedures
- **IssueBook**: Issues a book to a user based on availability and user type.  
- **ReturnBook**: Returns a book, calculates fines for late returns, and updates availability.  

---

## Sample Queries
- Insert categories, books, and users.
- Issue and return books using stored procedures.
- Retrieve total books issued per user type:

```sql
SELECT USER_ID , COUNT(t.TransactionID) AS TotalBooksIssued
FROM Userr u
JOIN Transactions t ON u.user_id = t.UserID
GROUP BY u.user_type;

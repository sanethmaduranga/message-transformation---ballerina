/* 
 * MySQL Script - initializeDataBase.sql.
 * Create testDB database, student table and StudentDetails table.
 */
 
-- Create testDB database
CREATE DATABASE IF NOT EXISTS testdb;     

-- Switch to testDB database
USE testdb;

-- create student table and StudentDetails table in the database
CREATE TABLE IF NOT EXISTS student (id INT, name VARCHAR(255), address VARCHAR(255), gender VARCHAR(255), PRIMARY KEY (id));



-- Create testDB database
CREATE DATABASE IF NOT EXISTS testdb1;     

-- Switch to testDB database
USE testdb1;

-- create student table and StudentDetails table in the database
CREATE TABLE IF NOT EXISTS StudentDetails (ID INTEGER, Com_Maths VARCHAR(1), Physics VARCHAR(1), Chemistry VARCHAR(1), PRIMARY KEY (ID)); 

-- add values to table StudentDetails
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (100, 'A', 'A', 'A');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (101, 'A', 'A', 'B');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (102, 'A', 'A', 'C');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (103, 'A', 'B', 'A');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (104, 'A', 'B', 'B');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (105, 'A', 'B', 'C');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (106, 'A', 'C', 'A');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (107, 'A', 'C', 'B');
INSERT INTO StudentDetails(ID, Com_Maths, Physics, Chemistry) values (108, 'A', 'C', 'C');





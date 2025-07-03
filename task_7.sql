-- Create base tables
CREATE TABLE deptmst (
  deptno INT PRIMARY KEY,
  deptname VARCHAR(20),
  location VARCHAR(15)
);

CREATE TABLE employee (
  empno INT PRIMARY KEY,
  empname VARCHAR(15) NOT NULL,
  deptno INT,
  salary DECIMAL(8,2),
  dob DATE,
  city VARCHAR(10),
  FOREIGN KEY (deptno) REFERENCES deptmst(deptno)
);

-- Insert sample data
INSERT INTO deptmst VALUES 
(10, 'HR', 'Mumbai'),
(20, 'IT', 'Delhi'),
(30, 'Finance', 'Kolkata'),
(40, 'Marketing', 'Chennai');

INSERT INTO employee VALUES
(1001, 'Alice', 10, 55000.00, '1990-05-12', 'Mumbai'),
(1002, 'Bob', 20, 62000.50, '1988-03-20', 'Delhi'),
(1003, 'Charlie', 30, 47000.75, '1992-08-15', 'Kolkata'),
(1004, 'Diana', 10, 58000.00, '1991-11-02', 'Pune'),
(1005, 'Ethan', 40, 75000.00, '1985-07-30', 'Chennai'),
(1006, 'Fiona', 20, 69000.00, '1993-01-15', 'Delhi');

-- 1. View with JOIN and subquery (complex SELECT)
CREATE VIEW emp_dept_view AS
SELECT 
  e.empno,
  e.empname,
  d.deptname,
  e.salary,
  (SELECT AVG(salary) 
   FROM employee e2 
   WHERE e2.deptno = e.deptno) AS dept_avg_salary,
  e.salary - (SELECT AVG(salary) 
              FROM employee e2 
              WHERE e2.deptno = e.deptno) AS salary_diff,
  d.location
FROM employee e
JOIN deptmst d ON e.deptno = d.deptno;

-- 2. Public-facing view without sensitive salary data
CREATE VIEW emp_public_view AS
SELECT 
  empname,
  deptno,
  city
FROM employee;

-- 3. View for department-wise employee count
CREATE VIEW dept_emp_count_view AS
SELECT 
  d.deptname,
  COUNT(e.empno) AS emp_count
FROM deptmst d
LEFT JOIN employee e ON d.deptno = e.deptno
GROUP BY d.deptno, d.deptname;

-- 4. View for employees earning above department average
CREATE VIEW high_earners_view AS
SELECT 
  empname,
  salary,
  deptno
FROM employee e1
WHERE salary > (
  SELECT AVG(salary)
  FROM employee e2
  WHERE e1.deptno = e2.deptno
);

-- 5. View for HR department employees only
CREATE VIEW hr_employees_view AS
SELECT 
  empname,
  salary,
  city
FROM employee
WHERE deptno = (
  SELECT deptno FROM deptmst WHERE deptname = 'HR'
);

-- 6. View for employees born before 1990 (age-based abstraction)
CREATE VIEW senior_employees_view AS
SELECT 
  empname,
  dob,
  city
FROM employee
WHERE dob < '1990-01-01';

-- 7. View with calculated age (requires JULIANDAY in SQLite)
CREATE VIEW emp_with_age_view AS
SELECT 
  empname,
  dob,
  CAST((julianday('now') - julianday(dob)) / 365 AS DECIMAL) AS age,
  city
FROM employee;

-- 8. View that abstracts city-wise employee count
CREATE VIEW city_emp_distribution AS
SELECT 
  city,
  COUNT(*) AS total_employees
FROM employee
GROUP BY city;

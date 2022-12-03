SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE employee_hire_sp ( 
 p_first_name VARCHAR2, 
 p_last_name VARCHAR2, 
 p_email VARCHAR2, 
 p_phone VARCHAR2,
 p_hire_date DATE,
 p_job_id VARCHAR2,  
 p_salary NUMBER,
 p_manager_id NUMBER,
 p_department_id NUMBER) 
IS 
BEGIN 
 INSERT INTO hr_employees(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id) 
 VALUES (hr_employees_seq.NEXTVAL, p_first_name, p_last_name, p_email,  p_phone, TRUNC(SYSDATE), p_job_id, p_salary, p_manager_id, p_department_id); 
COMMIT;
END employee_hire_sp; 
/ 
---------------------------------
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE employee_hire_sp ( 
 p_first_name hr_employees.first_name%TYPE, 
 p_last_name  hr_employees.last_name%TYPE, 
 p_email hr_employees.email%TYPE, 
 p_phone hr_employees.phone_number%TYPE, 
 p_hire_date hr_employees.hire_date%TYPE,  
 p_job_id hr_employees.job_id%TYPE,
 p_salary hr_employees.salary%TYPE, 
 p_manager_id hr_employees.manager_id%TYPE, 
 p_department_id hr_employees.department_id%TYPE) 
IS 
BEGIN 
 INSERT INTO hr_employees(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id) 
 VALUES (hr_employees_seq.NEXTVAL, p_first_name, p_last_name, p_email,  p_phone, TRUNC(SYSDATE), p_job_id, p_salary, p_manager_id, p_department_id); 
COMMIT;
END employee_hire_sp; 
/
----------------------------
SELECT * FROM hr_employees where job_id = 'SA_REP';

DROP PROCEDURE employee_hire_sp;
select * from hr_employees;

DELETE FROM hr_employees WHERE employee_id= 212;
--Test
EXECUTE employee_hire_sp('Brandon', 'Tomy', 'tomy@brandon', '647.765.3355', '01-JAN-99', 'IT_PROG', 5000, 103, 60)
SELECT * FROM hr_employees where job_id = 'IT_PROG';
----------------------------------------
--Task 1-3  : Sample: SQL 
UPDATE HR_EMPLOYEES SET SALARY= 5500 WHERE employee_id= 214; 
----- create procedure 
CREATE OR REPLACE PROCEDURE update_salary
(p_employee_id IN hr_employees.employee_id%TYPE,
p_percent IN NUMBER)
IS
BEGIN
UPDATE hr_employees
SET salary = salary * (1 + p_percent/100)
WHERE employee_id = p_employee_id;
END update_salary;
/
EXECUTE update_salary(214, 5)

----------------
--Q2
 
CREATE OR REPLACE FUNCTION get_job (
 p_job_id VARCHAR2) 
 RETURN VARCHAR2
 IS 
 v_job_title hr_jobs.job_title%type; 
BEGIN 
 SELECT job_title 
 INTO v_job_title 
 FROM hr_jobs 
 WHERE job_id = p_job_id; 
 RETURN v_job_title; 
END get_job; 
/
--Execute--------
VARIABLE job_title VARCHAR2(50) 
EXECUTE :job_title := get_job ('SA_REP'); 
PRINT job_title 

select * from hr_jobs;
----------------------
-- Task 2-2  
--Before
UPDATE hr_jobs SET job_title = 'ACCOUNTANT' WHERE job_id = 'FI_ACCOUNT'; 
-- After
UPDATE hr_jobs SET job_title = 'FIN- ACCOUNTANT' WHERE job_id = 'FI_ACCOUNT';
COMMIT; 
--OR
UPDATE hr_jobs SET min_salary = 8500 WHERE job_id = 'FI_ACCOUNT';
COMMIT; 
--Before
UPDATE hr_jobs SET min_salary = 4200 WHERE job_id = 'FI_ACCOUNT';

-----------------
-- Task 2-2  Store Procedure
create or replace PROCEDURE update_job
( 
 p_jobid hr_jobs.job_id%TYPE, 
 p_title hr_jobs.job_title%TYPE,
 v_minsal hr_jobs.min_salary%TYPE,
 v_maxsal hr_jobs.max_salary%TYPE
 ); 
BEGIN 
 INSERT INTO hr_jobs(job_id, job_title, min_salary, max_salary) 
 VALUES (p_jobid, p_title, v_minsal, v_maxsal); 
 DBMS_OUTPUT.PUT_LINE ('Update row added to HR_JOBS table:'); 
 DBMS_OUTPUT.PUT_LINE (p_jobid || ' ' || p_title ||' '|| 
 v_minsal || ' ' || v_maxsal); 
 COMMIT;
END update_job;
/

-----------------------
--Task 2-3  Create a New JOB
CREATE OR REPLACE PROCEDURE new_job( 
 p_jobid IN hr_jobs.job_id%TYPE, 
 p_title IN hr_jobs.job_title%TYPE, 
 v_minsal IN hr_jobs.min_salary%TYPE) IS 
 v_maxsal hr_jobs.max_salary%TYPE := 2 * v_minsal; 
BEGIN 
 INSERT INTO hr_jobs(job_id, job_title, min_salary, max_salary) 
 VALUES (p_jobid, p_title, v_minsal, v_maxsal); 
 DBMS_OUTPUT.PUT_LINE ('New row added to JOBS table:'); 
 DBMS_OUTPUT.PUT_LINE (p_jobid || ' ' || p_title ||' '|| 
 v_minsal || ' ' || v_maxsal);
 COMMIT;
END new_job; 
/ 
-----------------
-- Task 2-3 GUI work
EXECUTE new_job ('AS_MAN', 'Assistant Manager', 3500, 5500) 

EXECUTE new_job ('AS_MAN', 'Assistant Manager', 3500) 

SELECT * FROM hr_jobs WHERE job_id = 'AS_MAN'; 
COMMIT; 
-----------------------------
-- Task 3a � Creating a Trigger and also a Store Procedure to verify and check 
-- any Job�s minimum and Maximum Salary range if they are in acceptable limit

CREATE OR REPLACE PROCEDURE check_salary (p_the_job VARCHAR2, 
p_the_salary NUMBER) IS 
 v_minsal hr_jobs.min_salary%type; 
 v_maxsal hr_jobs.max_salary%type; 
BEGIN 
 SELECT min_salary, max_salary INTO v_minsal, v_maxsal 
 FROM hr_jobs 
 WHERE job_id = UPPER(p_the_job); 
 IF p_the_salary NOT BETWEEN v_minsal AND v_maxsal THEN 
 RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_the_salary ||'. '|| 
 'Salaries for job '|| p_the_job || 
 ' must be between $'|| v_minsal ||' and $' || v_maxsal); 
 END IF; 
END; 
/ 

-- Task 3b
CREATE OR REPLACE TRIGGER check_salary_trg 
BEFORE INSERT OR UPDATE OF job_id, salary 
ON hr_employees 
FOR EACH ROW 
BEGIN 
 check_salary(:new.job_id, :new.salary); 
END; 
/ 
select * from hr_jobs;
select * from hr_employees;

-----
-- Test case 1
EXECUTE employee_hire_sp('Elenor', 'Beh', 'elenor@beh', 'SA_REP', 1000, 145, 30)
-- Test case 2
UPDATE hr_employees SET salary = 2000 WHERE employee_id = 115; 
-- Test case 3
UPDATE hr_ employees  SET job_id = 'HR_REP' WHERE employee_id = 115; 










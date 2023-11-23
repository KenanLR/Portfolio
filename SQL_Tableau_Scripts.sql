use employees_mod;

-- TASK 1: Breakdown of Male to Female employees
SELECT 
    YEAR(d.from_date) AS calendar_year,
    e.gender AS gender,
    COUNT(*) AS number_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp d ON e.emp_no = d.emp_no
GROUP BY calendar_year , gender
HAVING calendar_year >= '1990'
ORDER BY calendar_year;

-- TASK 2: Comparison of Male to Female Managers from different departments for each year
SELECT
	d.dept_name,
    ee.gender,
    m.emp_no,
    m.from_date,
    m.to_date,
    e.calendar_year,
    CASE
		WHEN e.calendar_year BETWEEN YEAR(m.from_date) AND YEAR(m.to_date) THEN 1 ELSE 0 
	END AS active
FROM
	(SELECT DISTINCT
		YEAR(hire_date) as calendar_year
	FROM t_employees
    HAVING calendar_year >= '1990'
    ORDER BY calendar_year) e
    CROSS JOIN
    t_dept_manager m
    JOIN
    t_departments d ON m.dept_no = d.dept_no
    JOIN
	t_employees ee ON m.emp_no = ee.emp_no
ORDER BY  m.emp_no, e.calendar_year;

-- TASK 3: Compare Average salary of female vs Male employees in the entire company until 2002 with filters for departments
SELECT
	e.gender,
    d.dept_name,
    ROUND(AVG(s.salary),2) as salary,
    YEAR(s.from_date) as calendar_year
FROM
	t_employees e
		JOIN
        t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
        t_departments d ON de.dept_no = d.dept_no
        JOIN
        t_salaries s ON de.emp_no = s.emp_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= '2002' and calendar_year >= '1990'
ORDER BY d.dept_no;

-- TASK 4: Create a Stored Procedure that allows you to obtain the average male and female salary per department within a certain salary range that the user inputs
SELECT MIN(salary) FROM t_salaries;

SELECT MAX(salary) FROM t_salaries;

DROP PROCEDURE IF EXISTS filter_avg_salary;
DELIMITER $$
CREATE PROCEDURE filter_avg_salary(IN p_lower_bound FLOAT, IN p_upper_bound FLOAT)
BEGIN
SELECT
	e.gender,
    d.dept_name,
    ROUND(AVG(s.salary),2) as salary
FROM
	t_salaries s
		JOIN
	t_employees e ON s.emp_no = e.emp_no
		JOIN
	t_dept_emp de ON e.emp_no = de.emp_no
		JOIN
	t_departments d ON de.dept_no = d.dept_no
WHERE s.salary BETWEEN p_lower_bound AND p_upper_bound
GROUP BY d.dept_no, e.gender
ORDER BY d.dept_no;
END$$
DELIMITER ;

CALL filter_avg_salary(50000, 90000)
	
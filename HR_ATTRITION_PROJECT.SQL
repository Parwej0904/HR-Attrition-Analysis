create database HR;
use HR;

rename table `HR_Employee.csv`
to hr_employee;

-- 1. display the first 10 rows from the table
select * from hr_employee
limit 10;

-- 2. find the total number of employees in the company
select count(*) as total_employees
from hr_employee;

-- 3. list all unique departments
select distinct department
from hr_employee;

-- 4. show how many employees have left the company and how many are still working
select attrition, count(*) as employee_count
from hr_employee
group by attrition;

-- 5. retrieve the list of employees who work overtime
select *
from hr_employee
where overtime = 'Yes';

-- 6. find the average monthly income of all employees
select avg(monthlyincome) as avg_monthly_income
from hr_employee;

-- 7. identify employees whose number of companies worked is missing (null)
select *
from hr_employee
where numcompaniesworked is null;

-- 8. find the employee(s) with the maximum monthly income
select *
from hr_employee
where monthlyincome = (
select max(monthlyincome)
from hr_employee
);

-- 9. count the number of employees by gender
select gender, count(*) as total_employees
from hr_employee
group by gender;

-- 10. list all employees who have just joined (yearsatcompany = 0)
select *
from hr_employee
where yearsatcompany = 0;

-- 11. calculate the attrition rate (%) by department
select department,
round(
sum(case when attrition='es' then 1 else 0 end)*100.0/count(*),2
) as attrition_rate
from hr_employee
group by department;

-- 12. list the top 10 employees with the highest total working years
select *
from hr_employee
order by totalworkingyears desc
limit 10;

-- 13. group employees into tenure categories (<1yr, 1-3yr, 4-6yr, 7+yr)
select
case
when yearsatcompany < 1 then '<1yr'
when yearsatcompany between 1 and 3 then '1-3yr'
when yearsatcompany between 4 and 6 then '4-6yr'
else '7+yr'
end as tenure_category,
count(*) as employee_count
from hr_employee
group by tenure_category;

-- 14. find the average monthly income by job level and attrition status
select joblevel, attrition,
round(avg(monthlyincome),2) as avg_income
from hr_employee
group by joblevel, attrition;

-- 15. identify the top 5 job roles with the highest number of employees who left
select jobrole,
count(*) as employees_left
from hr_employee
where attrition='Yes'
group by jobrole
order by employees_left desc
limit 5;

-- 16. list employees who left the company within their first year
select *
from hr_employee
where attrition='Yes'
and yearsatcompany <= 1;

-- 17. determine the median monthly income of all employees
select * from hr_employee;
with ordered as (
    select 
        monthlyincome,
        row_number() over (order by monthlyincome) AS rn,
        count(*) over () as total_rows
    from hr_employee
)
select avg(monthlyincome) AS median_income
from ordered
where rn in (
    floor((total_rows + 1) / 2),
    floor((total_rows + 2) / 2)
);

-- 18. calculate each employee’s approximate new monthly compensation after applying salary hike percentage
select employeenumber,
monthlyincome,
percentsalaryhike,
round(
monthlyincome +
(monthlyincome*percentsalaryhike/100.0),2
) as new_monthly_compensation
from hr_employee;

-- 19. count employees grouped by overtime status and attrition
select overtime, attrition,
count(*) as employee_count from hr_employee
group by overtime, attrition;

-- 20. display the top 10 employees who attended the most training sessions last year
select * from hr_employee
order by trainingtimeslastyear desc limit 10;

-- 21. rank employees by total working years (most experienced = rank 1)
select employeenumber, totalworkingyears,
rank() over(order by totalworkingyears desc)
as experience_rank from hr_employee;

-- 22. for each department, find employees whose monthly income is in the top 25% of that department
select *
from (
select *,
ntile(4) over(
partition by department
order by monthlyincome desc
) as income_quartile
from hr_employee
) t
where income_quartile = 1;

-- 23. divide employees into 10 income deciles and find attrition rate for each decile
select income_decile,
round(
sum(case when attrition='Yes' then 1 else 0 end)*100.0/count(*),2
) as attrition_rate
from (
select *,
ntile(10) over(order by monthlyincome)
as income_decile
from hr_employee
) t
group by income_decile
order by income_decile;

-- 24. create a simple risk score based on tenure, performance, overtime and work life balance
select *,
(
case when yearsatcompany < 2 then 3 else 1 end +
case when performancerating <= 2 then 3 else 1 end +
case when overtime='yes' then 3 else 1 end +
case when worklifebalance <= 2 then 3 else 1 end
) as risk_score
from hr_employee
order by risk_score desc
limit 50;

-- 25. create a summary view showing for each department and job level
create or replace view department_summary as
select
    department,
    joblevel,
    count(*) as total_employees,
    sum(case when attrition = 'Yes' then 1 else 0 end) as leavers,
    round(
        sum(case when attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*),
        2
    ) as attrition_rate,
    round(avg(monthlyincome), 2) as avg_monthly_income
from hr_employee
group by department, joblevel;
================= create employee table ================
DROP TABLE IF EXISTS Employee ;
CREATE TABLE Employee (
	emp_id CHARACTER VARYING(10) PRIMARY KEY,
	emp_name CHARACTER VARYING (50),
	email CHARACTER VARYING (100),
	hire_date DATE, 
	salary INTEGER);
	
================= create Education table ================
DROP TABLE IF EXISTS Education ;	 
CREATE TABLE Education (
    ed_id Serial PRIMARY KEY ,
	educational_level CHARACTER VARYING (50));
	
================= create Department table ================
		   
DROP TABLE IF EXISTS Department ;
CREATE TABLE Department (
    department_id Serial PRIMARY key ,
	department_name CHARACTER VARYING (50));
	
================= create Location table ================
	
DROP TABLE IF EXISTS Location ;
CREATE TABLE Location (
    location_id serial PRIMARY KEY ,
	location CHARACTER VARYING (50),
	City CHARACTER VARYING (50))
	State CHARACTER VARYING (50);
	
================= create Job table ================

DROP TABLE IF EXISTS Job; 
CREATE TABLE Job (
   job_id serial PRIMARY KEY , 
   job_title CHARACTER VARYING (100)); 

================= create employment_history table ================

DROP TABLE IF EXISTS employment_history; 
CREATE TABLE  employment_history (
   emp_id CHARACTER VARYING (10) ,
   location_id INTEGER,
   department_id INTEGER,
   manager_id CHARACTER VARYING (10),
   ed_id INTEGER,
   job_id INTEGER,
   start_date DATE,
   end_date DATE);
   
   
CREATE VIEW manager 
AS SELECT s.emp_id AS manager_id, 
p.manager AS manager_name
FROM proj_stg AS p 
FULL JOIN (SELECT DISTINCT emp_id, emp_nm FROM proj_stg
WHERE emp_nm IN (SELECT DISTINCT manager FROM proj_stg)) AS s
ON p.manager=s.emp_nm;
   
-------------------------- add Forign keyies constrains ----------------
--can be cerated like this 
ALTER TABLE Employment_history 
ADD FOREIGN KEY (emp_id) REFERENCES Employee(emp_id), 
ADD FOREIGN KEY (location_id) REFERENCES location(location_id),
ADD FOREIGN KEY (ed_id) REFERENCES educationallevel(ed_id),
ADD FOREIGN KEY (job_id) REFERENCES job(job_id),
ADD FOREIGN KEY (department_id) REFERENCES department(department_id),
ADD FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);
--------------------------------------------------------------------------
--or this 
alter table Employment_history
add constraint FK_emp_id Foreign key (emp_id) REFERENCES Employee(emp_id),
add constraint FK_manager_id Foreign key (manager_id) REFERENCES Employee(emp_id),
add constraint FK_location_id Foreign key (location_id) REFERENCES location(location_id),
add constraint FK_education_id Foreign key (education_id) REFERENCES educaion(educational_level),
add constraint FK_job_id Foreign key (job_id) REFERENCES job(job_id),
add constraint FK_department_id Foreign key (department_id) REFERENCES department(department_id);


-------------------------- insert the data from staging table  ----------------

insert into job(job_title) 
SELECT DISTINCT job_title from proj_stg 

insert into location(location,city) 
SELECT DISTINCT location , city from proj_stg 

insert into education(educational_level) 
SELECT DISTINCT education_lvl from proj_stg 

insert into department (department_name)
select distinct department_nm from proj_stg

INSERT INTO Employee (emp_id , emp_name , email , hire_date , salary ) 
SELECT DISTINCT emp_id , emp_nm , email , hire_dt, salary   FROM proj_stg 


insert into employment_history 
select p.emp_id , L.location_id , d.department_id , M.emp_id , ed.ed_id ,j.job_id 
from proj_stg P 
join location L on P.location = L.location 
join department d on P.department_nm = d.department_name
left join proj_stg M on M.emp_nm = p.MANAGER
join education ed on P.education_lvl = ed.educational_level
join job j on p.job_title = j.job_title ;


-- Question 1: Return a list of employees with Job Titles and Department Names

select e.emp_name , job_title , department_name from 
employee e 
join employment_history eh on e.emp_id = eh.emp_id
join job j on j.job_id = eh.job_id
join department d on d.department_id = eh.department_id

-- Question 2: Insert Web Programmer as a new job title

insert into job(job_title) values('Web programmer')

-- Question 3: Correct the job title from web programmer to web developer

update job set job_title ='web developer'
where job_id = 11
     
-- Question 4: Delete the job title Web Developer from the database

delete from job 
where job_id = 11
	 
-- Question 5: How many employees are in each department?
	 
select count(*) , department_name 
from employee e
join employment_history eh on e.emp_id = eh.emp_id 
join department d on d.department_id = eh.department_id
group by 2

--Question 6: Write a query that returns current and past jobs (include employee name, job title, department, 
--manager name, start and end date for position) for employee Toni Lembeck.

select e.emp_name , job_title , department_name , M.EMP_NAME as "Manager Name"
from employment_history eh  
join employee e on eh.emp_id = e.emp_id 
join job j on eh.job_id = j.job_id 
join department d on eh.department_id = d.department_id 
JOIN employee M ON eh.manager_id = M.EMP_ID 
where e.emp_name = 'Toni Lembeck'

/* CLEANING DATA AND EXAMINING IN Microsoft SQL */
--Views, Temp Tables, Subqueries, Joins, EDA & Data Cleaning

-------------------------------------------------------------------------------------------------------------
/* AGE DATA */

--dataset
SELECT A.*
FROM PortfolioProject..ages A;

--no of age areas (51)
SELECT COUNT( DISTINCT A.code) no_age_areas
FROM PortfolioProject..ages A;

--check for nulls (no nulls)
SELECT A.*
FROM PortfolioProject..ages A
WHERE A.age is null or A.no_females is null or A.no_males is null;


--CLEANING DATA

--Keep the date column as a consistent data type INT
ALTER TABLE PortfolioProject..ages
ALTER COLUMN date INT;


--CLEAN DATASET
SELECT A.*
FROM PortfolioProject..ages A;

-------------------------------------------------------------------------------------------------------------
/* DWELLINGS DATA */

--dataset
SELECT A.*
FROM PortfolioProject..dwellings A;

--no dwelling areas (33)
SELECT COUNT( DISTINCT A.code) no_dwellings_areas
FROM PortfolioProject..dwellings A;

--check for nulls (no nulls)
SELECT A.*
FROM PortfolioProject..dwellings A
WHERE A.no_dwellings is null or A.dwellings_per_hect is null;

--date range (2001-2019)
SELECT DISTINCT date
FROM PortfolioProject.dbo.dwellings;

--CLEANING DATA--

--we need to standardise our date format to just be the year
SELECT date, YEAR(date)
FROM PortfolioProject.dbo.dwellings;

ALTER TABLE PortfolioProject..dwellings
ADD date_converted INT;

UPDATE PortfolioProject..dwellings
SET date_converted = YEAR(date);

ALTER TABLE PortfolioProject..dwellings
DROP COLUMN date;

--renamed as date using the GUI

--CLEAN DATASET
SELECT *
FROM PortfolioProject..dwellings;

-------------------------------------------------------------------------------------------------------------
/* RECYCLING DATA */

--dataset
SELECT *
FROM PortfolioProject..household_recycling;

--no dwelling areas (43)
SELECT COUNT( DISTINCT code) no_recycling_areas
FROM PortfolioProject..household_recycling;

--check for nulls (no nulls)
SELECT *
FROM PortfolioProject..household_recycling
WHERE code is null or area is null or Year is null or Recycling_Rates is null;

--date range (2004-2020)
SELECT DISTINCT Year
FROM PortfolioProject.dbo.household_recycling;

--CLEANING DATA--

--we need to standardise our date format removing the slash
SELECT CONCAT(SUBSTRING(Year, 1,2), SUBSTRING(Year, 6,7)) as date
FROM PortfolioProject.dbo.household_recycling;

ALTER TABLE PortfolioProject..household_recycling
ADD date INT;

UPDATE PortfolioProject..household_recycling
SET date = CONCAT(SUBSTRING(Year, 1,2), SUBSTRING(Year, 6,7));

ALTER TABLE PortfolioProject..household_recycling
DROP COLUMN Year;


--CLEAN DATASET
SELECT *
FROM PortfolioProject..household_recycling;

-------------------------------------------------------------------------------------------------------------
/* JOBS DATA */

--dataset
SELECT *
FROM PortfolioProject..jobs_and_job_density;

--no dwelling areas (49)
SELECT COUNT( DISTINCT code) no_jobs_areas
FROM PortfolioProject..jobs_and_job_density;

--check for nulls (no nulls)
SELECT *
FROM PortfolioProject..jobs_and_job_density
WHERE code is null or area is null or year is null or number_of_jobs is null or job_density is null;

--date range (2000-2019)
SELECT DISTINCT year
FROM PortfolioProject.dbo.jobs_and_job_density
ORDER BY year;

--CLEANING DATA--

--Keep the year column as a consistent data type INT
ALTER TABLE PortfolioProject..jobs_and_job_density
ALTER COLUMN year INT;

--renamed as date using the GUI

--CLEAN DATASET
SELECT *
FROM PortfolioProject..jobs_and_job_density;

-------------------------------------------------------------------------------------------------------------
/* PAY DATA */

--dataset
SELECT *
FROM PortfolioProject..london_pay;

--no dwelling areas (46)
SELECT COUNT( DISTINCT code) no_pay_areas
FROM PortfolioProject..london_pay;

--check for nulls (4 nulls: 2014-2019, Kensington and Chelsea, male_hourly_pay)
SELECT *
FROM PortfolioProject..london_pay
WHERE code is null or area is null or total_hourly_pay is null or male_hourly_pay is null or female_hourly_pay is null;

--date range (2002-2020)
SELECT DISTINCT date
FROM PortfolioProject.dbo.london_pay
ORDER BY date;

--CLEANING DATA--

--updating the date to be an INT year
SELECT CONVERT(INT, FORMAT(date,'yyyy')) date_coverted
FROM PortfolioProject..london_pay;

ALTER TABLE PortfolioProject..london_pay
ADD date_converted INT;

UPDATE PortfolioProject..london_pay
SET date_converted = CONVERT(INT, FORMAT(date,'yyyy'));

ALTER TABLE PortfolioProject..london_pay
DROP COLUMN date;

--renamed as date using the GUI

--replacing null values: total provides an average of male & female
--taking an assumed 50/50 demographic split we can use [(total*2) - female_hourly_pay] to give a proxy for male_hourly_pay


SELECT ((total_hourly_pay*2) - female_hourly_pay) male_pay , female_hourly_pay, total_hourly_pay
FROM PortfolioProject..london_pay
WHERE male_hourly_pay is null;

ALTER TABLE PortfolioProject..london_pay
ADD male_pay FLOAT;



SELECT male_pay, female_hourly_pay, total_hourly_pay
, CASE
	WHEN male_hourly_pay is null THEN ((total_hourly_pay*2) - female_hourly_pay)
	ELSE male_hourly_pay
	END
	as new_column
FROM PortfolioProject..london_pay
WHERE male_hourly_pay is null;

UPDATE PortfolioProject..london_pay
SET male_pay = CASE WHEN male_hourly_pay is null THEN ((total_hourly_pay*2) - female_hourly_pay)
	ELSE male_hourly_pay
	END;

ALTER TABLE PortfolioProject..london_pay
DROP COLUMN male_hourly_pay;

--rename male_pay using GUI

--CLEAN DATASET
SELECT *
FROM PortfolioProject..london_pay;

-------------------------------------------------------------------------------------------------------------
/* WELL BEING DATA */

--dataset
SELECT *
FROM PortfolioProject..well_being;

--no dwelling areas (46)
SELECT COUNT( DISTINCT code) no_well_being_areas
FROM PortfolioProject..well_being;

--check for nulls (no nulls)
SELECT *
FROM PortfolioProject..well_being
WHERE code is null or area is null or date is null or life is null or anxiouos is null or happy is null;

--date range (2012-2019)
SELECT DISTINCT date
FROM PortfolioProject.dbo.well_being
ORDER BY date;

--CLEANING DATA--

--we need to standardise our date format removing the slash
SELECT CONCAT(SUBSTRING(date, 1,2), SUBSTRING(date, 6,7)) as new_date
FROM PortfolioProject.dbo.well_being;

ALTER TABLE PortfolioProject..well_being
ADD new_date INT;

UPDATE PortfolioProject..well_being
SET new_date = CONCAT(SUBSTRING(date, 1,2), SUBSTRING(date, 6,7));

ALTER TABLE PortfolioProject..well_being
DROP COLUMN date;

--rename new_date using GUI

--CLEAN DATASET
SELECT *
FROM PortfolioProject..well_being;

-------------------------------------------------------------------------------------------------------------
/* HOUSING DATA */

--dataset
SELECT *
FROM PortfolioProject..london_housing;

--no dwelling areas (45)
SELECT COUNT( DISTINCT code) no_housing_areas
FROM PortfolioProject..london_housing;

--check for nulls (90 nulls: all in June and July)
SELECT *
FROM PortfolioProject..london_housing
WHERE date is null or area is null or average_price is null or code is null or houses_sold is null
ORDER BY date;

SELECT sum(case when houses_sold is null then 1 else 0 end) count_nulls
FROM PortfolioProject..london_housing;


--date range (Jan 1995 - July 2021)
SELECT DISTINCT date
FROM PortfolioProject.dbo.london_housing
ORDER BY date;

--CLEANING DATA--

/*We can use these values in multiple ways as it is monthly*/
--Method 1
---It would be interesting to predict house prices base on this data as it is so detialed
--Method 2
---We could merge this with other tables to create a larger db averaged for yearly info

--lets first change our date time column to just date
SELECT CONVERT(DATE, date, 103)
FROM PortfolioProject.dbo.london_housing;

ALTER TABLE PortfolioProject..london_housing
ADD date_converted Date;

UPDATE PortfolioProject..london_housing
SET date_converted = CONVERT(DATE, date, 103);

ALTER TABLE PortfolioProject..london_housing
DROP COLUMN date;

--rename new_date using GUI

--CLEAN DATASET
SELECT *
FROM PortfolioProject..london_housing;

--METHOD 1 (create monthly copy)
SELECT * INTO PortfolioProject..london_housing_monthly
FROM PortfolioProject..london_housing;

--METHOD 2 (create annual copy)
UPDATE PortfolioProject..london_housing;

WITH CTE_london_housing as 
(SELECT code, area, datepart(yyyy, date) as year, avg(borough_flag) borough_flag , round(avg(houses_sold),2) houses_sold, round(avg(average_price),2) average_price
FROM PortfolioProject..london_housing
group by code, area, datepart(yyyy, date)
)
SELECT * INTO PortfolioProject..london_housing_annual
FROM CTE_london_housing
ORDER BY area;

SELECT *
FROM PortfolioProject..london_housing_annual;

--rename using GUI

-------------------------------------------------------------------------------------------------------------

/* COMBINE THESE TABLES */
SELECT *
FROM PortfolioProject..ages;

SELECT *
FROM PortfolioProject..dwellings;

SELECT *
FROM PortfolioProject..household_recycling;

SELECT *
FROM PortfolioProject..london_housing_annual;

SELECT *
FROM PortfolioProject..london_pay;

SELECT *
FROM PortfolioProject..well_being;

--as we will be mainly intereseted in the housing value we shall join based on this table 
WITH CTE_merged_london_housing as
(SELECT
	housing.code,
	housing.date,
	housing.area,
	housing.borough_flag,
	housing.average_price,
	housing.houses_sold,
	ages.age,
	ages.no_males,
	ages.no_females,
	dwellings.dwellings_per_hect,
	dwellings.no_dwellings,
	recycling.Recycling_Rates,
	well_being.life,
	well_being.anxiouos,
	well_being.happy,
	well_being.worth,
	pay.total_hourly_pay,
	pay.male_hourly_pay,
	pay.female_hourly_pay
FROM
	PortfolioProject..london_housing_annual housing
		LEFT OUTER JOIN
	PortfolioProject..ages ages 
			ON housing.date = ages.date
			AND housing.code = ages.code
		LEFT OUTER JOIN
	PortfolioProject..dwellings dwellings 
			ON housing.date = dwellings.date
			AND housing.code = dwellings.code
		LEFT OUTER JOIN
	PortfolioProject..household_recycling recycling
			ON housing.date = recycling.date
			AND housing.code = recycling.code
		LEFT OUTER JOIN
	PortfolioProject..well_being well_being
			ON housing.date = well_being.date
			AND housing.code = well_being.code
		LEFT OUTER JOIN
	PortfolioProject..london_pay pay
			ON housing.date = pay.date_converted
			AND housing.area = pay.area
)
SELECT * INTO PortfolioProject..london_annual_data
FROM CTE_merged_london_housing
ORDER BY area, date;

SELECT *
FROM PortfolioProject..london_annual_data;

-------------------------------------------------------------------------------------------------------------

/* Cleaning combined */

--we arent so interested in the non boruogh regions as most of this data is contained in the bourough anyway

DELETE FROM PortfolioProject..london_annual_data
WHERE borough_flag = 0;

SELECT *
FROM PortfolioProject..london_annual_data
WHERE date = 1995;

--most consistant data runs FROM 2004 onward so we shall remove data which is before this year 
DELETE FROM PortfolioProject..london_annual_data
WHERE date < 2004;

--most data also does not run for 2021
DELETE FROM PortfolioProject..london_annual_data
WHERE date=2021;


--we now have a good amount of clean data however the columns life, anxious, happy and worth all conatin allot of null values

SELECT *
FROM PortfolioProject..london_annual_data
WHERE date is null or code is null or date is null or code is null or houses_sold is null
ORDER BY date;


--There are 4 places that contain no data for pay however most other values are populated so we shall leave these places in for our EDA
SELECT *
FROM PortfolioProject..london_annual_data
WHERE area in (
SELECT DISTINCT area
FROM PortfolioProject..london_annual_data
WHERE total_hourly_pay is null)

SELECT *
FROM PortfolioProject..london_annual_data;

-------------------------------------------------------------------------------------------------------------

/* EDA */

SELECT area, date, ROUND(AVG(average_price),2) price
FROM PortfolioProject..london_annual_data
group by area, date
having date = 2019
order by price DESC;


--Kensington & Chelsea is the most expensive area, lets explore the stats
SELECT *
FROM PortfolioProject..london_annual_data
WHERE area = 'Kensington & Chelsea' and date=2019

--relitive equal number of males and females, 7.38 happiness, middle aged (35-41), low number of children
--most wealthy people therefore seem to be middle aged couples
SELECT area, age, no_males, no_females, happy, (no_males+no_females) no_people
FROM PortfolioProject..london_annual_data
WHERE area = 'Kensington & Chelsea' and date=2019
order by no_people DESC

SELECT SUM(no_males) males, SUM(no_females) females
FROM PortfolioProject..london_annual_data
WHERE area = 'Kensington & Chelsea' and date=2019

--Barking & Dagenham is the least expensive area, lets explore the stats
SELECT *
FROM PortfolioProject..london_annual_data
WHERE area = 'Barking & Dagenham' and date=2019

--relitive equal number of males and females, 7.67 happiness, young aged(0-10), high number of children
--least wealthy people therefore seem to be young parents/large families
SELECT area, age, no_males, no_females, happy, (no_males+no_females) no_people
FROM PortfolioProject..london_annual_data
WHERE area = 'Barking & Dagenham' and date=2019
order by no_people DESC

SELECT SUM(no_males) males, SUM(no_females) females
FROM PortfolioProject..london_annual_data
WHERE area = 'Barking & Dagenham' and date=2019


--Subquery
--The highest demographic (age) are FROM 2-7 showing a findings above more clearly
SELECT TOP 5 sub.no_people, sub.area, sub.age 
FROM (
SELECT area, age, no_males, no_females, happy, (no_males+no_females) no_people
FROM PortfolioProject..london_annual_data
WHERE area = 'Barking & Dagenham' and date=2019
) sub
order by sub.no_people DESC




--Let create a view to display this information
CREATE VIEW RichPoor as
SELECT poor.age, poor.area low_inc_area, poor.no_males low_inc_male, poor.no_females low_inc_female, poor.no_people low_inc_people, rich.area high_inc_area, rich.no_males high_inc_male, rich.no_females high_inc_female, rich.no_people high_inc_people
FROM
	(SELECT area, age, no_males, no_females, happy, (no_males+no_females) no_people
	FROM PortfolioProject..london_annual_data
	WHERE area = 'Barking & Dagenham' and date=2019) poor
FULL OUTER JOIN 
	(SELECT area, age, no_males, no_females, happy, (no_males+no_females) no_people
	FROM PortfolioProject..london_annual_data
	WHERE area = 'Kensington & Chelsea' and date=2019) rich
ON
	(poor.age = rich.age)

SELECT *
FROM PortfolioProject..RichPoor

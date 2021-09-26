--View the tables to make sure everything loaded in correctly
SELECT *
FROM PortfolioProject.dbo.CovidDeaths;

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations;

--COVID DEATHS TABLE

--Lets view a subsection of key columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2;

--Total Cases vs Total Deaths for UK
/*A random individual from the UK who caught COVID some time between 31/01/2021 and Today had a 1.86% chance of death*/
/*It is promising to note that, using domain knowledge, the application of vaccinations seems to be reducing the chance of death*/
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Kingdom%'
ORDER BY location, Date;

--Total Cases vs Population
/*1 in 10 people have had for COVID in the UK (conditional on testing positive)*/
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) as CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Kingdom%'
ORDER BY location, date;


--CONTINENTS ARE IN THE COUNTRY LOCATION COLUMN. WE MUST ACCOUNT FOR THIS IN OUR WHERE CLAUSE FOR DATA INTEGRITY

-- Countries with highest percentage infection population
/*The individuals in the Seychelles seem the most likley to have caught COVID*/
/*The UK rank at 21st*/
SELECT location, population, MAX(total_cases) as Cases, ROUND(MAX((total_cases/population)*100),2) as CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CasesPercentage DESC;

-- Total Deaths
/*The US has the highest death count, partially due to population size*/
/*The UK rank at 8th*/
SELECT location, MAX(cast(total_deaths as int)) as Deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Deaths DESC;

/*Americas have the highest death count*/
SELECT continent,  MAX(cast(total_deaths as int)) as Deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Deaths DESC;

--Global deaths per day
SELECT date as Date, MAX(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, 
(SUM(cast(new_deaths as int))/MAX(new_cases))*100 as Percentage --total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY Date;


--COVID VACCINATION TABLE

--Joining the datasets
SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;

--Vaccinations per day (with running total per country)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VacRunningTotal
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.continent, dea.location, dea.date


--Using CTE to use VacRunningTotal column in calculations
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, VacRunningTotal)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VacRunningTotal
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (VacRunningTotal/Population)*100
From PopvsVac;


--Using temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent VARCHAR(255),
	Location VARCHAR(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	VacRunningTotal numeric,
);

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VacRunningTotal
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null;

Select *, (VacRunningTotal/Population)*100
From #PercentPopulationVaccinated;

--Create view to store data for visualisations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VacRunningTotal
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null;


Select *
From PercentPopulationVaccinated

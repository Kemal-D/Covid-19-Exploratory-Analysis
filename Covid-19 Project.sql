/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4


--select *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select the starting data

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths (Death Percentage)
--Likelihood of dying if you contract Covid-19 in the Netherlands

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%netherlands%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of pupulation is infecrted with Covid-19

select Location, date, population, total_cases, (total_cases/population)*100 as PercentageofPopulationInfected
from [Portfolio Project]..CovidDeaths
where location like '%netherlands%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageofPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%netherlands%'
group by location, population
order by PercentageofPopulationInfected desc

-- Countries with highest death count per population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%netherlands%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Looking at the data by continent
--Continents with highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%netherlands%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Numbers Across the World

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%netherlands%'
where continent is not null
--group by date
order by 1,2

-- Dec 2021 Total Cases in the World

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%netherlands%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one Covid-19 vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous query
-- Total Population vs Vaccinations (vaccination rate and total vaccination at any given time)

With PopvsVac (continent, location, date, population, new_vaccinations, totalvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (TotalVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (totalvaccinated/population)*100
from PopvsVac

-- using temporary table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
totalvaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (TotalVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (totalvaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (TotalVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 

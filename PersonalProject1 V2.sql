
SELECT * 
FROM PortfolioProject1..CovidDeaths


--SELECT * 
--FROM PortfolioProject1..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2

-- looking at total cases vs. total deaths
-- shows rough likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs. population
--shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 as Population_Infected_Percentage
FROM PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Population_Infected_Percentage
FROM PortfolioProject1..CovidDeaths
group by location, population
order by Population_Infected_Percentage desc

--let's break things down by continent with highest death counts per population
SELECT MAX(cast(total_deaths as int)) as TotalDeathCount, location
FROM PortfolioProject1..CovidDeaths
WHERE continent is null
--where location like '%states%'
group by location
order by TotalDeathCount desc

--showing countries with highest death counts per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--where location like '%states%'
group by location
order by TotalDeathCount desc

--showing continents with the highest death counts per population
SELECT MAX(cast(total_deaths as int)) as TotalDeathCount, continent
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--where location like '%states%'
group by continent
order by TotalDeathCount desc

-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidVaccinations dea
JOIN PortfolioProject1..CovidDeaths vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidVaccinations dea
JOIN PortfolioProject1..CovidDeaths vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidVaccinations dea
JOIN PortfolioProject1..CovidDeaths vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated

-- creating a view table that shows highest death counts per country
Create View HighestDeathCountsPerCountry as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--where location like '%states%'
group by location
--order by TotalDeathCount desc

SELECT *
FROM HighestDeathCountsPerCountry

-- creating a view table that looks at countries with highest infection rate compared to population
Create View PopulationInfectedRate as
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Population_Infected_Percentage
FROM PortfolioProject1..CovidDeaths
group by location, population
--order by Population_Infected_Percentage desc

SELECT *
FROM PopulationInfectedRate
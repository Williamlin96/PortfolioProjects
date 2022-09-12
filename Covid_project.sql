--SELECT *
--FROM PortfolioProject..Covid_deaths
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..Covid_vaccinations
--WHERE continent is not null
--ORDER BY 3, 4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM PortfolioProject..Covid_deaths
ORDER BY 1, 2

--Now we are going to looking at Total Cases vs Total Deaths
-- This is the feasible of dying if you contact Covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM PortfolioProject..Covid_deaths
WHERE location like 'Thailand'
ORDER BY 1, 2

--Looking at Total Cases vs Total Population
--This is what percentage of population got Covid
SELECT location, date,  population, total_cases, (total_cases/population)*100 as infected_percentage
FROM PortfolioProject..Covid_deaths
WHERE Location like 'Thailand'
ORDER BY 1, 2

--Now looking at countires with highest infection rate compared to population
SELECT location,  population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as infected_percentage
FROM PortfolioProject..Covid_deaths
--WHERE Location like 'Thailand'
Group by location, population
ORDER BY infected_percentage desc

--This is the countires with highest death count per population.
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_deaths
--WHERE Location like 'Thailand'
WHERE continent is not null
Group by location
ORDER BY total_death_count desc

--This one is to categorize by continent but with the column of continent there are some issues with the number.
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_deaths
--WHERE Location like 'Thailand'
WHERE continent is not null
Group by continent
ORDER BY total_death_count desc

--However, with the location column all of the number are fixed.
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_deaths
--WHERE Location like 'Thailand'
WHERE continent is null
Group by location
ORDER BY total_death_count desc

--This one is showing continents witht he highest death count per population.
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
Group by continent
ORDER BY total_death_count desc

--world cases day by day
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--world total cases
SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
ORDER BY 1, 2

--join the two tables
SELECT *
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--This is going to look at total population vs vaccination

WITH popvsvac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as cumulative_vaccinations
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and new_vaccinations is not null
--ORDER BY 2, 3
)
 --use CTE
SELECT *, (cumulative_vaccinations/population)* 100 as total_vaccinated_percentage
FROM popvsvac
WHERE location like 'Thailand'

--Temp table

DROP TABLE IF exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as cumulative_vaccinations
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null and new_vaccinations is not null
--ORDER BY 2, 3

SELECT *, (cumulative_vaccinations/population)* 100 as total_vaccinated_percentage
FROM #PercentagePopulationVaccinated
WHERE location like 'Thailand'

--Create the view of the sotre data for visualizations

DROP VIEW IF exists PercentagePopulationVaccinated
GO
CREATE VIEW  dbo.PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as cumulative_vaccinations
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and new_vaccinations is not null





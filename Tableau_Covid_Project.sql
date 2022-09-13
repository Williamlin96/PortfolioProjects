
-- 1. Creating the table of total death_percentage(Global Numbers).

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Thailand'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- 2. Creating the table of total deaths count base on the continent.
-- European Union is part of Europe

SELECT location, SUM(CONVERT(int, new_deaths)) as total_death_count
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Thailand'
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count desc


-- 3. Creating the table of population infected percentage by country.

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)* 100 as population_infected_percentage
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Thialand'
GROUP BY location, population
ORDER BY population_infected_percentage desc


-- 4. Creating the table of population infected percentage by country but it include extra one column date.

SELECT location, population, date, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)* 100 as population_infected_percentage
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Thialand'
GROUP BY location, population, date
ORDER BY population_infected_percentage desc





--SELECT * FROM PortfolioProject..CovidDeaths

--SELECT * FROM PortfolioProject..CovidVaccinations

-- Percentage of people who got infected by Covid based on different country

SELECT location, date, new_cases, total_cases, population, (total_cases/population)*100 as Percent_of_people_infected_by_covid
	FROM PortfolioProject..CovidDeaths 
	ORDER by 1,2,3 

-- Percentage of people who died after getting infected by Covid

SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Percent_of_people_infected_by_covid
	FROM PortfolioProject..CovidDeaths 
	ORDER by 1,2,3 

-- Country with highest infection rate compared to their population

SELECT location, population, MAX(total_cases) AS Highest_number_of_cases, MAX((total_cases/population))*100 as Percent_of_population_infected
	FROM PortfolioProject..CovidDeaths 
	WHERE continent is not null
	GROUP BY location, population
	ORDER BY Percent_of_population_infected desc

-- Country with highest death rate compared to their population

SELECT location, MAX(cast(total_deaths as int)) AS Highest_number_of_deaths, MAX((cast(total_deaths as float) /population))*100 as Percent_of_population_died
	FROM PortfolioProject..CovidDeaths 
	WHERE continent is not null
	GROUP BY location
	ORDER BY Highest_number_of_deaths desc

--Chances of survival if you were infected by covid

SELECT location, date, (total_deaths/total_cases)*100 AS Percent_of_survival
	FROM PortfolioProject..CovidDeaths 
	WHERE continent is not null and location = 'India'
	ORDER BY Percent_of_survival desc

--  Total number of deaths and cases in the entire world 

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null


--Number of people who has recieved atleast one shot of vaccine

SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date  ) as sum_vaccinated
FROM PortfolioProject..CovidDeaths as dea 
	JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location and
	dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 1

--Using CTE 

WITH vac (location, date, population, new_vaccinations, sum_vaccinated)
as
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date  ) as sum_vaccinated
FROM PortfolioProject..CovidDeaths as dea 
	JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location and
	dea.date = vac.date
	WHERE dea.continent is not null
)
SELECT *, (sum_vaccinated/population)*100 FROM vac

-- Using temp tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE table #PercentPopulationVaccinated
(
location varchar(255),
Date datetime,
population numeric,
new_vaccinations NUMERIC,
sum_vaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date  ) as sum_vaccinated
FROM PortfolioProject..CovidDeaths as dea 
	JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location and
	dea.date = vac.date
	WHERE dea.continent is not null

SELECT *, (sum_vaccinated/population)*100 FROM #PercentPopulationVaccinated

--

SELECT dea.location, dea.population,
SUM(cast(vac.new_vaccinations as int)) as sum_vaccinated
FROM PortfolioProject..CovidDeaths as dea 
	JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location and
	dea.date = vac.date
	WHERE dea.continent is not null and dea.location is not null 
	GROUP BY dea.location, dea.population
	ORDER BY 3 desc

WITH popvsvac (location, population, sum_vaccinated)
as
(
SELECT dea.location, dea.population,
SUM(cast(vac.new_vaccinations as int)) as sum_vaccinated
FROM PortfolioProject..CovidDeaths as dea 
	JOIN PortfolioProject..CovidVaccinations as vac 
	ON dea.location = vac.location and
	dea.date = vac.date
	WHERE dea.continent is not null
	GROUP BY dea.location, dea.population
)
SELECT *, (sum_vaccinated/population)*100 as percent_vacination FROM popvsvac
WHERE sum_vaccinated is not null
ORDER BY percent_vacination desc



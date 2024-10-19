SELECT *
FROM portfolioProject.dbo.covidDeaths$
ORDER BY 3,4;

--SELECT *
--FROM portfolioProject.dbo.vaccinationInformation$
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject.dbo.covidDeaths$
ORDER BY 1,2;

--looking at total cases and total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM portfolioProject.dbo.covidDeaths$
WHERE location LIKE '%phil%' 
ORDER BY 1,2;

--looking at total cases and population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS casePercentageBasedOnPopulation
FROM portfolioProject.dbo.covidDeaths$
--WHERE location LIKE '%phil%' 
ORDER BY 1,2;

--looking at Countries with highest cases
SELECT location, population, MAX(total_cases) AS highestCasesCount, MAX((total_cases/population))*100 AS percentPopulationInfected
FROM portfolioProject.dbo.covidDeaths$
--WHERE location LIKE '%phil%' 
GROUP BY location, population
ORDER BY 4 DESC;

--showing Countries with highest death counts per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject.dbo.covidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%phil%' 
GROUP BY location
ORDER BY totalDeathCount DESC;

SELECT *
FROM portfolioProject.dbo.covidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--showing continents with highest death counts per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS totalDeathCount
FROM portfolioProject.dbo.covidDeaths$
WHERE continent IS NOT NULL
--WHERE location LIKE '%phil%' 
GROUP BY continent
ORDER BY totalDeathCount DESC;


-- global numbers
SELECT date, SUM(new_cases) AS totalNewCases, SUM(CAST(new_deaths AS INT)) AS totalNewDeaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS deathPercentage
FROM portfolioProject.dbo.covidDeaths$
--WHERE location LIKE '%phil%' 
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2;

-- looking at total population and vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM portfolioProject..covidDeaths$ dea
JOIN portfolioProject..vaccinationInformation$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- CTE
WITH populationVaccination (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM portfolioProject..covidDeaths$ dea
JOIN portfolioProject..vaccinationInformation$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rollingPeopleVaccinated/population)*100 AS vaccinatedPercentage
FROM populationVaccination
ORDER BY 2,3


-- TEMP TABLE
DROP TABLE IF EXISTS #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM portfolioProject..covidDeaths$ dea
JOIN portfolioProject..vaccinationInformation$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *, (rollingPeopleVaccinated/population)*100 AS vaccinatedPercentage
FROM #percentPopulationVaccinated


-- creating view to store data for later visualizations
CREATE VIEW percentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM portfolioProject..covidDeaths$ dea
JOIN portfolioProject..vaccinationInformation$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM percentPopulationVaccinated; 
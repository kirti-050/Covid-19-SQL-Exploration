SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Selecting Data That We Will Be Using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking At Total Cases vs Total Deaths
--Shows The Likelihood Of Dying If you Contract Covid In Your Country

SELECT location, date, total_cases, total_deaths, 
CAST (total_deaths AS FLOAT)/ NULLIF(CAST(total_cases AS FLOAT), 0) * 100 AS death_rate
FROM CovidDeaths
WHERE location LIKE '%India%'
AND continent IS NOT NULL
ORDER BY death_rate DESC

--Looking At The Total Cases vs The Population
--Shows What Percentage Of Population Got Covid

SELECT location, date, population, total_cases,
CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0) * 100 AS Infected_Rate
FROM CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY Infected_Rate DESC

--Looking At Countries With Highest Infection Rate Compared To Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
MAX(Cast(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS HighestInfectionRate
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

--Showing The Countries With The HIghest Death Count Per Population

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--To Break Things Down By Continent
--Showing Continent With The Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND continent <> ' '
GROUP BY continent
ORDER BY TotalDeathCount DESC 



--GLOBAL NUMBERS

SELECT date, SUM(NULLIF(CAST(new_cases AS FLOAT), 0)) AS Total_Cases, SUM(NULLIF(CAST(new_deaths AS FLOAT), 0)) AS Total_deaths,
SUM(NULLIF(CAST(new_deaths AS FLOAT), 0)) / SUM(NULLIF(CAST(new_cases AS FLOAT), 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ' '
GROUP BY date
ORDER BY 1, 2 DESC

--To See Total Deaths Across The World

SELECT SUM(NULLIF(CAST(new_cases AS FLOAT), 0)) AS Total_Cases, SUM(NULLIF(CAST(new_deaths AS FLOAT), 0)) AS Total_deaths,
SUM(NULLIF(CAST(new_deaths AS FLOAT), 0)) / SUM(NULLIF(CAST(new_cases AS FLOAT), 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ' '
ORDER BY 1, 2

--Looking At Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(NULLIF(CAST(Vac.new_vaccinations AS FLOAT), 0)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
AND Dea.continent <> ' ' 
ORDER BY 2, 3

--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(NULLIF(CAST(Vac.new_vaccinations AS FLOAT), 0)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
AND Dea.continent <> ' ' 
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PopulationPercentageVaccinated
FROM PopVsVac

--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date date, 
Population numeric(18, 0), 
New_Vaccinations numeric(18, 0), 
RollingPeopleVaccinated numeric(18, 0))

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, 
TRY_CAST(Dea.date AS date), 
TRY_CAST(Dea.population AS numeric(18, 0)), 
TRY_CAST(Vac.new_vaccinations AS numeric(18, 0)),
SUM(TRY_CAST(Vac.new_vaccinations AS numeric(18, 0))) 
OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date

SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PopulationPercentageVaccinated
FROM #PercentPopulationVaccinated

--Creating View To Store Data For Later Visualization

CREATE VIEW PercentpopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(NULLIF(CAST(Vac.new_vaccinations AS FLOAT), 0)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN CovidVaccinations Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
AND Dea.continent <> ' ' 

SELECT * FROM PercentpopulationVaccinated
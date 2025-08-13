SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order BY 1,2

--Select DATA that we are going to be using

SELECT 
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location = 'Philippines'
Order BY 1,2
	

--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT 
	Location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as PopulatedCases
FROM CovidDeaths
Where location = 'Philippines'
Order BY 1,2


--Looking at Countries with HIGHEST Infection Rate compared to Population

SELECT 
	Location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM CovidDeaths
Group BY Location, population
Order BY PercentofPopulationInfected DESC


--Global Numbers

SELECT 
	date,
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
Group BY date
Order BY 1,2


--USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinatedPeoplePerDay)
AS (
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(Convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS VaccinatedPeoplePerDay
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (VaccinatedPeoplePerDay/Population)*100 AS VaccinatedPopulation
FROM PopvsVac



--Temp table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinatedPeoplePerDay numeric
)

Insert Into #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(Convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS VaccinatedPeoplePerDay
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (VaccinatedPeoplePerDay/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(Convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS VaccinatedPeoplePerDay
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


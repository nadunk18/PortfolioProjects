SELECT * 
FROM PORTFOLIO..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PORTFOLIO..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIO..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases Vs Total Deaths
--possibility of dying after contacting covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
WHERE location like 'Sri%'
ORDER BY 1,2

--Looking at Total Cases Vs Population
--Percentage of population got positive
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PORTFOLIO..CovidDeaths
WHERE location like 'Sri%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) as ToatlInfectionCount, MAX(total_cases/population)*100 as PercentageofPopulationInfected
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
--WHERE location like 'Sri%'
GROUP BY location, population
ORDER BY PercentageofPopulationInfected DESC

--Looking countries with highest death count per population

SELECT location, population,MAX(CAST(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as PercentageofPopulationDied
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
--WHERE total_deaths>5000 AND location like 'Sri%'
GROUP BY location , population
ORDER BY PercentageofPopulationDied DESC

--Details by Continents



--Showing continensts with highest death count

SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
--WHERE total_deaths>5000 AND location like 'Sri%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int))as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--( total_deaths/total_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
Group by date
ORDER BY 1,2

--Looking at Total population vs total vacinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT * , (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM PopvsVac




--Temp table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated


--Creating view to store data for visualization

CREATE VIEW PercentPopulationVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated2

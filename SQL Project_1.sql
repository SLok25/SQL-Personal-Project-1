SELECT *
FROM Project..CovidDeaths
ORDER BY 3,4

SELECT *
FROM Project..CovidVaccinations
ORDER BY 3,4

SELECT Data that we are going to be using 

SELECT Location, date, total_cases, total_deaths, population 
FROM Project..CovidDeaths
ORDER BY 1,2 

-- Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM Project..CovidDeaths$
WHERE location LIKE '%states%'
ORDER by 1,2 

-- Countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM Project..CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with highest death count per population 

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount desc 

-- Global Numbers 

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM Project..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
 

-- Total Population vs Vaccinations

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM Project..CovidDeaths$ dea
JOIN Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  is not null
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


-- Creating view to store data for later visualization 

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM Project..CovidDeaths$ dea
JOIN Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent  is not null
--ORDER BY 2,3 
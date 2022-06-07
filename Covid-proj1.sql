SELECT * 
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
ORDER BY 3, 4


-- Select Data that we are going to be using

SELECT continent, date, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2

-- Looking at Total Cases Vs Total Deaths
-- Showing contracted covid in my Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_Pct
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%Portugal%'
ORDER BY 1, 2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Pct_pop_Infected
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%Portugal%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infections Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS Pct_pop_Infected 
FROM PortfolioProject1..CovidDeaths$
where continent is not null
GROUP BY location, population
ORDER BY Pct_pop_Infected DESC

-- SHowing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- SHOWING CONTINENT WITH THE HIGHEST DEAT COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as Total_Newcases, 
		SUM(CAST(new_deaths as int)) AS Total_NewDeaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2


SELECT  date,
		SUM(new_cases) as Total_Newcases, 
		SUM(CAST(new_deaths as int)) AS Total_NewDeaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE continent is not null
GROUP BY  date
ORDER BY 1, 2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidDeaths$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS OVER THE TIME

SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
		(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidDeaths$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE
with PopVsVac (continent, location, date, population, new_vaccionations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidDeaths$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- CREATING VIEW TO STORE DATA FOR LATER VISULALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidDeaths$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated
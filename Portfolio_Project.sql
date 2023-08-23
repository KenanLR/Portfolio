SELECT 
    *
FROM
    coviddeaths
WHERE continent IS NOT NULL
order by 3,4;

/*
SELECT 
    *
FROM
    covidvaccinations;*/

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    portfolioproject.coviddeaths
WHERE
	continent is not null
ORDER BY 1 , 2;

# Looking at Total Cases vs Total Deaths
#Shows likelihood of dying if you contract covid in Canada

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as DeathPercentage
FROM
    portfolioproject.coviddeaths
WHERE
	location like '%Canada%'
ORDER BY 1 , 2;

#Looking at Total Cases vs Population
#Shows what percentage of population got Covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 as PercentPopulationInfected
FROM
    portfolioproject.coviddeaths
WHERE
	location like '%Canada%'
ORDER BY 1 , 2;

# Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    portfolioproject.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;

#Showing Countries with Highest Death Count per Population

SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED INT)) AS TotalDeathCount
FROM
    portfolioproject.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

ALTER TABLE coviddeaths
MODIFY continent varchar(255) NULL;

commit;

UPDATE
	coviddeaths
SET
	continent = CASE continent WHEN '' THEN NULL ELSE continent END;
    
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED INT)) AS TotalDeathCount
FROM
    portfolioproject.coviddeaths
WHERE
    continent IS NULL
    and location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC;

# Taking a look at the data by continent

# Showing continents with the highest death count per population

SELECT 
    continent,
    MAX(CAST(total_deaths AS SIGNED INT)) AS TotalDeathCount
FROM
    portfolioproject.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


# Global Numbers

SELECT 
    date,
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as SIGNED INT)) as total_deaths,
    SUM(CAST(new_deaths as SIGNED INT))/SUM(new_cases)* 100 as DeathPercentage
FROM
    portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL
Group BY date
ORDER BY 1 , 2;

SELECT 
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as SIGNED INT)) as total_deaths,
    SUM(CAST(new_deaths as SIGNED INT))/SUM(new_cases)* 100 as DeathPercentage
FROM
    portfolioproject.coviddeaths
WHERE
	continent IS NOT NULL
ORDER BY 1 , 2;

# Looking at Total Population vs Vaccinations

SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS SIGNED INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated,
    (Rolling_People_Vaccinated/population)*100
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

# USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS SIGNED INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated/*,
    (Rolling_People_Vaccinated/population)*100 */
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
#ORDER BY 2,3;
)
Select *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac;

# TEMP TABLE

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date text,
Population int,
New_vaccinations text,
Rolling_People_Vaccinated int
);

INSERT IGNORE INTO  PercentPopulationVaccinated
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS SIGNED INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated/*,
    (Rolling_People_Vaccinated/population)*100 */
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.date = cv.date
#WHERE cd.continent IS NOT NULL
#ORDER BY 2,3
;

Select *, (Rolling_People_Vaccinated/Population)*100
FROM PercentPopulationVaccinated ;

#Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS SIGNED INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as Rolling_People_Vaccinated/*,
    (Rolling_People_Vaccinated/population)*100 */
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
#ORDER BY 2,3
;

SELECT 
    *
FROM
    PercentPopulationVaccinated
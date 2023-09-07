/* 

SQL Queries used for Tableau Project 

*/

-- 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed int)) as total_deaths, SUM(cast(new_deaths as signed int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%Canada%'
where continent is not null 
-- Group By date
order by 1,2;

-- 2
Select location, SUM(cast(new_deaths as signed int)) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%Canada%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income'
Group by location
order by TotalDeathCount desc;

-- 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%Canada%'
WHERE location not like '%income'
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- Where location like '%Canada%'
WHERE location not like '%income'
Group by Location, Population, date
order by PercentPopulationInfected desc;

/* Queries used for data visualization in Tableau public and store in excel sheet*/

--1 total case, deaths and %
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDataAnalysis..covidDeaths
where continent is not null 
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDataAnalysis..covidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income','Low income', 'Oceania')
Group by location
order by TotalDeathCount desc


-- 3.

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDataAnalysis..covidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- 4.

Select location, population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDataAnalysis..covidDeaths
Group by location, population, date
order by PercentPopulationInfected desc


/*visualization link : https://public.tableau.com/views/Coviddashboard_16949979330090/CovidDashboard?:language=en-US&:display_count=n&:origin=viz_share_link*/

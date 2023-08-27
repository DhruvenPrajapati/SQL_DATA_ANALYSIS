/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
--check the data in table

Select
	*
From 
	CovidDataAnalysis..covidDeaths
Where
	continent is not null

Select 
	*
From 
	CovidDataAnalysis..covidVaccinations


-- Select Data that we are going to be work 
Select
	location, date, total_cases, new_cases, total_deaths, population
From
	CovidDataAnalysis..covidDeaths
Where
	continent is not null
order by
	1,2



-- Total Cases vs Total Deaths for canada(there is issue with total_deaths datatype so cast it as int)
Select
	location, date, total_cases,total_deaths,
	(cast(total_deaths as int)/total_cases)*100 as DeathPercentage
From
	CovidDataAnalysis..covidDeaths
Where
	location like '%Canada%' and
	continent is not null
order by 1,2
/*Result of this shows likelihood of dying*/


-- Total Cases vs population for canada
Select
	location, date, total_cases,population,
	(total_cases/population)*100 as PercentPopulationInfected
From
	CovidDataAnalysis..covidDeaths
Where
	location like '%Canada%' and
	continent is not null
order by 1,2
/*Result of this shows what percentage of population infected with Covid*/



-- Countries with Highest Infection Rate compared to Population

Select
	location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From
	CovidDataAnalysis..covidDeaths
Where
	continent is not null
Group by
	location, population
order by
	PercentPopulationInfected desc



-- Countries with Highest Death Count per Population
Select
	location, MAX(cast(total_deaths as int)) as TotalDeathCount
From
	CovidDataAnalysis..covidDeaths
Where
	continent is not null
Group by
	Location
order by
	TotalDeathCount desc

/* result shows the location have some value that should not be there like world, South America
	etc. these are entire Continent group of location
	
	After checking table continent is null when location is world, asia, south america etc.
	so we need to add where condition with continent and add into every script. */




-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select
	location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From
	CovidDataAnalysis..covidDeaths
Where
	continent is null 
Group by
	location
order by
	TotalDeathCount desc


-- GLOBAL NUMBERS of covid case, deths and %

Select
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From
	CovidDataAnalysis..covidDeaths
where
	continent is not null 
order by
	1,2

	/* we can add date and groupby to check date wise value*/


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine and count sum after each new_vaccinations

Select
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From
	CovidDataAnalysis..covidDeaths cd
Join
	CovidDataAnalysis..covidVaccinations cv
		On cd.location = cv.location
		and cd.date = cv.date
where
	cd.continent is not null 
order by
	2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From
	CovidDataAnalysis..covidDeaths cd
Join
	CovidDataAnalysis..covidVaccinations cv
		On cd.location = cv.location
		and cd.date = cv.date
where
	cd.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as populationvaccinated
From PopvsVac

/* we can find max people vaccinated by removing date as well*/




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From
	CovidDataAnalysis..covidDeaths cd
Join
	CovidDataAnalysis..covidVaccinations cv
		On cd.location = cv.location
		and cd.date = cv.date
where
	cd.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as populationvaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From
	CovidDataAnalysis..covidDeaths cd
Join
	CovidDataAnalysis..covidVaccinations cv
		On cd.location = cv.location
		and cd.date = cv.date
where
	cd.continent is not null 
Select*
From [PortfolioProject]..[CovidDeaths]
where continent is not null
Order by 3,4

--Select*
--From [PortfolioProject]..[CovidVaccinations]
--Order by 3,4

--The Data i will be using
Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject]..[CovidDeaths]
where continent is not null
order by 1,2

--Looking at the Total_cases vs Total_Death
--Here is the Likelyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_Cases)*100 as DeathPercentage
From [PortfolioProject]..[CovidDeaths]
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of the population has got covid
Select Location, date, population, total_cases, (Total_cases/Population)*100 As InfectedPercentage
From [PortfolioProject]..[CovidDeaths]
where continent is not null
--where Location like ('%States%')
order by 1,2

--Looking at countries with the highest infection rate compare to the population

Select Location, population, MAX(total_cases) as HighestInfectedCount,  MAX((Total_deaths/Total_Cases))*100 as HighestPopulationInfected
From [PortfolioProject]..[CovidDeaths]
where continent is not null
--where Location like 'United States'
Group by Location, Population
order by HighestPopulationInfected Desc

--Showing Countries with the highest Death count by Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount 
From [PortfolioProject]..[CovidDeaths]
where continent is not null
--where Location like 'United States'
Group by Location
order by  TotalDeathCount desc

--Let's Break Things Down By Continent
--Showing Continent with the highest Death count by Population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount 
From [PortfolioProject]..[CovidDeaths]
where continent is not null
--where Location like 'United States'
Group by continent
order by  TotalDeathCount desc

--Global Nummbers by date
Select date, sum(new_cases) as TotalSumOfNewCases, sum(cast(new_deaths as int)) as TotalSumOfNewDeaths, sum(new_cases)/sum(cast(new_deaths as int))*100  as DeathPercentage
From [PortfolioProject]..[CovidDeaths]
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Global Numbers Overall
Select sum(new_cases) as TotalSumOfNewCases, sum(cast(new_deaths as int)) as TotalSumOfNewDeaths, sum(new_cases)/sum(cast(new_deaths as int))*100  as DeathPercentage
From [PortfolioProject]..[CovidDeaths]
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Join death with Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 2,3

-- population vs Vaccination. This is to know the percentage of people that are vaccinated in each of the country.
--use CTE. Because we can not use the alias 'RollingPeopleVaccinated' in the same eyntax

with PopvsVac (continent, location, date, population, new_vaccinated, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
--Now we can do use RollingPeopleVaccination with the CTE
select*, (RollingPeopleVaccinated/population)*100 as Percentage_Of_TotalVaccinated
from popvsvac

--Representing the data on Temp Table will have the same effect as the CTE. But, i did it anyway

--TEMP TABLE
Drop table if exists #PercentageOfTotalVaccinated
create Table #PercentageOfTotalVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric)

insert into #PercentageOfTotalVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100 as Percentage_Of_TotalVaccinated
from #PercentageOfTotalVaccinated

--creating view to store data for later visualization
create view PercentageOfTotalVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentageOfTotalVaccinated

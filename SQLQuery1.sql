



Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at toal cases vs total deaths

Select location, date, total_cases, total_deaths, population, (Convert(float,total_deaths)/Convert(float,total_cases))* 100 as DeathPercentage
from CovidDeaths
order by 1,2


-- looking at the total cases vs the population
Select location, date, population, total_cases,  (total_cases/population)* 100 as InfectedPercentage
from CovidDeaths
order by 1,2

-- Looking at countries with the highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfected,  Max(total_cases/population)* 100 as InfectedPercentage
from CovidDeaths
group by location, population
order by 4 desc

-- Looking at countries with the highest Deaths
Select location,  Max(cast(total_deaths as int)) as Highestdeaths
from CovidDeaths
where continent is not null 
group by location
order by Highestdeaths desc


--Lets break things by Continent

--Looking at Continents with the highest Deaths
Select continent,  Max(cast(total_deaths as int)) as Highestdeaths
from CovidDeaths
where continent is not null 
group by continent
order by Highestdeaths desc

--Global Numbers
SELECT 
    SUM(new_cases) AS TotalNewCases, 
    SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS float)) / SUM(new_cases)) * 100 
    END AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL

ORDER BY 
   TotalNewCases;


-- Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as total_Vaccination
from CovidDeaths dea join CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3



-- to know the vaccinated population percentage( using temp table)
drop table if exists #popvac
create table #popvac (
continent nvarchar(100),
location nvarchar(100),
date datetime,
population numeric,
new_vaccination numeric,
total_Vaccination numeric)

Insert into #popvac
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as total_Vaccination
from CovidDeaths dea join CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

select * , (total_Vaccination/population)*100 totalpeoplevaccinated
from #popvac


-- creating view to store data for viz later

create view popvac as 
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as total_Vaccination
from CovidDeaths dea join CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
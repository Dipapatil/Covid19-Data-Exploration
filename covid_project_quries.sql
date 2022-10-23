/* Covid19 Project Queries */

select * from Covid19_project..covid_death
order by 3,4;

select top 10 * from covid_vaccination
order by 3,4

select location, covid_date, convert(date,covid_date), total_cases, new_cases, total_deaths, population
	from Covid19_project..covid_death
	where continent is not null
	order by 1,2

update covid_death
set covid_date = convert(date,covid_date);

--total cases vs total death
--shows the percentage of dying if you contract covid in your country

select location,convert(date,covid_date), total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_death
where location like '%States%'
and continent is not null
order by 1,2;


--total cases vs population 
--percentage of population got covid

select location , convert(date,covid_date), population, total_cases, round((total_cases/population)*100,2) as PercentOfPopulationInfected
from covid_death
where continent is not null
order by 1,2;

-- countries with highest infection rate compared to population
--3rd tableau query 

select location, population, max(total_cases) as HighestInfectionCount, 
	round(max((total_cases/population))*100,2) as PercentPopulationInfected
	from covid_death
	where continent is not null
	group by location,population
	order by PercentPopulationInfected 

-- contries with infection count according to date
--4th tableau query

	select location, population, convert(date,covid_date) as Date, max(total_cases) as HighestInfectionCount, 
	round(max((total_cases/population))*100,2) as PercentPopulationInfected
	from covid_death
	where continent is not null
	group by location,population,covid_date
	order by PercentPopulationInfected desc

--contries with highest death count per population

select location,
	max(cast(total_deaths as int)) as TotalDeathCount
	from covid_death
	where continent is not null
	group by location
	order by TotalDeathCount DESC
 
 --death count by continent

select
	continent,
	max(cast(total_deaths as int)) as TotalDeathCount
	from covid_death
	where continent is not null
	group by continent
	order by TotalDeathCount desc;


--global numbers of total cases and total death according to date

select 
	convert(date,covid_date) as Date,
	sum(new_cases) as TotalCases,
	sum(cast(new_deaths as int)) as TotalDeaths, 
	round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as DeathPercentage
	from covid_death
	where continent is not null
	group by covid_date
	order by 1

--total number of cases and deaths in world  
-- 1st tableau query

select 
	sum(new_cases) as TotalCases, 
	sum(cast(new_deaths as int)) as TotaDeaths,
	round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as DeathPercentage
from covid_death

-- European Union is part of Europe Total death count by continent

/*Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_death
Where continent is null 
and location not in('World','High income', 'Upper middle income','European Union','Low income','Lower middle income','International')
Group by location
order by TotalDeathCount desc*/

--2nd tableau query for total death count by continent

select continent, 
	sum(cast(new_deaths as int)) as TotalDeathCount
	from covid_death
	where continent is not null
group by continent
order by TotalDeathCount desc


-- Total population vs Vaccinations

--use CTE
-- 5th Tableau query

with PopvsVac (Continent, location, population, new_vaccinations, Rollingpeoplevaccinated)
as 
(
	select
	d.continent, 
	d.location, 
	d.population, 
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.covid_date) as Rollingpeoplevaccinated
	from Covid19_project..covid_death d
	join Covid19_project..covid_vaccination v
	on d.location = v.location and
	d.covid_date = v.covid_date
	where d.continent is not null
)
select *, round((Rollingpeoplevaccinated/population)*100,2) as PercentOfVaccination
from PopvsVac


--temp table  same Output as CTE just different method
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	population float,
	new_vaccinations bigint,
	Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
	select
	d.continent, 
	d.location, 
	d.population, 
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.covid_date) as Rollingpeoplevaccinated
	from Covid19_project..covid_death d
	join Covid19_project..covid_vaccination v
	on d.location = v.location and
    d.covid_date = v.covid_date
	where d.continent is not null

select *, round((Rollingpeoplevaccinated/population)*100,2) as PercentOfVaccination
from #PercentPopulationVaccinated


-- creating view to store data for later data visualization same as above output diffrent method

create view PercentPopulationVaccinated as
	select
	d.continent, 
	d.location, 
	d.population, 
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.covid_date) as Rollingpeoplevaccinated
	from Covid19_project..covid_death d
	join Covid19_project..covid_vaccination v
	on d.location = v.location and
   d.covid_date = v.covid_date
	where d.continent is not null

--using view to get data

select * from PercentPopulationVaccinated


-- new_deaths vs. new vaccinations according to date and location

select d.location,convert(date,d.covid_date) as Date,
	avg(d.total_cases) as TotalCases,
	avg(cast(v.new_vaccinations as float)) as NewVaccinations,
	avg(cast(d.new_deaths as float)) as NewDeaths
	from covid_death d
	join covid_vaccination v
	on d.location = v.location
	and d.covid_date = v.covid_date
	where d.continent is not null
	group by d.location,d.covid_date, d.total_cases
	order by d.location, d.covid_date,d.total_cases desc;

-- new deaths vs new vaccinations

select 
	avg(d.total_cases) as TotalCases,
	avg(cast(v.new_vaccinations as float)) as NewVaccinations,
	avg(cast(d.new_deaths as float)) as NewDeaths
	from covid_death d
	join covid_vaccination v
	on d.location = v.location
	and d.covid_date = v.covid_date
	where d.continent is not null
	group by d.total_cases
	order by d.total_cases desc;



select * from project..['covid_deaths'] where continent is not null 
order by 3 ,4 ;

select location, date, total_cases, new_cases, total_deaths, population from project..['covid_deaths']
where continent is not null
order by 1,2;

-- percent of deaths per covid case

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as death_percent from project..['covid_deaths']
where location like'India' and continent is not null
order by 1,2;

-- percent of covid cases

select location, date, total_cases,  population, (total_cases/population)*100 as covid_percent from project..['covid_deaths']
where location like'India' and continent is not null
order by 1,2;

--highest covid cases

select location, population, MAX(total_cases) as highest_infection_rate, MAX((total_cases/population)*100) as covid_percent from project..['covid_deaths']
--where location like'India'
where continent is not null
Group by location, population
order by covid_percent desc;

-- highest death rates location wise

select location, MAX(cast (total_deaths as int)) as highest_death_rate from project..['covid_deaths']
where continent is not null
--location like'India'
Group by location
order by highest_death_rate desc;

-- highest death count continent wise

select location, MAX(cast (total_deaths as int)) as highest_death_rate from project..['covid_deaths']
where continent is null
--location like'India'
Group by location
order by highest_death_rate desc;


select continent, MAX(cast (total_deaths as int)) as highest_death_rate from project..['covid_deaths']
where continent is not null
--location like'India'
Group by continent
order by highest_death_rate desc;


-- global numbers


select  SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent from project..['covid_deaths']
where 
--location like'India' and 
continent is not null
--group by date
order by 1,2;


select * from project..['covid_vaccinations'] where continent is not null 
order by 3 ,4 ;


-- total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by 
dea.location, dea.date) as rolling_people_vaccinated,

from project..['covid_deaths'] dea
join project..['covid_vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

 order by 2,3 ;



 -- use cte

 with popvcvac(continent,location, date, population, new_vaccinations, rolling_people_vaccinated)
 as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by 
dea.location, dea.date) as rolling_people_vaccinated

from project..['covid_deaths'] dea
join project..['covid_vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

 --order by 2,3 
 )
 select *, (rolling_people_vaccinated/population)*100 as rpv 
 from popvcvac




 -- temp table



 drop table if exists PRV
create table PRV
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rpv numeric
)


insert into PRV
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by 
dea.location, dea.date) as rolling_people_vaccinated

from project..['covid_deaths'] dea
join project..['covid_vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

 --order by 2,3 

 select *, (rpv/population)*100 --as rpvp 
 from PRV


 --create view to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by 
dea.location, dea.date) as rolling_people_vaccinated

from project..['covid_deaths'] dea
join project..['covid_vaccinations'] vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

 --order by 2,3 
 drop view PercentPopulationVaccinated;
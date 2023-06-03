select * from coviddeaths order by 3,4

--- columns we need 
select location, date, total_cases,new_cases, total_deaths, population from dbo.coviddeaths order by location, date 


---- chances of dying if you got covid in india 
select location, date, total_cases, total_deaths,round((total_deaths/total_cases*100),3) as 'percentage of deaths', population
from dbo.coviddeaths  where location  like 'india%'
order by location, date

--- percentage of population that is getting infected
select location, date, total_cases ,population , round(total_cases/population*100,3) as 'infected percentage' 
from coviddeaths where location ='india' order by 1,2


-----country with highest infection rate
select top 5 location,population  , max(total_cases) as 'highest no. of cases',
max(round(total_cases/population*100,3)) as 'infected percentage' 
from coviddeaths  where total_cases/population*100 is not null 
Group by  location,population order by [infected percentage] desc


-----country with highest death counts
select location, max(cast(total_deaths as int)) as 'total death counts',
round(max((total_deaths/population)*100),3) as 'percentage of population died '
from coviddeaths where continent is not null group by location 
order by  [total death counts] desc

----continent wise death rate 
select continent, max(cast(total_deaths as int)) as 'total death counts' ,
round(max((total_deaths/population)*100),3) as 'percentage of population died'
from CovidDeaths where continent is not null group by continent
order by [total death counts] desc 

---date wise daily new cases
select date, sum(new_cases) as 'Daily new cases' from coviddeaths 
where new_cases is not null group by date order by date


-----Daily new deaths
select date, sum(cast(new_deaths as int )) as 'Daily new deaths' from  coviddeaths 
where new_cases is not null group by date order by date

---total cases and deaths
select sum(new_cases) AS 'TOTAL CASES', sum(cast(new_deaths as int)) AS 'total deaths',
round(sum(cast(new_deaths as int))/sum(new_cases) *100,3) as ' chances of dying %'
from CovidDeaths where continent IS NOT NULL 

-----how many people got vaccinated till now in every country
select a.location, max(b.population) Total_population, sum(cast(a.new_vaccinations as int)) as total_vaccinations,
round(sum(cast(a.new_vaccinations as int))/max(b.population)*100,3) as 'vacciation %'
from CovidVaccinations a
join CovidDeaths b 
on a.date=b.date
and a.location=b.location 
where a.continent is not null
group by a.location
order by a.location;

--- how many people are getting vaccinated daily
with  popvsroll 
(continent, location, date, population, new_vaccinations, rolling_new_vaccations) as
(select a.continent,b.location, b.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as bigint)) over( partition by a.location order by a.location, b.date ) 
as 'rolling_new_vaccations' from CovidDeaths a 
join CovidVaccinations b 
on a.date=b.date
and a.location=b.location
where b.continent is not null)
select*, round(rolling_new_vaccations/population*100,5) as 'rolling_%_new_vacc'from popvsroll
order by 2,3


---creating temp table
drop table  if exists #temptable
create table #temptable ( continent nvarchar (255), location nvarchar(255), date datetime, population bigint,
new_vaccinations bigint, 
rolling_new_vacc bigint)

insert  into #temptable select a.continent, a.location, a.date, a.population,b.new_vaccinations,
sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date) as 'rolling_new_vacc'
from CovidDeaths a
join CovidVaccinations  b 
on a.date=b.date
and a.location=b.location 
where  a.continent is not null 


select* from #temptable order by 2,3



---creating view
create view abc  as 
select a.continent, a.location, a.date, a.population,b.new_vaccinations,
sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date) as 'rolling_new_vacc'
from CovidDeaths a
join CovidVaccinations  b 
on a.date=b.date
and a.location=b.location 
where  a.continent is not null 

select* from abc








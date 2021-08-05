-- Data Source: https://ourworldindata.org/covid-deaths



-- looking at the covid deaths dataset

select * 
from Covid_Dataset_Project..CovidDeaths


--select the data that we are going to use 

select location, date, total_cases, new_cases, total_deaths, population
from Covid_Dataset_Project..CovidDeaths
order by 1,2


--looking at total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Covid_Dataset_Project..CovidDeaths
order by 1,2

--select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
--from Covid_Dataset_Project..CovidDeaths
--where location='India'
--order by 1,2


--looking at total cases vs total population

select location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as cases_percent
from Covid_Dataset_Project..CovidDeaths
where location='India'
order by 1,2


--checking which countries have the highest infection rates

--select location, MAX(total_cases) as highest_infection_count, MAX(total_cases/population) as highest_infection_percentage
--from Covid_Dataset_Project..CovidDeaths
--group by location
--order by 2 desc


--(the above query also gives some continents in place of location, hence):

select location, MAX(total_cases) as highest_infection_count, MAX(total_cases/population) as highest_infection_percentage
from Covid_Dataset_Project..CovidDeaths
where continent is not null
group by location
order by 2 desc


--checking which countries have the highest deaths

--select location, MAX(total_deaths) as highest_death_count, MAX(total_deaths/population) as highest_death_percentage
--from Covid_Dataset_Project..CovidDeaths
--where continent is not null
--group by location
--order by 2 desc


--the results of the above query do not seem correct due to some error beacuse of the data type, hence: 

select location, MAX(cast(total_deaths as int)) as highest_death_count, MAX(cast(total_deaths as int)/population) as highest_death_percentage
from Covid_Dataset_Project..CovidDeaths
where continent is not null
group by location
order by 2 desc


-- looking at the covid vaccinations dataset

select * 
from Covid_Dataset_Project..CovidVaccinations


--looking at total population vs vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
from Covid_Dataset_Project..CovidDeaths deaths
join Covid_Dataset_Project..CovidVaccinations vax
on deaths.location= vax.location
and deaths.date= vax.date
where deaths.continent is not null
order by 2,3


--creating a total vaccinations column using the new vaccinations column

select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) 
as total_vaccinations_till_date

from Covid_Dataset_Project..CovidDeaths deaths
join Covid_Dataset_Project..CovidVaccinations vax
on deaths.location= vax.location
and deaths.date= vax.date
where deaths.continent is not null
order by 2,3


--creating a vaccination/population ratio column using the column created in the previous query

--using CTE (common table expression)

with pop_vs_vac (continent, location, date, population, new_vaccinations, total_vaccinations_till_date) 
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) 
as total_vaccinations_till_date

from Covid_Dataset_Project..CovidDeaths deaths
join Covid_Dataset_Project..CovidVaccinations vax
on deaths.location= vax.location
and deaths.date= vax.date
where deaths.continent is not null
--order by 2,3
)

select *, (total_vaccinations_till_date/population)*100
from pop_vs_vac
--as vaccinated_population_ratio 


--using temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_till_date numeric)

insert into #PercentPopulationVaccinated

select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) 
as total_vaccinations_till_date

from Covid_Dataset_Project..CovidDeaths deaths
join Covid_Dataset_Project..CovidVaccinations vax
on deaths.location= vax.location
and deaths.date= vax.date
where deaths.continent is not null
--order by 2,3

Select *, (total_vaccinations_till_date/Population)*100
From #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations

use Covid_Dataset_Project

Create View Percent_Population_Vaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(convert(int, vax.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) 
as total_vaccinations_till_date

from Covid_Dataset_Project..CovidDeaths deaths
join Covid_Dataset_Project..CovidVaccinations vax
on deaths.location= vax.location
and deaths.date= vax.date
where deaths.continent is not null
--order by 2,3

select * 
from Percent_Population_Vaccinated

----------------------------------------------------------

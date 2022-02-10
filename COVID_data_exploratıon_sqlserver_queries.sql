select * from PortfolioProject..CovidDeaths order by 3,4

select * from PortfolioProject..CovidVaccinations order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeaths order by 1,2

--TOTAL CASES VS POPULATION 
select location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 
as DeathPercentage from PortfolioProject..CovidDeaths where location like '%turkey%' order by 1,2

--PERCENTAGE OF POPULATION GOT COVID
select location,date,total_cases,population,(cast(total_deaths as float)/cast(population as float))*100 
as DeathPercentage from PortfolioProject..CovidDeaths where location like '%turkey%' order by 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION  
select location,population,max(total_cases) as HighestInfectionCount ,max(cast(total_cases as float)/cast(population as float))*100 
as PercentPopulationInfected from PortfolioProject..CovidDeaths group by location, population order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT POPULATION
select location,population,max(total_cases) as HighestInfectionCount ,max(cast(total_cases as float)/cast(population as float))*100 
as PercentPopulationInfected from PortfolioProject..CovidDeaths group by location, population order by PercentPopulationInfected desc

select location,max(total_cases) as TotalDeathCount from PortfolioProject..CovidDeaths group by location order by TotalDeathCount desc

Select * from PortfolioProject..CovidDeaths where continent is not null 

select location,max(cast(total_deaths as decimal)) as TotalDeathCount from PortfolioProject..CovidDeaths where continent is null 
group by location order by TotalDeathCount desc

--GLOBAL NUMBERS
select sum(cast(new_cases as decimal)) as total_cases,sum(cast(new_deaths as decimal)) as total_daths, 
sum(cast(new_deaths as decimal))/sum(cast(new_cases as decimal))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null group by date order by 1,2

--PERCENTAGE OF POPULATION WITH AT LEAST ONE COVID VACCINE
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
order by 2,3

--USE CTE
with PopvsVac(Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null
)
select *  from PopvsVac


 --TEMP TABLE
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE VÝEW
go
Create View PercentPopulationVaccinated2
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 





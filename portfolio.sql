/*Skills used: Joins,group by, CTE's, Windows Functions, Aggregate Functions, Converting Data Types */


/* Data exploration */
 select * from coviddeaths order by location,date;
 
 /* Select the data that we are going to use */
 select location,date,total_cases,new_cases,total_deaths,population from coviddeaths order by location,date;
 
 /* Understand the total cases vs total deaths for all the locations*/
 select location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage from coviddeaths order by location,date;

  /* Understand the total cases vs total deaths in india*/
/*shows likelihood of dying if infected by covid in india*/
select location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as death_percentage from coviddeaths where upper(location)='INDIA' order by death_percentage DESC,location,date;
/*The cases and deaths were minimal during the onset of covid in 2020 but the death rate was at all time high during the months of April and may in the year 2020. The death rate declined significantly in the year 2021. */

/* shows percentage of people infected by covid in india*/
 select location,date,total_cases,population,((total_cases/population)*100) as percentage_infected from coviddeaths where upper(location)='INDIA' order by percentage_infected DESC,location,date;
/*The infected rate was minimal in the beginning of 2020 and reached its peak in the months of April and may in the year 2021*/

/*Highest infection rate compared to population for all the countries*/
 select location,MAX(total_cases) as highest_count,population,MAX(((total_cases/population)*100)) as percentage_population_infected from coviddeaths group by population,location order by percentage_population_infected DESC;
/* Andorra has the highest infection rate*/

/*Highest death rate compared to population for all the countries*/
select location,MAX(cast(total_deaths as signed)) as highest_deaths,population,MAX(((total_deaths/population)*100)) as percentage_population_deaths from coviddeaths where continent is not null group by population,location order by percentage_population_deaths DESC LIMIT 0, 1000;
/* USA has the highest death count . Hungary has the highest death rate  */


/*Global death percentage*/
select SUM(cast(new_deaths as signed)) as total_deaths,SUM(new_cases) as total_cases,(SUM(cast(new_deaths as signed))/SUM(new_cases))*100 AS DEATH_RATE FROM COVIDDEATHS  order by death_rate desc;

/* identify the total number of people and vaccinated population for all the countries*/
select a.location,a.date,a.population,b.new_vaccinations from coviddeaths a inner join covidvaccination b on a.location=b.location and a.date=b.date where a.continent is not null order by a.location,a.date;

/*rolling count of vaccinated population for each location */
select a.location,a.date,a.population,b.new_vaccinations,SUM(CAST(b.new_vaccinations as signed)) over(partition by a.location order by a.location,a.date) as rolling_vaccination_count from coviddeaths a inner join covidvaccination b on a.location=b.location and a.date=b.date where a.continent is not null order by a.location,a.date;

/*percentage of population vaccinated for each location*/
with CTE AS (select a.location,a.date,a.population,b.new_vaccinations,SUM(CAST(b.new_vaccinations as signed)) over(partition by a.location order by a.location,a.date) as rolling_vaccination_count from coviddeaths a inner join covidvaccination b on a.location=b.location and a.date=b.date where a.continent is not null order by a.location,a.date)
SELECT *,(MAX(rolling_vaccination_count)/population) as percent_vaccinated FROM CTE group by location order by percent_vaccinated desc;
/* Gibraltar has the highest vaccination rate due to their small population */

--Covid Data from Our World in Data, Statistics tll 10-Aug-2021
--query results visualised on tableau: https://public.tableau.com/app/profile/jun3019

-- aggregating total infection cases, mortality cases and mortality rates
select sum(new_cases) AS Total_Global_Cases, sum(CAST(new_deaths AS INT)) AS Total_Global_Deaths,
		sum(CAST(new_deaths AS INT))/sum(new_cases) * 100 AS Global_Mortality_Rate
FROM covid_death
where Continent is not null

--extracting highest Covid infection count and aggregating highest percentage population infected across Countries
select location,population, max(total_cases) AS HighestInfectionCount,
		max(total_cases)/population * 100 AS PercentagePopulationInfected
FROM covid_death 
where Continent is not null
Group by Location,population
Order By HighestInfectionCount Desc

--extracting highest Covid cases and death counts to aggregate death percentage across Countries
select location, max(total_cases) AS Total_cases, max(cast(total_deaths as INT)) AS DeathCount,
		max(CAST(total_deaths AS INT))/sum(new_cases) * 100 AS DeathPercentage
FROM covid_death 
where Continent is not null
Group by Location
Order By DeathCount Desc

--extracting the number of people who have at least 1 dose and completed 2 doses across all countries over the period of time when coountries start vaccination till 10 Aug 2021
Select cv.location, cv.date,cv.population,cv.people_fully_vaccinated,cv.people_vaccinated,
		(cast(cv.people_vaccinated AS BIGINT) - cast(cv.people_fully_vaccinated AS BIGINT)) as At_Least_One_Dose_Completed,
		cv.people_fully_vaccinated as Second_Dose_Completed,
		(cast(cv.people_vaccinated AS BIGINT) - cast(cv.people_fully_vaccinated AS BIGINT))/cv.population * 100 AS ShareofPeoplePARTLYVaccinatedAgainstCovid,
		cv.people_fully_vaccinated/cv.population * 100 AS ShareofPeopleFULLYVaccinatedAgainstCovid
FROM covid_vaccination cv 
where cv.continent is not null and (cv.people_fully_vaccinated is not NULL or cv.people_vaccinated is not NULL)
Order By cv.location, cv.date


--joining of tables between covid data and world bank income_group classification based on iso code of countries
Select cv.location, eg.income_group, cv.population, cv.gdp_per_capita,
		MAX( (cv.people_vaccinated/cv.population))*100 AS ShareofPeoplePartlyorFULLYVaccinatedAgainstCovid ,
		(MAX( (cv.people_vaccinated/cv.population))) * cv.population AS NumberofPeoplePartlyorFULLYVaccinatedAgainstCovid 
From Covid_vaccination cv
JOIN economies_grouping eg
	ON cv.iso_code = eg.code
where cv.Continent is not null
group by cv.location, cv.population, eg.income_group, cv.gdp_per_capita
Order by cv.location

--relationship between stringency index and spread of percentage population infected AND stringency index and death count over a period of time 
--nine response indicators including school closures, workplace closures, and travel bans, rescaled to a value from 0 to 100 (100= strictest)
select location,date, stringency_index, total_cases, total_deaths
From covid_death
where Continent is not null
order by location,date

-- Rolling 7-DAY average for deaths and infection count
select date, location,
		avg(CAST(total_cases as numeric)) OVER ( Order By Location, Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as Moving_Average_Infection_Count ,
		avg(CAST(total_deaths as numeric)) OVER ( Order By Location, Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as Moving_Average_Death_Count
from covid_vaccination
Order by Location,date


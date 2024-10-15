CREATE DATABASE Indian_Census;

-- number of rows into our datasets

SELECT 
    COUNT(*)
FROM
    dataset1;

SELECT 
    COUNT(*)
FROM
    dataset2;
    
-- dataset for jharkhand and bihar

SELECT 
    *
FROM
    dataset1
WHERE
    state IN ('Jharkhand' , 'Bihar');
    
-- population of India

SELECT 
    SUM(population) AS Total_Population
FROM
    dataset2;
    
-- Average growth of the India

SELECT 
    ROUND((AVG(growth) * 100), 2) Avg_growth
FROM
    dataset1;

-- Average growth by the state

SELECT 
    state, ROUND((AVG(growth) * 100), 2) Avg_growth
FROM
    dataset1
GROUP BY state
ORDER BY Avg_growth;

-- Average Sex_ratio per State

SELECT 
    state, ROUND((AVG(sex_ratio)), 2) Avg_sex_ratio
FROM
    dataset1
GROUP BY state
ORDER BY Avg_sex_ratio DESC;

-- Average literacy rate greater than 90

SELECT 
    state, ROUND((AVG(literacy)), 0) Avg_literacy
FROM
    dataset1
GROUP BY state
HAVING Avg_literacy >= 90
ORDER BY Avg_literacy DESC;

-- Top 3 states having highest growth ratio

SELECT 
    state, ROUND((AVG(growth) * 100), 2) Avg_growth
FROM
    dataset1
GROUP BY state
ORDER BY Avg_growth DESC
LIMIT 3; 

-- bottom 3 state showing lowest sex ratio

SELECT 
    state, ROUND((AVG(sex_ratio)), 0) Avg_sex_ratio
FROM
    dataset1
GROUP BY state
ORDER BY Avg_sex_ratio ASC
LIMIT 3; 

-- bottom 3 state showing lowest literacy ratio

SELECT 
    state, ROUND((AVG(literacy)), 0) Avg_literacy_ratio
FROM
    dataset1
GROUP BY state
ORDER BY Avg_literacy_ratio ASC
LIMIT 3; 

-- states having top 3 highest & bottom 3 lowest literacy ratio

DROP TABLE IF EXISTS top_states;

CREATE TABLE top_states (
    state VARCHAR(255),
	Avg_literacy_ratio DECIMAL(5,2)
);

INSERT INTO top_states (state, Avg_literacy_ratio) 
SELECT state, ROUND(AVG(literacy),0) Avg_literacy_ratio FROM dataset1
GROUP BY state
ORDER BY AVG(literacy) DESC;

DROP TABLE IF EXISTS bottom_states;

CREATE TABLE bottom_states (
    state VARCHAR(255),
	Avg_literacy_ratio DECIMAL(5,2)
);

INSERT INTO bottom_states (state, Avg_literacy_ratio) 
SELECT state, ROUND(AVG(literacy),0) Avg_literacy_ratio FROM dataset1
GROUP BY state
ORDER BY AVG(literacy) ASC;

-- 1ST APPROACH

(SELECT state, avg_literacy_ratio
FROM top_states
ORDER BY avg_literacy_ratio DESC
LIMIT 3) 
UNION
(SELECT state, avg_literacy_ratio
FROM top_states
ORDER BY avg_literacy_ratio ASC
LIMIT 3) ;

-- 2ND APPROACH

(SELECT 
    state, ROUND((AVG(literacy)), 0) Avg_literacy_ratio
FROM
    dataset1
GROUP BY state
ORDER BY Avg_literacy_ratio DESC
LIMIT 3) UNION (SELECT 
    state, ROUND((AVG(literacy)), 0) Avg_literacy_ratio
FROM
    dataset1
GROUP BY state
ORDER BY Avg_literacy_ratio ASC
LIMIT 3)
; 

-- states starting with letter 'a'

SELECT DISTINCT state
FROM dataset1
WHERE state LIKE 'a%' 
ORDER BY state;


-- states starting with letter 'a' or 'b'

SELECT DISTINCT state
FROM dataset1
WHERE state LIKE 'a%' OR state LIKE 'b%'
ORDER BY state;

-- states starting with letter 'a' and end with 'm'

SELECT DISTINCT state
FROM dataset1
WHERE state LIKE 'a%' AND state LIKE '%m'
ORDER BY state;

-- total males and females

-- FORMULA :

-- 1. Sex_ratio     = No_of_Females / No_of_Males OR No_of_Males / No_of_Females
-- 2. Population    = No_of_Males + No_of_Females
-- 3. Total_Males   = population / sex_ratio + 1
-- 4. Total_Females = population * sex_ratio / sex_ratio + 1 

SELECT 
    state,
    SUM(No_of_Males) AS Total_Males,
    SUM(No_of_Females) AS Total_Females
FROM
    (SELECT 
        state,
            district,
            ROUND((population / sex_ratio + 1), 0) AS No_of_Males,
            ROUND((population * sex_ratio / sex_ratio + 1), 0) AS No_of_Females
    FROM
        (SELECT 
        a.district,
            a.state,
            a.sex_ratio / 1000 AS sex_ratio,
            b.population
    FROM
        dataset1 AS a
    JOIN dataset2 AS b ON a.district = b.district) AS S) AS T
GROUP BY state
ORDER BY state ASC
;

-- Total Literacy Rate

-- Formula :

-- 1. Literacy_Ratio         = Total_literate_people / population
-- 2. Total_literate_people  = Literacy_Ratio * population
-- 3. Total_literate_people  = (1-Literacy_Ratio) * population

SELECT 
    state,
    SUM(literate_People) AS Total_literate_People,
    SUM(illiterate_People) AS Total_illiterate_People
FROM
    (SELECT 
        district,
            state,
            ROUND((literacy_ratio * population), 0) AS literate_People,
            ROUND((1 - literacy_ratio) * population, 0) AS illiterate_People
    FROM
        (SELECT 
        a.district,
            a.state,
            a.Literacy / 100 AS Literacy_ratio,
            b.population
    FROM
        Dataset1 AS a
    JOIN Dataset2 AS b ON a.district = b.district) AS Literacy) AS LITERACY_RATE
GROUP BY state
ORDER BY state ASC
;

-- Total population of previous  & current census 

-- 1. Population                  = Previous_Census_Population + Growth * Previous_Census_Population
-- 2. Previous_Census_Population  = Population / (1 + growth)

SELECT 
    SUM(Previous_census_population) AS Previous_census_Total_population,
    SUM(Current_census_population) AS Current_census_Total_population
FROM
    (SELECT 
        state,
            SUM(Previous_census) AS Previous_census_population,
            SUM(Current_census) AS Current_census_population
    FROM
        (SELECT 
        district,
            state,
            ROUND(population / (1 + growth), 0) AS Previous_census,
            Population AS Current_census
    FROM
        (SELECT 
        a.district, a.state, a.growth, b.population
    FROM
        dataset1 a
    JOIN dataset2 b ON a.district = b.district) AS growth) Growth_rate
    GROUP BY state
    ORDER BY state ASC) AS Census_rate;

-- population vs area

SELECT 
    (g.Total_Area / g.Previous_census_Total_population) AS Previous_census_population,
    (g.Total_Area / g.Current_census_Total_population)  AS Current_census_population
FROM
    (SELECT 
        q.*, z.total_area
    FROM
        (SELECT 
        '1' AS keyy, Y.*
    FROM
        (SELECT 
        SUM(Previous_census_population) AS Previous_census_Total_population,
            SUM(Current_census_population) AS Current_census_Total_population
    FROM
        (SELECT 
        state,
            SUM(Previous_census) AS Previous_census_population,
            SUM(Current_census) AS Current_census_population
    FROM
        (SELECT 
        district,
            state,
            ROUND(population / (1 + growth), 0) AS Previous_census,
            Population AS Current_census
    FROM
        (SELECT 
        a.district, a.state, a.growth, b.population
    FROM
        dataset1 a
    JOIN dataset2 b ON a.district = b.district) AS growth) Growth_rate
    GROUP BY state
    ORDER BY state ASC) AS Census_rate) AS Y) AS Q
    JOIN (SELECT 
        '1' AS keyy, X.*
    FROM
        (SELECT 
        SUM(area_km2) AS Total_Area
    FROM
        dataset2) AS X) AS Z ON z.keyy = q.keyy) AS g
;

-- output top 3 districts from each state with highest literacy rate

SELECT *
FROM
(SELECT state , district, Literacy,
RANK() OVER(PARTITION BY state ORDER BY literacy DESC) AS L
FROM  dataset1 ) AS A
WHERE A.L <= 3
ORDER BY state;




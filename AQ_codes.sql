CREATE DATABASE AQ;
USE weather_db;
CREATE TABLE airquality_project LIKE air_quality;
INSERT INTO airquality_project
SELECT * FROM air_quality;


SELECT COUNT(*) FROM air_quality;
SELECT COUNT(*) FROM airquality_project; 
SET SQL_SAFE_UPDATES=0;

-- Data Cleaning 

-- Exploration

SELECT * FROM airquality_project;
SELECT COUNT(*) FROM airquality_project;
SHOW COLUMNS FROM airquality_project;

-- Remove Duplicates 

SELECT *, 
       ROW_NUMBER() OVER(
           PARTITION BY region, AQI, PM10, NO2, SO2, CO, O3, temperature, humidity, date
           ORDER BY date
       ) AS row_num
FROM airquality_project;

WITH duplicate_cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(
               PARTITION BY region, AQI, PM10, NO2, SO2, CO, O3, temperature, humidity, date
               ORDER BY date
           ) AS row_num
    FROM airquality_project
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Null / Missing values

SELECT 
CONCAT(
'SELECT ',
GROUP_CONCAT(
CONCAT(
'SUM(CASE WHEN ', COLUMN_NAME, ' IS NULL THEN 1 ELSE 0 END) AS missing_', COLUMN_NAME
)
SEPARATOR ', '
),
' FROM airquality_project;'
) AS sql_query
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'airquality_project'
AND TABLE_SCHEMA = DATABASE();

SELECT 
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN AQI IS NULL THEN 1 ELSE 0 END) AS missing_AQI,
    SUM(CASE WHEN `PM2.5` IS NULL THEN 1 ELSE 0 END) AS missing_PM25,
    SUM(CASE WHEN NO2 IS NULL THEN 1 ELSE 0 END) AS missing_NO2,
    SUM(CASE WHEN SO2 IS NULL THEN 1 ELSE 0 END) AS missing_SO2,
    SUM(CASE WHEN CO IS NULL THEN 1 ELSE 0 END) AS missing_CO,
    SUM(CASE WHEN O3 IS NULL THEN 1 ELSE 0 END) AS missing_O3,
    SUM(CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) AS missing_temperature,
    SUM(CASE WHEN humidity IS NULL THEN 1 ELSE 0 END) AS missing_humidity,
    SUM(CASE WHEN wind_speed IS NULL THEN 1 ELSE 0 END) AS missing_wind_speed,
    SUM(CASE WHEN precipitation IS NULL THEN 1 ELSE 0 END) AS missing_precipitation,
    SUM(CASE WHEN hospital_visits IS NULL THEN 1 ELSE 0 END) AS missing_hospital_visits,
    SUM(CASE WHEN emergency_visits IS NULL THEN 1 ELSE 0 END) AS missing_emergency_visits,
    SUM(CASE WHEN mobility_index IS NULL THEN 1 ELSE 0 END) AS missing_mobility_index,
    SUM(CASE WHEN school_closures IS NULL THEN 1 ELSE 0 END) AS missing_school_closures
FROM airquality_project;


-- Outliers


-- Data Type

DESCRIBE airquality_project;

UPDATE airquality_project
SET date = DATE(date);
ALTER TABLE airquality_project
MODIFY COLUMN date DATE;

ALTER TABLE airquality_project
MODIFY COLUMN region VARCHAR(30);


-- Added Custom Columns

ALTER TABLE airquality_project ADD COLUMN Climate_Zone VARCHAR(30);
UPDATE airquality_project
SET Climate_Zone = CASE
    WHEN temperature > 25 AND precipitation < 200 THEN 'Desert'
    WHEN temperature BETWEEN 18 AND 25 AND precipitation BETWEEN 200 AND 800 THEN 'Semi-arid'
    WHEN temperature < 18 AND precipitation >= 800 THEN 'Mediterranean'
    ELSE 'Temperate'
END;

ALTER TABLE airquality_project ADD COLUMN Urban_Rural VARCHAR(20);
UPDATE airquality_project
SET Urban_Rural = CASE
    WHEN population_density >= 1000 AND green_cover_percentage < 30 THEN 'Urban'
    ELSE 'Rural'
END;

ALTER TABLE airquality_project ADD COLUMN Climate_Classification VARCHAR(50);
UPDATE airquality_project
SET Climate_Classification = CASE
    WHEN temperature > 20 AND humidity > 70 AND precipitation > 1000 THEN 'Tropical Rainforest'
    WHEN temperature > 20 AND humidity < 40 AND precipitation < 250 THEN 'Desert'
    WHEN temperature BETWEEN 10 AND 20 AND precipitation BETWEEN 400 AND 800 THEN 'Mediterranean'
    WHEN temperature BETWEEN 0 AND 10 AND precipitation > 800 THEN 'Temperate Oceanic'
    WHEN temperature BETWEEN 0 AND 10 AND precipitation < 400 THEN 'Continental'
    WHEN temperature < 0 AND precipitation < 250 THEN 'Polar Desert'
    WHEN temperature < 0 AND precipitation >= 250 THEN 'Tundra'
    WHEN green_cover_percentage > 60 THEN 'Forest'
    ELSE 'Temperate'
END;

ALTER TABLE airquality_project ADD COLUMN Temp_Cat VARCHAR(20);
UPDATE airquality_project
SET Temp_Cat = CASE
    WHEN temperature <= 0 THEN 'Freezing'
    WHEN temperature <= 10 THEN 'Cold'
    WHEN temperature <= 20 THEN 'Cool'
    WHEN temperature <= 30 THEN 'Warm'
    ELSE 'Hot'
END;

ALTER TABLE airquality_project ADD COLUMN Hum_Cat VARCHAR(20);
UPDATE airquality_project
SET Hum_Cat = CASE
    WHEN humidity <= 30 THEN 'Low'
    WHEN humidity <= 60 THEN 'Moderate'
    ELSE 'High'
END;

ALTER TABLE airquality_project ADD COLUMN Wind_Cat VARCHAR(20);
UPDATE airquality_project
SET Wind_Cat = CASE
    WHEN wind_speed <= 5 THEN 'Calm'
    WHEN wind_speed <= 15 THEN 'Breezy'
    ELSE 'Windy'
END;

ALTER TABLE airquality_project ADD COLUMN Rain_Cat VARCHAR(20);
UPDATE airquality_project
SET Rain_Cat = CASE
    WHEN precipitation <= 0.1 THEN 'None'
    WHEN precipitation <= 2.5 THEN 'Light'
    WHEN precipitation <= 7.6 THEN 'Moderate'
    ELSE 'Heavy'
END;

ALTER TABLE airquality_project ADD COLUMN Mob_Cat VARCHAR(20);
UPDATE airquality_project
SET Mob_Cat = CASE
    WHEN mobility_index <= 50 THEN 'Restricted'
    WHEN mobility_index <= 80 THEN 'Normal'
    ELSE 'High Mobility'
END;

ALTER TABLE airquality_project ADD COLUMN Transport_Cat VARCHAR(20);
UPDATE airquality_project
SET Transport_Cat = CASE
    WHEN public_transport_usage <= 30 THEN 'Rare'
    WHEN public_transport_usage <= 70 THEN 'Occasional'
    ELSE 'Frequent'
END;

ALTER TABLE airquality_project ADD COLUMN Sch_Closure VARCHAR(20);
UPDATE airquality_project
SET Sch_Closure = CASE
    WHEN school_closures = 0 THEN 'Open'
    WHEN school_closures = 1 THEN 'Closed'
    ELSE NULL
END;

ALTER TABLE airquality_project ADD COLUMN Lock_Stat VARCHAR(20);
UPDATE airquality_project
SET Lock_Stat = CASE
    WHEN lockdown_status = 0 THEN 'Lockdown'
    WHEN lockdown_status = 1 THEN 'No Lockdown'
    ELSE NULL
END;

ALTER TABLE airquality_project ADD COLUMN Air_Index VARCHAR(50);
UPDATE airquality_project
SET Air_Index = CASE
    WHEN AQI <= 50 THEN 'Good'
    WHEN AQI <= 100 THEN 'Moderate'
    WHEN AQI <= 150 THEN 'Unhealthy for Sensitive Groups'
    WHEN AQI <= 200 THEN 'Unhealthy'
    WHEN AQI <= 300 THEN 'Very Unhealthy'
    ELSE 'Hazardous'
END;

ALTER TABLE airquality_project ADD COLUMN Population_Cat VARCHAR(20);
UPDATE airquality_project
SET Population_Cat = CASE
    WHEN population_density <= 1000 THEN 'Sparse'
    WHEN population_density <= 5000 THEN 'Moderate'
    ELSE 'Dense'
END;

ALTER TABLE airquality_project ADD COLUMN Green_Cat VARCHAR(20);
UPDATE airquality_project
SET Green_Cat = CASE
    WHEN green_cover_percentage <= 20 THEN '0-20%'
    WHEN green_cover_percentage <= 50 THEN '21-50%'
    WHEN green_cover_percentage <= 100 THEN '51-100%'
    ELSE 'Invalid'
END;

ALTER TABLE airquality_project ADD COLUMN Industrial_Cat VARCHAR(20);
UPDATE airquality_project
SET Industrial_Cat = CASE
    WHEN industrial_activity <= 50 THEN 'Low'
    WHEN industrial_activity <= 100 THEN 'Moderate'
    WHEN industrial_activity > 100 THEN 'High'
    ELSE 'Invalid'
END;

ALTER TABLE airquality_project ADD COLUMN Construction_Cat VARCHAR(20);
UPDATE airquality_project
SET Construction_Cat = CASE
    WHEN construction_activity <= 5 THEN 'Low'
    WHEN construction_activity <= 10 THEN 'Moderate'
    WHEN construction_activity > 10 THEN 'High'
    ELSE 'Invalid'
END;


-- Conditional Columns

ALTER TABLE airquality_project
ADD COLUMN ERI FLOAT,
ADD COLUMN HBI FLOAT,
ADD COLUMN PLI FLOAT,
ADD COLUMN GDI FLOAT,
ADD COLUMN HPI FLOAT,
ADD COLUMN RRR FLOAT;

-- Environmental Risk Index (ERI)
UPDATE airquality_project
SET ERI = (industrial_activity + vehicle_count + construction_activity + population_density)
/ (green_cover_percentage + 1);

-- Health Burden Index (HBI)
UPDATE airquality_project
SET HBI = (respiratory_admissions + hospital_visits + emergency_visits)
/ (population_density + 1);

-- Pollution Load Index (PLI)
UPDATE airquality_project
SET PLI = industrial_activity + vehicle_count + construction_activity;

-- Green Deficit Index (GDI)
UPDATE airquality_project
SET GDI = population_density / (green_cover_percentage + 1);

-- Hospital Pressure Index (HPI)
UPDATE airquality_project
SET HPI = (hospital_visits + emergency_visits) / (population_density + 1);

-- Respiratory Risk Ratio (RRR)
UPDATE airquality_project
SET RRR = respiratory_admissions / NULLIF(PLI, 0);



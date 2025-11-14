 -- Analysis 
-- Overview Insights
 
 --  Seasonal average
 
 SELECT 
  season,
  ROUND(AVG(AQI),2) AS avg_AQI
FROM airquality_project
GROUP BY Season
ORDER BY avg_AQI DESC;

-- + Higher AQI in winter → trapped pollutants due to low wind
-- + Lower AQI in summer → more dispersion and humidity effects


--  policy / Mask usage
SELECT 
  lockdown_status,
  ROUND(AVG(AQI),2) AS avg_AQI,
  ROUND(AVG(mobility_index),2) AS avg_mobility,
  ROUND(AVG(mask_usage_rate),2) AS avg_mask
FROM airquality_project
GROUP BY lockdown_status
ORDER BY avg_AQI DESC;


-- + During lockdown (status = 1), mobility decreases → AQI likely decreases
-- + Mask usage might correlate with lower health impact but not directly with AQI


SELECT 
  region,
  ROUND(AVG(AQI),2) AS avg_AQI,
  ROUND(AVG(industrial_activity),2) AS avg_industry,
  ROUND(AVG(vehicle_count),2) AS avg_vehicles,
  ROUND(AVG(green_cover_percentage),2) AS avg_green
FROM airquality_project
GROUP BY region
ORDER BY avg_AQI DESC;
--  Regions with higher industry and vehicle_count → higher AQI (more pollution)
--  Regions with higher green_cover → lower AQI (better air quality)



-- AQI by Climate Zone

SELECT 
    Climate_Zone,
    ROUND(AVG(AQI),2) AS avg_AQI
FROM airquality_project
GROUP BY Climate_Zone
ORDER BY avg_AQI DESC;

-- + Desert zones → higher AQI due to dust particles
-- + Temperate zones → lower AQI, better dispersion and vegetation



--  AQI Vs Population density

SELECT 
    Temp_Cat,
    ROUND(AVG(AQI),2) AS avg_AQI
FROM airquality_project
GROUP BY Temp_Cat
ORDER BY avg_AQI DESC;

-- + High temperature → sometimes higher ozone, moderate AQI
-- + Low temperature → stagnant air → higher AQI



-- AQI vs Respiratory admission

SELECT 
    ROUND(AQI/50)*50 AS AQI_range,  
    ROUND(AVG(respiratory_admissions),2) AS avg_respiratory
FROM airquality_project
GROUP BY AQI_range
ORDER BY AQI_range;

-- + Higher AQI → more respiratory admissions
-- + Shows dose-response relationship between pollution and health impact




-- AQI vs Hospital visits

SELECT 
    ROUND(AQI/50)*50 AS AQI_range,
    ROUND(AVG(hospital_visits),2) AS avg_hospital
FROM airquality_project
GROUP BY AQI_range
ORDER BY AQI_range;

-- + Higher AQI → more hospital visits, especially in winter
-- + Could reflect pollution-related exacerbation of chronic conditions



-- AQI vs emergeny visits

SELECT 
    ROUND(AQI/50)*50 AS AQI_range,
    ROUND(AVG(emergency_visits),2) AS avg_emergency
FROM airquality_project
GROUP BY AQI_range
ORDER BY AQI_range;

-- + Peaks in emergency visits often coincide with high AQI days
-- + Useful for planning public health interventions



-- Respiratory admissions vs specific pollutants

SELECT
    'PM2_5' AS pollutant,
    ROUND((AVG(respiratory_admissions*PM2_5) - AVG(respiratory_admissions)*AVG(PM2_5)) 
          / (NULLIF(STDDEV_POP(respiratory_admissions),0)*NULLIF(STDDEV_POP(PM2_5),0)),3) AS corr
UNION ALL
SELECT 'PM10', ROUND((AVG(respiratory_admissions*PM10) - AVG(respiratory_admissions)*AVG(PM10)) 
                     / (NULLIF(STDDEV_POP(respiratory_admissions),0)*NULLIF(STDDEV_POP(PM10),0)),3)
UNION ALL
SELECT 'NO2', ROUND((AVG(respiratory_admissions*NO2) - AVG(respiratory_admissions)*AVG(NO2)) 
                    / (NULLIF(STDDEV_POP(respiratory_admissions),0)*NULLIF(STDDEV_POP(NO2),0)),3);
                    
                    

                    
-- + PM2.5 & PM10 usually correlate strongest with respiratory admissions
-- + NO2 also shows positive correlation, indicating traffic contribution
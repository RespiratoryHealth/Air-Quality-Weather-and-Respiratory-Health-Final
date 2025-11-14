-- Data Modeling 


-- Dim Date

CREATE TABLE Dim_Date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    day INT,
    weekday VARCHAR(20),
    season VARCHAR(20)
);

-- Dim Region

CREATE TABLE Dim_Region (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region VARCHAR(100),
    Climate_Zone VARCHAR(50),
    Urban_Rural VARCHAR(50)
);


-- Dim Weather

CREATE TABLE Dim_Weather (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT,
    humidity FLOAT,
    wind_speed FLOAT,
    precipitation FLOAT,
    Temp_Cat VARCHAR(50),
    Hum_Cat VARCHAR(50),
    Wind_Cat VARCHAR(50),
    Rain_Cat VARCHAR(50)
);



-- Dim Policy

CREATE TABLE Dim_Policy (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    mobility_index FLOAT,
    school_closures BOOLEAN,
    public_transport_usage FLOAT,
    mask_usage_rate FLOAT,
    lockdown_status BOOLEAN,
    Mob_Cat VARCHAR(50),
    Transport_Cat VARCHAR(50),
    Sch_Closure VARCHAR(50),
    Lock_Stat VARCHAR(50)
);


-- Dim Demographic

CREATE TABLE Dim_Demographic (
    demographic_id INT AUTO_INCREMENT PRIMARY KEY,
    population_density FLOAT,
    green_cover_percentage FLOAT,
    industrial_activity FLOAT,
    construction_activity FLOAT,
    vehicle_count INT,
    Population_Cat VARCHAR(50),
    Green_Cat VARCHAR(50),
    Industrial_Cat VARCHAR(50),
    Construction_Cat VARCHAR(50)
);


-- Fact Table

CREATE TABLE Fact_AirQuality (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    date_id INT,
    region_id INT,
    weather_id INT,
    policy_id INT,
    demographic_id INT,
    AQI FLOAT,
    PM2_5 FLOAT,
    PM10 FLOAT,
    NO2 FLOAT,
    SO2 FLOAT,
    CO FLOAT,
    O3 FLOAT,
    hospital_visits INT,
    emergency_visits INT,
    respiratory_admissions INT,
    ERI FLOAT,
    HBI FLOAT,
    PLI FLOAT,
    GDI FLOAT,
    HPI FLOAT,
    RRR FLOAT,
    FOREIGN KEY (date_id) REFERENCES Dim_Date(date_id),
    FOREIGN KEY (region_id) REFERENCES Dim_Region(region_id),
    FOREIGN KEY (weather_id) REFERENCES Dim_Weather(weather_id),
    FOREIGN KEY (policy_id) REFERENCES Dim_Policy(policy_id),
    FOREIGN KEY (demographic_id) REFERENCES Dim_Demographic(demographic_id)
);



INSERT INTO Dim_Date (date, year, month, day, weekday, season)
SELECT DISTINCT 
    DATE(date) AS date,
    YEAR(date) AS year,
    MONTH(date) AS month,
    DAY(date) AS day,
    DAYNAME(date) AS weekday,
    CASE 
        WHEN MONTH(date) IN (12,1,2) THEN 'Winter'
        WHEN MONTH(date) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(date) IN (6,7,8) THEN 'Summer'
        WHEN MONTH(date) IN (9,10,11) THEN 'Autumn'
    END AS season
FROM weather_db.airquality_project
WHERE date IS NOT NULL;
INSERT INTO Dim_Region (region, Climate_Zone, Urban_Rural)
SELECT DISTINCT 
    region,
    Climate_Zone,
    Urban_Rural
FROM weather_db.airquality_project
WHERE region IS NOT NULL;
INSERT INTO Dim_Weather (temperature, humidity, wind_speed, precipitation, Temp_Cat, Hum_Cat, Wind_Cat, Rain_Cat)
SELECT DISTINCT 
    temperature,
    humidity,
    wind_speed,
    precipitation,
    Temp_Cat,
    Hum_Cat,
    Wind_Cat,
    Rain_Cat
FROM weather_db.airquality_project;
INSERT INTO Dim_Policy (mobility_index, school_closures, public_transport_usage, mask_usage_rate, lockdown_status,
                        Mob_Cat, Transport_Cat, Sch_Closure, Lock_Stat)
SELECT DISTINCT 
    mobility_index,
    school_closures,
    public_transport_usage,
    mask_usage_rate,
    lockdown_status,
    Mob_Cat,
    Transport_Cat,
    Sch_Closure,
    Lock_Stat
FROM weather_db.airquality_project;
INSERT INTO Dim_Demographic (population_density, green_cover_percentage, industrial_activity, construction_activity, vehicle_count,
                             Population_Cat, Green_Cat, Industrial_Cat, Construction_Cat)
SELECT DISTINCT 
    population_density,
    green_cover_percentage,
    industrial_activity,
    construction_activity,
    vehicle_count,
    Population_Cat,
    Green_Cat,
    Industrial_Cat,
    Construction_Cat
FROM weather_db.airquality_project;
INSERT INTO Fact_AirQuality (
    date_id, region_id, weather_id, policy_id, demographic_id,
    AQI, PM2_5, PM10, NO2, SO2, CO, O3,
    hospital_visits, emergency_visits, respiratory_admissions,
    ERI, HBI, PLI, GDI, HPI, RRR
)
SELECT 
    d.date_id,
    r.region_id,
    w.weather_id,
    p.policy_id,
    demo.demographic_id,
    a.AQI, a.PM2_5, a.PM10, a.NO2, a.SO2, a.CO, a.O3,
    a.hospital_visits, a.emergency_visits, a.respiratory_admissions,
    a.ERI, a.HBI, a.PLI, a.GDI, a.HPI, a.RRR
FROM weather_db.airquality_project a
JOIN Dim_Date d ON DATE(a.date) = d.date
JOIN Dim_Region r ON a.region = r.region
JOIN Dim_Weather w ON a.temperature = w.temperature AND a.humidity = w.humidity
JOIN Dim_Policy p ON a.mobility_index = p.mobility_index
JOIN Dim_Demographic demo ON a.population_density = demo.population_density;
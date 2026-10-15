CREATE DATABASE IF NOT EXISTS nigeria_oil_gas;
USE nigeria_oil_gas;

CREATE TABLE IF NOT EXISTS stg_oil_production (
 production_month DATE NOT NULL, terminal_stream VARCHAR(100) NOT NULL, liquid_type VARCHAR(30) NOT NULL, production_barrels BIGINT NULL, unit VARCHAR(20) NOT NULL, source VARCHAR(150) NOT NULL
);

ALTER TABLE stg_oil_production
ADD COLUMN data_status
VARCHAR(50) NOT NULL;

CREATE TABLE IF NOT EXISTS raw_oil_production (
 production_month DATE NOT NULL, terminal_stream VARCHAR(100) NOT NULL, liquid_type VARCHAR(30) NOT NULL, production_barrels BIGINT NULL, unit VARCHAR(20) NOT NULL, source VARCHAR(150) NOT NULL, data_status
VARCHAR(50) NOT NULL
);

INSERT INTO raw_oil_production
SELECT *
FROM stg_oil_production;

 Describe stg_oil_production;
-- Replace the path with the actual local CSV path MySQL can access.
LOAD DATA INFILE 'NUPRC_2025_Oil_Production_Long.csv'
INTO TABLE stg_oil_production
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS
(production_month, terminal_stream, liquid_type, @production_barrels, unit, source)
SET production_barrels = NULLIF(@production_barrels,'');


SELECT COUNT(*) AS totall_rows
FROM stg_oil_production; -- 417 rows

-- checking if the values landed in the right columns
SELECT *
FROM stg_oil_production; -- properly situated

-- checkking the date range
SELECT
	MIN(production_month) AS first_month,
    MAX(production_month) AS last_month,
    COUNT(DISTINCT production_month) AS num__dates
FROM stg_oil_production; -- mmin  = 2025-01-01, and max = 2025-01-12, 12 dates

UPDATE stg_oil_production
SET production_month =
    STR_TO_DATE(
DATE_FORMAT(production_month,'%Y-%d-%m'),
		'%Y-%m-%d'
        );

SELECT 
DATE_FORMAT(production_month,'%Y-%m-%d') AS production_month
FROM stg_oil_production;

SELECT DISTINCT production_month
FROM stg_oil_production
ORDER BY production_month;

-- cheking the liquid types
SELECT DISTINCT liquid_type
FROM stg_oil_production; -- crude and condensate

-- checking terminal/stream names
SELECT DISTINCT terminal_stream
FROM stg_oil_production; -- 29 streamms; BONNY, BRASS, QUA IBOE, FORCADOS, ESCRAVOS (Oil Terminal), ODUDU (AMENAM BLEND), TULJA - OKWUIBOME, OKORO (Ex Ima Terminal), OTAKPIPO (Ex Ima Terminal), ANTAN, OKONO, YOHO, OKWORI, EBOK, AJAPA, BONGA, ERHA, USAN, EGINA, OYO / OBODO, ABO, PENNINGTON, UGO OCHA (JONES CREEK), SEA EAGLE (EA), ANYALA MADU (CJ Blend), NEMBE, UTAPATE, AGBAMI, AKPO
-- note theyre a in uppercase

-- cchecking for missing production values
SELECT *
FROM stg_oil_production
WHERE production_barrels IS NULL; -- no missing values

-- duplicate check 
SELECT production_month, terminal_stream, liquid_type, 
	COUNT(*) AS record_count
FROM stg_oil_production
GROUP BY 
	production_month, terminal_stream, liquid_type
HAVING COUNT(*) > 1; -- none

-- missing production check
SELECT
	COUNT(*) AS tota_rows,
    SUM(production_barrels IS NULL) AS missing_production
FROM stg_oil_production; -- none

-- production vaues check
SELECT 
	MIN(production_barrels) AS minimium_production,
    MAX(production_barrels) AS maximum_production,
    SUM(production_barrels <= 0) AS zero_or_nnegtive_value
FROM stg_oil_production; -- 4438,	8585208,	0

--
SELECT
	production_month, count(*) AS recrd_month
FROM stg_oil_production
GROUP BY production_month
ORDER BY production_month; -- ONLY AUGOCT & DEC HAS 34, OTHERS 35   

-- check foor termmina reords missing in aug, oct and dec
SELECT 
	terminal_stream, liquid_type,
    SUM(MONTH(production_month) = 8) AS August,
    SUM(MONTH(production_month) = 10) AS October,
    SUM(MONTH(production_month) = 12) AS December
FROM stg_oil_production
GROUP BY terminal_stream, liquid_type
HAVING August = 0
	OR October = 0
    OR December = 0;
    
-- monthly prodution by liquid type
SELECT production_month, liquid_type,
	COUNT(*) AS record_count,
    SUM(production_barrels) AS total_production
FROM stg_oil_production
GROUP BY production_month, liquid_type
ORDER BY production_month, liquid_type;

-- inspect nvember production
SELECT terminal_stream, liquid_type, production_barrels
FROM stg_oil_production
WHERE production_month = '2025-11-01'
ORDER BY terminal_stream, liquid_type;

-- for ajapa condensate and yoho crude oil, which months do they appear
SELECT production_month, terminal_stream, liquid_type, production_barrels
FROM stg_oil_production
WHERE(terminal_stream = 'AJAPA'
AND liquid_type = 'Condensate')
	OR (terminal_stream = 'YOHO'
AND liquid_type = 'Crude Oil')
ORDER BY terminal_stream, liquid_type, production_month;


-- ANAYSIS PROPER
-- STEP 1 : MONTHLY PRODUTION TREND
SELECT production_month,
	SUM(CASE
		WHEN liquid_type = 'Crude Oil'
        THEN production_barrels
        ELSE 0
	END) AS Crude_production,
	SUM(CASE 
		WHEN liquid_type = 'Condensate'
        THEN production_barrels
        ELSE 0
	END) AS Condensate_production,
	SUM(production_barrels) AS total_production
FROM stg_oil_production
GROUP BY production_month
ORDER BY production_month;

-- STEP 2: MONTH-ON-MONTH CHNGE
WITH monthly_production AS (
	SELECT
		production_month, SUM(production_barrels)
AS total_production
	FROM stg_oil_production
    GROUP BY production_month
)

SELECT
	production_month,
    total_production,
    total_production
		- LAG(total_production)
OVER (
			ORDER BY
production_month
		) AS production_change
FROM monthly_production
ORDER BY production_month;
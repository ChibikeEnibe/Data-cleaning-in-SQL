SELECT * FROM public.fifa21;


--   Creating the tables and Columns   --
CREATE TABLE IF NOT EXISTS public.fifa21
(
    ID integer NOT NULL,
    "Name" character varying(255) COLLATE pg_catalog."default",
    "LongName" character varying(255) COLLATE pg_catalog."default",
    photoUrl character varying(255) COLLATE pg_catalog."default",
    playerUrl character varying(255) COLLATE pg_catalog."default",
	Nationality character varying(100) COLLATE pg_catalog."default",
    Age integer,
	OVA integer,
    POT integer,
	"Club" character varying(100) COLLATE pg_catalog."default",
	"Contract" character varying(50) COLLATE pg_catalog."default",
    Positions character varying(50) COLLATE pg_catalog."default",
    Height integer,
    Weight integer,
    "Preferred Foot" character varying(10) COLLATE pg_catalog."default",
    BOV integer,
    "Best Position" character varying(10) COLLATE pg_catalog."default",
	Joined date,
    "Loan Date End" date,
    "Value" character varying(20) COLLATE pg_catalog."default",
    "Wage" character varying(20) COLLATE pg_catalog."default",
    "Release Clause" character varying(20) COLLATE pg_catalog."default",
    Attacking integer,
    Crossing integer,
    Finishing integer,
    "Heading Accuracy" integer,
    "Short Passing" integer,
    Volleys integer,
    Skill integer,
    Dribbling integer,
    Curve integer,
    "FK Accuracy" integer,   
    "Long Passing" integer,
    "Ball Control" integer,
    Movement integer,
    Acceleration integer,
    "Sprint Speed" integer,
    Agility integer,
    Reactions integer,
    Balance integer,
    Power integer,
    "Shot Power" integer,
    Jumping integer,
    Stamina integer,
    Strength integer,
    "Long Shots" integer,
    Mentality integer,
    Aggression integer,
    Interceptions integer,
    Positioning integer,
    Vision integer,
    Penalties integer,
    Composure integer,
    Defending integer,
    Marking integer,
    "Standing Tackle" integer,
    "Sliding Tackle" integer,
    Goalkeeping integer,
    "GK Diving" integer,
    "GK Handling" integer,
    "GK Kicking" integer,
    "GK Positioning" integer,
    "GK Reflexes" integer,
    "Total Stats" integer,
    "Base Stats" integer,
    "W/F" character varying(20) COLLATE pg_catalog."default",
	"SM" character varying(20) COLLATE pg_catalog."default",
	"A/W" character varying(10) COLLATE pg_catalog."default",
	"D/W" character varying(10) COLLATE pg_catalog."default",
    "IR" character varying(10) COLLATE pg_catalog."default",
	PAC integer,
    SHO integer,
    PAS integer,
    DRI integer,
    DEF integer,
    PHY integer,
    Hits integer,
  CONSTRAINT fifa21_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;
ALTER TABLE IF EXISTS public.fifa21
   OWNER to postgres;


-- Loading the CSV file into the newly created table
COPY fifa21 FROM 'C:/Users/Public/Documents/fifa21.csv' DELIMITER ',' CSV HEADER;


--     DATA CLEANING IN CLUB COLUMN    --

--  This query removes the character 1. from the club column and replaces it with an empty string
UPDATE fifa21 SET        
    club = REPLACE(club, $$1. $$, '');
--     DATA CLEANING IN CONTRACT COLUMN    --



-- This query creates new columns contract_startyear and contract_endyear and stores it as an INTEGER data type
ALTER TABLE fifa21 ADD COLUMN contract_startyear INTEGER;
ALTER TABLE fifa21 ADD COLUMN contract_endyear INTEGER;


-- This query extracts the four chracters from the left and right of the contract column where the rows contain the value ---- ~ ---- i.e 2018 ~ 2021. It then places the four characters from the left on the contract_startyear column and the four characters from the right on the contract_endyear column 
UPDATE fifa21 SET 
    contract_startyear = LEFT(contract, 4),
    contract_endyear = RIGHT(contract, 4)
WHERE contract LIKE '____ ~ ____';


-- This query extracts the four charcters on the 12th position left of records having the characters On loan and places it in the contract_endyear column
UPDATE fifa21 SET 
   contract_endyear = SUBSTR(contract, -12, 4)
WHERE contract LIKE '%On Loan%';


-- This query extracts the date from the loan date end column where the records are not null and places it in the contract_endyear column
UPDATE fifa21 SET 
    contract_endyear = EXTRACT(YEAR FROM "Loan Date End")
WHERE "Loan Date End" IS NOT NULL;



--      DATA CLEANING IN HEIGHT COLUMN      --



-- This query replaces the " symbol which represents Inches with an empty string
UPDATE fifa21 SET
    height = REPLACE(height, '"', '');
	
	
-- This query replaces the ' symbol which represents Feet with an empty string	
UPDATE fifa21 SET        
    height = REPLACE(height, '''', '');
					 

-- This query replaces the cm unit in the height column with an empty string					 
UPDATE fifa21 SET        
    height = REPLACE(height, $$cm$$, '');
					 
					 
-- This query changes the data type of the height column to integer type so it can be possible to perform calculations and to use aggregated functions
ALTER TABLE fifa21
ALTER COLUMN height TYPE integer
USING height::integer;
					 
					 
-- To check for all the distinct characters in the height column 
SELECT DISTINCT(height)
	FROM public.fifa21;
			
					 
-- This query casts the value 62 and converts it to the corresponding units in cm and it rounds the result to the nearest whole number					 
UPDATE fifa21
SET height = ROUND((6 * 30.48) + (2 * 2.54))
WHERE height = 62;
					 

--     DATA CLEANING IN WEIGHT COLUMN     --	
					 
					 
					 
-- To check all the distinct characters we have in the weight column in descending order					 
SELECT DISTINCT(weight)
FROM public.fifa21
ORDER BY weight DESC;					 

					 
-- To Check the maximum number of weight not in kg    
SELECT MAX(weight)
FROM public.fifa21
WHERE weight NOT LIKE '%kg';

					 
-- To Check the maximum number of weights in kg					 
SELECT MAX(weight)
FROM public.fifa21
WHERE weight LIKE '___kg';	


-- This query replaces the lbs unit in the weight column to an empty string
UPDATE fifa21 SET        
    weight = REPLACE(weight, $$lbs$$, '');
					 

-- This query replaces the kg unit with an empty string					 
UPDATE fifa21 SET        
    weight = REPLACE(weight, $$kg$$, '');
					 
					 
-- This query changes the data type of the weight column to integer type so it can be possible to use aggregated functions
ALTER TABLE fifa21
ALTER COLUMN weight TYPE integer
USING weight::integer;
					
					 
-- This query converts weight in lbs to kg. Converting lbs values which are <= 130 to kg
UPDATE fifa21
SET weight = ROUND(weight * 0.45359237)	
WHERE weight >= 130;


-- This changes the name of the column from height to height_cm and weight to weight_kg
ALTER TABLE fifa21
RENAME COLUMN height TO height_cm,
RENAME COLUMN weight TO weight_kg;



-- DATA CLEANING IN VALUE COLUMN --


-- This query removes €(Euro sign) and replaces it with an empty string. It also removes K(thousands) and replaces it with 000 on only rows in the value column containing a K character.
UPDATE fifa21 
SET value = 
    CASE 
	    WHEN value LIKE '%K' AND value NOT LIKE '%M'
		     THEN REPLACE(REPLACE(value, $$€$$, ''), $$K$$, '000')
		ELSE value 
	END;


-- To check for all the distinct characters in the value column
SELECT DISTINCT(value)
FROM public.fifa21
ORDER BY value


-- This query removes the €, ., and M(millions) and replaces them with an empty string for € and ., 00000 for M. It executes it on only rows contaning a M character	
UPDATE fifa21 
SET value = 
    CASE 
	    WHEN value LIKE '%M' AND value NOT LIKE '%0'
		     THEN REPLACE(REPLACE(REPLACE(value, $$€$$, ''), $$.$$, ''), $$M$$, '00000')
		ELSE value 
	END;
	
-- This query removes the € sign from the rows containing €0 and replaces it with an empty string 	
UPDATE fifa21 
SET value = 
    CASE 
	    WHEN value LIKE '€0' 
		     THEN REPLACE(value, $$€$$, '')
		ELSE value 
	END;	
	
	
-- This query changes the column name from value to value_InEuros
ALTER TABLE fifa21
RENAME COLUMN value TO value_InEuros


-- This query changes the data type of the value_InEuros column from text to integer so we can perform calculations
ALTER TABLE fifa21
ALTER COLUMN value_InEuros  TYPE integer
USING value_InEuros::integer;



-- DATA CLEANING IN WAGE COLUMN --


-- This query removes the € sign from only characters ending with 0 and replaces it with an empty string
UPDATE fifa21 
SET wage = 
    CASE 
	    WHEN wage LIKE '%0' 
		     THEN REPLACE(wage, $$€$$, '')
		ELSE wage 
	END;
	
	
-- To check for all the distinct characters in the wage column
SELECT DISTINCT(wage)
FROM public.fifa21
ORDER BY wage;


-- This query removes the € and K and replaces with an empty string and 000 respectively from the only the rows containing the character K
UPDATE fifa21 
SET wage = 
    CASE 
	    WHEN wage LIKE '%K' AND wage NOT LIKE '%0'
		     THEN REPLACE(REPLACE(wage, $$€$$, ''), $$K$$, '000')
		ELSE wage 
	END;


-- This query changes the column name from wage to wage_InEuros
ALTER TABLE fifa21
RENAME COLUMN wage TO wage_InEuros


-- This query changes the data type of the wage_InEuros column from varchar(20) to integer so we can perform calculations
ALTER TABLE fifa21
ALTER COLUMN wage_InEuros  TYPE integer
USING wage_InEuros::integer;



-- DATA CLEANING IN RELEASE CLAUSE COLUMN --


SELECT DISTINCT("Release Clause")
FROM public.fifa21
ORDER BY "Release Clause";


-- This query removes €(Euro sign) and replaces it with an empty string. It also removes K(thousands) and replaces it with 000 on only rows in the "Release Clause" column containing a K character.
UPDATE fifa21 
SET "Release Clause" = 
    CASE 
	    WHEN "Release Clause" LIKE '%K' AND "Release Clause" NOT LIKE '%M'
		     THEN REPLACE(REPLACE("Release Clause", $$€$$, ''), $$K$$, '000')
		ELSE "Release Clause" 
	END;
	
	
-- This query removes the €, ., and M(millions) and replaces them with an empty string for € and ., 00000 for M. It executes it on only rows contaning a M character	
UPDATE fifa21 
SET "Release Clause" = 
    CASE 
	    WHEN "Release Clause" LIKE '%M' AND "Release Clause" NOT LIKE '%0'
		     THEN REPLACE(REPLACE(REPLACE("Release Clause", $$€$$, ''), $$.$$, ''), $$M$$, '00000')
		ELSE "Release Clause" 
	END;
	
	
-- This query removes the € sign from the rows containing €0 and replaces it with an empty string 	
UPDATE fifa21 
SET "Release Clause" = 
    CASE 
	    WHEN "Release Clause" LIKE '€0' 
		     THEN REPLACE("Release Clause", $$€$$, '')
		ELSE "Release Clause" 
	END;
	
	
-- This query changes the data type of the "Release Clause" column from varchar(20) to integer so we can perform calculations
ALTER TABLE fifa21
ALTER COLUMN "Release Clause"  TYPE integer
USING "Release Clause"::integer;



--      DATA CLEANING IN "W/F" COLUMN     --


-- This query removes the special character i.e the star symbol and replaces it with an empty string
UPDATE fifa21
SET "W/F" = REPLACE("W/F", ' ★', '');



SELECT DISTINCT("W/F")
FROM public.fifa21
ORDER BY "W/F";


-- This query changes the data type of the "W/F" column to integer type so it can be possible to perform calculations and use aggregated functions
ALTER TABLE fifa21
ALTER COLUMN "W/F" TYPE integer
USING "W/F"::integer;



--      DATA CLEANING IN SM COLUMN     --


-- This query removes the special character i.e the star symbol and replaces it with an empty string
UPDATE fifa21
SET sm = REPLACE(sm, '★', '');


SELECT DISTINCT(sm)
FROM public.fifa21
ORDER BY sm;


-- This query changes the data type of the sm column to integer type so it can be possible to perform calculations and use aggregated functions
ALTER TABLE fifa21
ALTER COLUMN sm TYPE integer
USING sm::integer;



--      DATA CLEANING IN IR COLUMN     --


-- This query removes the special character i.e the star symbol and replaces it with an empty string
UPDATE fifa21
SET "IR" = REPLACE("IR", ' ★', '');


SELECT DISTINCT("IR")
FROM public.fifa21
ORDER BY "IR";


-- This query changes the data type of the sm column to integer type so it can be possible to perform calculations and use aggregated functions
ALTER TABLE fifa21
ALTER COLUMN "IR" TYPE integer
USING "IR"::integer;


SELECT DISTINCT(club)
FROM public.fifa21
ORDER BY club;



--     DROP USELESS AND UNWANTED COLUMNS     --
ALTER TABLE fifa21
DROP COLUMN playerurl;


--  Export cleaned data into loacl system
COPY fifa21 to 'C:/Users/Public/Documents/fifa21.csv' with (format csv, header true, encoding 'UTF8');
-- rename columns for 2023 daily aqi
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2023 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2023 aqi
ALTER TABLE public.daily_aqi_2023 ALTER COLUMN date TYPE DATE USING date::date;

-- rename columns for 2013 daily aqi
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2013 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2013 aqi
ALTER TABLE public.daily_aqi_2013 ALTER COLUMN date TYPE DATE USING date::date;

-- rename columns for 2003 daily aqi
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "State Name" TO "state_name";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "county Name" TO "county_name";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "State Code" TO "state_code";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "County Code" TO "county_code";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Date" TO "date";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Defining Parameter" TO "defining_parameter";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Defining Site" TO "defining_site";
ALTER TABLE public.daily_aqi_2003 RENAME COLUMN "Number of Sites Reporting" TO "num_sites_reporting";

-- make date column Date type 2003 aqi
ALTER TABLE public.daily_aqi_2003 ALTER COLUMN date TYPE DATE USING date::date;


-- Find average aqi by year by season
SELECT ROUND(AVG(aqi),2), 
			CASE
           WHEN EXTRACT(MONTH FROM date) BETWEEN 3 AND 5 THEN 'Spring'
           WHEN EXTRACT(MONTH FROM date) BETWEEN 6 AND 8 THEN 'Summer'
           WHEN EXTRACT(MONTH FROM date) BETWEEN 9 AND 11 THEN 'Fall'
           ELSE 'Winter'
           END AS season
FROM public.daily_aqi_2023
GROUP BY season;


SELECT * FROM daily_aqi_2023;
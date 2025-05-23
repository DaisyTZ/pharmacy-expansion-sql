-- Find a pharmacy brand in the healthcare industry that has the most traffic in the past 5 years.

SELECT p.location_name AS pharmacy_name, 
SUM(v.raw_visit_counts) AS total_visits
FROM `elemental-leaf-436616-q5.safegraph.places` AS p
JOIN `elemental-leaf-436616-q5.safegraph.visits` AS v
ON p.safegraph_place_id = v.safegraph_place_id
WHERE p.top_category = 'Health and Personal Care Stores'
AND v.date_range_start >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR))  -- Convert to TIMESTAMP, and -- Filter for visits within the last 5 years
GROUP BY p.location_name
ORDER BY total_visits DESC
LIMIT 5;

-- Find a county that has an elderly population higher than average and a high-income population higher than average, then calculate the pharmacy per capita ratio to identify the county with the highest pharmacy capacity.

CREATE TEMPORARY TABLE potential_county_table AS
SELECT f.county,f.state_fips,f.county_fips,f.state,
     SUM(`pop_m_60-61` + `pop_m_62-64` + `pop_m_65-66` + `pop_m_67-69`+`pop_m_70-74`+
         `pop_f_60-61` + `pop_f_62-64` + `pop_f_65-66`+`pop_f_67-69`+`pop_f_70-74`) AS older_population,
     SUM(`inc_75-100` + `inc_100-125` + `inc_125-150`) AS higher_income_population
FROM `elemental-leaf-436616-q5.safegraph.cbg_demographics` AS d
JOIN `elemental-leaf-436616-q5.safegraph.cbg_fips` AS f
ON SUBSTRING(d.cbg, 1, 2) = f.state_fips
AND SUBSTRING(d.cbg, 3, 3) = f.county_fips
GROUP BY f.county,f.state_fips,f.county_fips,f.state
HAVING older_population > (
  SELECT AVG(older_population)
  FROM (
      SELECT SUM(`pop_m_60-61` + `pop_m_62-64` + `pop_m_65-66` + `pop_m_67-69`+`pop_m_70-74`+
                  `pop_f_60-61` + `pop_f_62-64` + `pop_f_65-66`+`pop_f_67-69`+`pop_f_70-74`) AS older_population,
      FROM `elemental-leaf-436616-q5.safegraph.cbg_demographics` AS d
      JOIN `elemental-leaf-436616-q5.safegraph.cbg_fips` AS f
        ON SUBSTRING(d.cbg, 1, 2) = f.state_fips
        AND SUBSTRING(d.cbg, 3, 3) = f.county_fips
      GROUP BY f.county
  ) AS subquery)
AND higher_income_population> (
SELECT AVG(income)
  FROM (
      SELECT SUM(`inc_75-100` + `inc_100-125` + `inc_125-150`) AS income,
      FROM `elemental-leaf-436616-q5.safegraph.cbg_demographics` AS d
      JOIN `elemental-leaf-436616-q5.safegraph.cbg_fips` AS f
        ON SUBSTRING(d.cbg, 1, 2) = f.state_fips
        AND SUBSTRING(d.cbg, 3, 3) = f.county_fips
      GROUP BY f.county
  ) AS sub);


SELECT county, state,SUM (older_population)/COUNT(v.safegraph_place_id) pharmacy_percapita
FROM potential_county_table pc
JOIN `elemental-leaf-436616-q5.safegraph.visits` v
ON SUBSTRING(v.poi_cbg, 1, 2) = pc.state_fips
        AND SUBSTRING(v.poi_cbg, 3, 3) = pc.county_fips
JOIN `elemental-leaf-436616-q5.safegraph.places` p
ON v.safegraph_place_id = p.safegraph_place_id
WHERE p.top_category = 'Health and Personal Care Stores'
GROUP BY county,state
ORDER BY pharmacy_percapita DESC;


-- Finding the busiest day and hour for Walgreens as the ideal business day and hour.

SELECT
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Monday') AS INT64))/SUM(raw_visit_counts) AS total_monday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Tuesday') AS INT64))/SUM(raw_visit_counts) AS total_tuesday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Wednesday') AS INT64))/SUM(raw_visit_counts) AS total_wednesday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Thursday') AS INT64))/SUM(raw_visit_counts) AS total_thursday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Friday') AS INT64))/SUM(raw_visit_counts) AS total_friday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day, '$.Saturday') AS INT64))/SUM(raw_visit_counts) AS total_saturday,
SUM(CAST(JSON_EXTRACT_SCALAR(popularity_by_day,'$.Sunday') AS INT64))/SUM(raw_visit_counts) AS total_sunday
FROM `elemental-leaf-436616-q5.safegraph.visits` AS v
JOIN `elemental-leaf-436616-q5.safegraph.places` AS p
ON v.safegraph_place_id = p.safegraph_place_id
JOIN `elemental-leaf-436616-q5.safegraph.cbg_fips` AS f
ON v.region = f.state
WHERE p.city LIKE '%Cook%'
AND state = 'IL';


SELECT
   f.county,
   f.state,
   SUM(
       `pop_m_lt5` + `pop_m_10-14` + `pop_f_5-9` + `pop_f_lt5` +
       `pop_f_10-14` + `pop_m_5-9`
   ) / SUM(pop_total) AS kids_pop,
  
   SUM(
       `pop_m_15-17` + `pop_m_18-19` + `pop_m_20` + `pop_m_21` + `pop_m_22-24` +
       `pop_f_15-17` + `pop_f_18-19` + `pop_f_20` + `pop_f_21` + `pop_f_22-24`
   ) / SUM(pop_total) AS teenager_pop,
  
   SUM(
       `pop_m_25-29` + `pop_m_30-34` + `pop_m_35-39` + `pop_m_40-44` +
       `pop_f_25-29` + `pop_f_30-34` + `pop_f_35-39` + `pop_f_40-44`
   ) / SUM(pop_total) AS middleage_pop,
  
   SUM(
       `pop_f_45-49` + `pop_f_50-54` + `pop_f_55-59` +
       `pop_m_45-49` + `pop_m_50-54` + `pop_m_55-59` +
       `pop_f_60-61` + `pop_f_62-64` + `pop_m_60-61` + `pop_m_62-64`
   ) / SUM(pop_total) AS olderage_pop,
  
   SUM(
       `pop_m_65-66` + `pop_m_67-69` + `pop_m_70-74` +
       `pop_f_65-66` + `pop_f_67-69` + `pop_f_70-74`
   ) / SUM(pop_total) AS elderly_pop
FROM
   `elemental-leaf-436616-q5.safegraph.cbg_demographics` AS d
JOIN
   `elemental-leaf-436616-q5.safegraph.cbg_fips` AS f
ON
   SUBSTRING(d.cbg, 1, 2) = f.state_fips
   AND SUBSTRING(d.cbg, 3, 3) = f.county_fips
WHERE
   state = 'IL'
   AND county LIKE '%Cook%'
GROUP BY
   f.county,
   F.state;

SELECT
   SUM(
       `pop_m_lt5` + `pop_m_10-14` + `pop_f_5-9` + `pop_f_lt5` +
       `pop_f_10-14` + `pop_m_5-9`
   ) / SUM(pop_total) AS kids_pop,

   SUM(
       `pop_m_15-17` + `pop_m_18-19` + `pop_m_20` + `pop_m_21` +
       `pop_m_22-24` + `pop_f_15-17` + `pop_f_18-19` + `pop_f_20` +
       `pop_f_21` + `pop_f_22-24`
   ) / SUM(pop_total) AS teenager_pop,

   SUM(
       `pop_m_25-29` + `pop_m_30-34` + `pop_m_35-39` + `pop_m_40-44` +
       `pop_f_25-29` + `pop_f_30-34` + `pop_f_35-39` + `pop_f_40-44`
   ) / SUM(pop_total) AS middleage_pop,

   SUM(
       `pop_f_45-49` + `pop_f_50-54` + `pop_f_55-59` +
       `pop_m_45-49` + `pop_m_50-54` + `pop_m_55-59` +
       `pop_f_60-61` + `pop_f_62-64` + `pop_m_60-61` + `pop_m_62-64`
   ) / SUM(pop_total) AS olderage_pop,

   SUM(
       `pop_m_65-66` + `pop_m_67-69` + `pop_m_70-74` +
       `pop_f_65-66` + `pop_f_67-69` + `pop_f_70-74`
   ) / SUM(pop_total) AS elderly_pop

FROM
   `elemental-leaf-436616-q5.safegraph.cbg_demographics`;

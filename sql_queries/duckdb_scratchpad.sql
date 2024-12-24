-- Cheat sheet
-- data workflow
-- tools and techniques of working with data or new data set
-- mastering duckdb
INSTALL httpfs;
LOAD httpfs;

-- CREATE TABLE systems_data AS
SELECT * FROM read_csv('https://oedi-data-lake.s3.amazonaws.com/pvdaq/csv/systems.csv');
-- https://developer.nrel.gov/api/pvdaq/v3/data_file?api_key=DEMO_KEY&system_id=34&year=2019

CREATE TABLE IF NOT EXISTS systems (
    id INTEGER PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
);

CREATE TABLE IF NOT EXISTS readings (
    system_id INTEGER NOT NULL,
    read_on TIMESTAMP NOT NULL,
    power DECIMAL(10, 3) NOT NULL DEFAULT 0 CHECK (power >= 0),
    PRIMARY KEY (system_id, read_on),
    FOREIGN KEY (system_id) REFERENCES systems(id)
);

CREATE SEQUENCE IF NOT EXISTS prices_id
    INCREMENT BY 1 MINVALUE 10;

CREATE TABLE IF NOT EXISTS prices (
    id INTEGER PRIMARY KEY DEFAULT nextval('prices_id'),
    value DECIMAL(5, 2) NOT NULL,
    valid_from DATE NOT NULL,
    CONSTRAINT prices_uk UNIQUE (valid_from)
);

ALTER TABLE prices
ADD COLUMN IF NOT EXISTS valid_until DATE;
-- CAN ALSO DROP and RENAME

-- could create a duplicate table and limit 0 to copy schema
CREATE TABLE prices_duplicate AS 
SELECT * FROM prices LIMIT 0;

-- A view is a virtual table based on the result-set of an SQL statement.
-- a view of a query
-- stores thae statement that will behave as any other table or relation when being queried
-- if you find yourself running into performance issues, you might want to materialize the 
-- date of a view in a temp table using CTAS
-- Views are a great way to create an API inside your DB
-- API can server as adhoc queries and applications alike
CREATE OR REPLACE VIEW v_power_per_day AS
SELECT system_id,
        date_trunc('day', read_on) AS day,
        round(sum(power) / 4 / 1000, 2) AS kWh
FROM readings
GROUP BY system_id, day;


-- DESCRIBE statement - provides information about the structure of a table
DESCRIBE SELECT read_on, power FROM readings;

-- DESCRIB A constructed tuple
DESCRIBE VALUES (4711, '2023-05-28 11:00'::timestamp, 42);

--LOAD httpfs;
--INSTALL httpfs;


----------------------------------- DML 
-- INSERT AND DELETE
INSERT INTO prices
VALUES (1, 11.59, '2018-12-01', '2019-01-01')
ON CONFLICT DO NOTHING;

INSERT INTO prices(value, valid_from, valid_until)
VALUES (11.47, '2019-01-01', '2019-02-01'),
       (11.35, '2019-02-01', '2019-03-01'),
       (11.23, '2019-03-01', '2019-04-01'),
       (11.11, '2019-04-01', '2019-05-01'),
       (10.95, '2019-05-01', '2019-06-01')
ON CONFLICT (valid_from)
    DO UPDATE SET Value = excluded.value;


-- INSERT FROM other relations
--INSERT INTO prices(value, valid_from, valud_until)
-- SELECT * FROM 'prices.csv' src;


INSERT INTO systems(id, name)
SELECT DISTINCT system_id, system_public_name
FROM 'https://oedi-data-lake.s3.amazonaws.com/pvdaq/csv/systems.csv'
ORDER BY system_id ASC;


INSERT INTO readings(system_id, read_on, power)
SELECT SiteId, "Date-Time",
        CASE WHEN ac_power < 0 OR ac_power IS NULL THEN 0
        ELSE ac_power END
FROM read_csv(
    'https://developer.nrel.gov/api/pvdaq/v3/data_file?api_key=DEMO_KEY&system_id=34&year=2019'
);


SELECT *
FROM readings
WHERE date_trunc('day', read_on) = '2019-08-26'
AND power <> 0;

SELECT *
FROM (
    SELECT 'https://' || years.range || '.csv' AS v
    FROM range(2019, 2021) AS years
) urls, read_csv(urls.v);

-- Merging data
-- Do Update
INSERT INTO readings(system_id, read_on, power)
VALUES (10, '2023-06-05 13:00:00', 4000);

INSERT INTO readings(system_id, read_on, power)
VALUES (10, '2023-06-05 13:00:00', 3000)
ON CONFLICT(system_id, read_on)
DO UPDATE SET power = CASE
                    WHEN power = 0 THEN excluded.power
                    ELSE (power + excluded.power) / 2 END;

DELETE FROM readings WHERE date_part('minute', read_on) NOT IN (0,15,30,45);

-- ORDER OF OPERATIONS
/*
SELECT select_list
FROM tables
WHERE condition
GROUP BY groups
HAVING group_filter
ORDER BY order_expr
LIMIT n;
*/

-- JOIN clause
-- left and right
-- a join creates matching pairs of rows from both sides
-- JOIN USING instead of JOIN ON
-- joins are all based on a cartesian product in relational algebra
-- OR joining everything with everything else and then filtering out
-- Essentially all joins can be derived from CROSS JOIN
-- The inner join then filters on some confition, and a left or right outer join
-- adds a union to it, but that's all there is

-- Cartesian product is list of all ordered pairs that you can produce
-- from two sets of elements by combining each element from the first set 
-- with each element of the second set.
-- Size of a cartesian product is equal to the product of the size of 
-- each set


-- COPY TO - SELECT FROM - COPY TO
/*
duckdb -c "COPY (SELECT * FROM 'production.csv' JOIN 'consumption.csv'
USING (ts) JOIN 'export.csv' USING (ts) JOIN 'import.csv' USING (ts) )
TO '/dev/stdout' (HEADER)"
*/

-- WITH - CTE
WITH max_power AS (
    SELECT max(power) AS v FROM readings
)
SELECT max_power.v,
    read_on,
FROM max_power
JOIN readings ON power = max_power.v;


WITH max_power AS (
    SELECT max(power) AS v FROM readings
)
SELECT max_power.v,
    read_on,
FROM max_power
JOIN readings USING power = max_power.v;


WITH per_hour AS (
    SELECT system_id,
            date_trunc('hour', read_on) AS read_on,
            avg(power) / 1000 AS kWh
    FROM readings
    GROUP BY ALL
)
SELECT name,
       max(kWh),
       arg_max(read_on, kWh) AS 'Read on'
FROM per_hour
JOIN systems s ON s.id = per_hour.system_id
WHERE system_id = 34
GROUP by name;


CREATE TABLE IF NOT EXISTS src (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER,
    name VARCHAR(8)
);

INSERT INTO src (VALUES
    (1, null, 'root1'),
    (2,    1, 'child1a'),
    (3,    1, 'child2a'),
    (4,    3, 'child3a'),
    (5, null, 'root2'),
    (6,    5, 'child1b')
);

WITH RECURSIVE tree AS (
    SELECT id,
           id AS root_id,
           [name] AS path
    FROM src WHERE parent_id IS NULL
    UNION ALL
    SELECT src.id,
           root_id,
           list_append(tree.path, src.name) AS path
    FROM src
        JOIN tree ON (src.parent_id = tree.id)
)
SELECT path FROM tree;


CREATE TABLE IF NOT EXISTS departments (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER,
    name VARCHAR(50)
);

INSERT INTO departments (id, parent_id, name) VALUES
    (1, NULL, 'Head Office'),
    (2, 1, 'HR'),
    (3, 1, 'Finance'),
    (4, 2, 'Recruitment'),
    (5, 2, 'Employee Relations'),
    (6, 3, 'Accounts'),
    (7, 3, 'Payroll'),
    (8, NULL, 'Branch Office'),
    (9, 8, 'Sales'),
    (10, 9, 'Regional Sales'),
    (11, 8, 'Support');

WITH RECURSIVE tree AS (
    SELECT id,
           id AS root_id,
           [name] AS path
    FROM departments
    WHERE parent_id IS NULL
    UNION ALL
    SELECT 
        departments.id,
        root_id,
        list_append(tree.path, departments.name) AS path
    FROM departments
    JOIN tree ON (departments.parent_id = tree.id)
)
SELECT path FROM tree;


-- AGGREGATES
--  (https://duckdb.org/docs/sql/aggregates.html

-- DUCKDB-specific SQL extensions

-- SELECT * two-edged sword
-- instability of resulting tuples
-- pressure on db server or process
-- select * will cause more traffic on nonembedded dbs (duckdb is embedded)
-- select * might prevent index-only scan
-- index-only scan will occur when your query can use an index
-- only columns associated with that index will be returned to avoid another IO
-- index-only scan is desired in most cases because it's faster

-------------------------
-- EXCLUDE and REPLACE --
-------------------------

-- EXCLUDE: exclude columns from a SELECT statement
SELECT * EXCLUDE (id) FROM prices;

-- REPLACE: replace columns in a SELECT statement
SELECT * REPLACE (round(kWh)::int AS kWh)
FROM v_power_per_day;


-- columns can be used to project, filter, and aggregate one or more 
-- columns based on regular expression
SELECT COLUMNS('valid.*') FROM prices LIMIT 3;
SELECT max(COLUMNS('valid.*')) FROM prices;

-- you can simplify long predicates that have AND with COLUMNS

-- COLUMNS expression is a lambda function evaluatiing to true
-- when the column name is like the given text

-- the expression inside COLUMNS evaluates to true 
-- when column name is like the given text
FROM prices 
WHERE COLUMNS('valid.*') 
BETWEEN '2020-01-01' AND '2021-01-01'


INSERT INTO systems BY name
SELECT DISTINCT
    system_id as id,
    system_public_name AS NAME
FROM 'https://oedi-data-lake.s3.amazonaws.com/pvdaq/csv/systems.csv'
ON CONFLICT DO NOTHING;

-- introducing an alias to a column
-- aliases defined in SELECT list can be accessed
-- which is not possible in many other relational databases
-- can also be accessed in a HAVING clause
SELECT system_id > 10 AS is_not_system10,
        date_trunc('month', read_on) AS month,
        sum(power) / 1000 / 1000 AS power_per_month
FROM readings
WHERE is_not_system10 = TRUE
GROUP BY is_not_system10, month
HAVING power_per_month > 100;


-- GROUP BY 
-- GROUP BY ALL works if you have many nonaggregate columns
CREATE OR REPLACE VIEW v_power_per_day AS
SELECT system_id,
       date_trunc('day', read_on)         AS day,
       round(sum(power)) / 4 / 1000, 2)   AS kWh,
FROM readings
GROUP BY ALL;

-- ORDER BY ALL
-- FROM v_power_per_day ORDER BY ALL;


-- SAMPLING data
-- instead of using arbitrary limits, this provides a better and more
-- reliable overview -> sampling with a probabilistic 
-- below samples with a power column not equal to zero
-- specific rates apply system sampling including each vector by equal 
-- chance
-- https://duckdb.org/docs/sql/samples
SELECT power
FROM readings
WHERE power <> 0
USING SAMPLE 10%
    (bernoulli);

-- functions with option parameters
SELECT DISTINCT unnest(parameters)
FROM duckdb_functions()
WHERE function_name = 'read_json';

--------------------------------------------
-- Advanced Aggregation and Analysis of Data
--------------------------------------------
-- preparing, cleaning, and aggregating data while ingesting
-- window functions to create new aggregates over different partitions
-- understanding different types of subqueries
-- using CTEs
-- Applying filters to any aggregate


-- how DuckDB can be used to provide reports that would take a lot more code in an imperative language

-- Pre-aggregating data while ingesting

-- SELECT  * FROM read_csv('2020_10.csv') LIMIT 3;

-- function to deal with dates, times, and timestamps
-- time.bucket() function to bucketize the time
-- https://duckdb.org/docs/sql/functions/timestamp
-- assuming negative values can be 0 in this case (noted because book does so)
INSERT INTO readings(system_id, read_on, power)
SELECT any_value(SiteId),
        time_bucket(
                INTERVAL '15 Minutes',
                CAST("Date-Time" AS timestamp)
        ) AS read_on,
        avg(
            CASE
                WHEN ac_power < 0 OR ac_power IS NULL THEN 0
                ELSE ac_power END
        ) AS power
FROM
    read_csv(
        'https://developer.nrel.gov/api/pvdaq/v3/data_file?api_key=DEMO_KEY&system_id=34&year=2019'
    )
GROUP BY read_on
ORDER BY read_on;

--- Summarizing data
-- knowing characteristics of a new dataset before going into in-depth analysis
SUMMARIZE SELECT read_on, power FROM readings WHERE system_id = 1200;

-- SUMMARIZE work directly on tables, query results, CSV, and parquet
-- average of total power by systems you manage

-- subqueries
-- avg and sum -> not possible: aggregate functions cannot be nested
SELECT AVG(sum_per_system)
FROM (
    SELECT sum(kWh) AS sum_per_system
    FROM v_power_per_day
    GROUP BY system_id
);

-- Uncorrelated subquery 
-- a query inside another one and it operates as if the outer 
-- query executed on the results of the inner query not the other

SELECT read_on, power
FROM readings
WHERE power = (SELECT max(power) FROM readings);
-- This is different from the first one in that it only returns a single,
-- scalar value. A scalar uncorrelated subquery


--- correlated, scalar subquery
-- inner quert is related to the other query in that the db
-- must evaluate it for every row of the outer query
SELECT system_id, read_on, power
FROM readings r1
WHERE power = (
    SELECT
        max(power)
    FROM readings r2
    WHERE r2.system_id = r1.system_id
);

-- when used as expressions, subqueries may be rewritten as joins
-- with computation of nested aggregates being the exepction

-- uncorrelated subquery join with outer table

-- when used as expressions, subqueries may be rewritten as joins
SELECT r1.system_id, read_on, power
FROM readings r1
JOIN (
    SELECT r2.system_id, max(power) AS value
    FROM readings r2
    GROUP BY ALL
) AS max_power ON (
    max_power.system_id = r1.system_id AND
    max_power.value = r1.power
)
ORDER BY ALL;

/*
 DuckDB, on the other hand, uses a subquery
decorrelation optimizer that always makes subqueries independent of outer queries,
thus allowing users to freely use subqueries to create expressive queries without hav-
ing to worry about manually rewriting subqueries into joins. It is not always possible to
manually decorrelate certain subqueries by rewriting the SQL. Internally, DuckDB
uses special types of joins that will decorrelate all subqueries. In fact, DuckDB does
not have support for executing subqueries that are not decorrelated.
This is a positive for you because it allows you to focus on the readability and
expressiveness of your queries and the business problem you are trying to solve.
Indeed, DuckDB allows you to spend all your time focusing on the bigger picture—
you don’t need to worry about what type of subquery you use at all.
*/

-- EXISTS
SELECT * FROM VALUES (7), (11) s(v)
WHERE EXISTS (SELECT * FROM range(10) WHERE range = v);

-- using various aggregates to check if the imports make sense
SELECT count(*),
        min(power) AS min_W, MAX(power) AS max_W,
        round(sum(power) / 4 / 1000, 2) AS kWh
FROM readings;


-- a plain GROUP BY with essentially one of the set of GROUPING KEYS()
SELECT year(read_on) AS year,
    system_id,
    count(*),
    round(sum(power) / 4 / 1000, 2) AS kWh
FROM readings
GROUP BY year, system_id
ORDER BY year, system_id;

-- GROUPING SETS
SELECT year(read_on) AS year,
    system_id,
    count(*),
    round(sum(power) / 4 / 1000, 2) AS kWh
FROM readings
GROUP BY GROUPING SETS ((year, system_id, year), ())
ORDER BY year NULLS FIRST, system_id NULLS FIRST;

-- GROUP BY GROUPING SETS ((system_id, year), year, ())
-- system_id, year
-- year
-- () empty bucket NULL VALUES provided
SELECT year(read_on) AS year,
    system_id,
    count(*),
    round(sum(power) / 4 / 1000, 2) as kWh
FROM readings
GROUP BY ROLLUP (year, system_id)
ORDER BY YEAR NULLS FIRST, system_id NULLS FIRST;


SELECT year(read_on) AS year,
    system_id,
    count(*),
    round(sum(power) / 4 / 1000, 2) as kWh
FROM readings
GROUP BY CUBE (year, system_id)
ORDER BY year NULLS FIRST, system_id NULLS FIRST;


-- Window Functions

-- Ranking
-- computing independent aggregates per window
-- computing running totals per window
-- computing changes by accessing preceding or following rows via lag or lead

WITH ranked_readings AS (
    SELECT *,
        dense_rank()
        OVER (
            ORDER BY POWER DESC) AS rnk
    FROM readings
)
SELECT *
FROM ranked_readings
WHERE rnk <= 3;

-- Applying a partition to a window
-- PARTITION clause, the entire relation is treated as a single partition
-- 
WITH ranked_readings AS (
    SELECT *,
        dense_rank()
        OVER (
            PARTITION BY system_id
            ORDER BY POWER DESC
        ) AS rnk
    FROM readings
)
SELECT * FROM ranked_readings WHERE rnk <= 2
ORDER BY system_id, rnk ASC;

-- compute an aggregate over a partition
SELECT *,
    avg(kWh)
        OVER (
            PARTITION BY system_id
        ) AS average_per_system
FROM v_power_per_day;


-- Framing --
-- what is the seven-day moving average of enery producted system wide?
-- TO DO THIS:
-- aggregate readings per 15-minute interval into days (grouping + summing)
-- partition by day and systems
-- create frams of seven days

-- Framing specifies a set of rows relative to each other where func is evaluated
SELECT system_id,
    day,
    kWh,
    avg(kWh) OVER (
        PARTITION BY system_id
        ORDER BY day ASC
        RANGE BETWEEN INTERVAL 3 Days PRECEDING
        AND INTERVAL 3 Days FOLLOWING
    ) AS "kWh 7-day moving average"
FROM v_power_per_day
ORDER BY system_id, day;

-- Using a named window with a complex order and partition
-- referencing the window defined after FROM clause
-- use a named window when you're querying for several aggregates
SELECT system_id,
    day,
    min(kWh) OVER seven_days AS "7-day min",
    quantile(kWh, [0.25, 0.5, 0.75])
        OVER seven_days AS "kWh 7-day quartile",
    max(kWh) OVER seven_days AS "7-day max",
FROM v_power_per_day
WINDOW
    seven_days AS (
        PARTITION BY system_id, month(day)
        ORDER BY day ASC
        RANGE BETWEEN INTERVAL 3 Days PRECEDING
        AND INTERVAL 3 Days FOLLOWING
    )
ORDER BY system_id, day;


-- Accessing preceding or following rows in a partition
-- using lag - computing difference of price in current row and previous row
SELECT valid_from,
        value,
        lag(value)
            OVER validity AS "Previous value",
        value - lag(value, 1, value)
        OVER validity AS "Change"
FROM prices
WHERE date_part('year', valid_from) = 2019
WINDOW validity AS (ORDER BY valid_from)
ORDER BY valid_from;

-- Computing the aggregate OVER a window
WITH changes AS (
    SELECT value - lag(value, 1, value) OVER(ORDER BY valid_from) AS v
    FROM prices
    WHERE date_part('year', valid_from) = 2019
    ORDER BY valid_from
)
SELECT sum(changes.v) AS total_change
FROM changes;

-- Conditions and filtering outside the WHERE clause
-- computed aggreagetes nor the result of the window func can be filtered
-- via the WHERE clause

-- Such filtering is necessary to answer questions like:

-- selection of groups that have an aggregated value exceeds value x -> HAVING
-- selection of data that exceeds a certain value in range of days -> QUALIFY
-- might need to filter out values to keep them from entering aggregate function -> FILTER

-- Filtering clauses and where to use them

-- HAVING  -> after GROUP BY 
    --> Filter rows based on aggregates computed for a group
-- QUALIFY -> After FROM clause regerring to any window expression - 
    --> Filter rows based on anything computed in that window
-- FILTER  ->  After any aggregate function
    --> Filters the values passed to the aggregate


-- Using the HAVING clause
-- give me all days with production exceeding 900 kWh
-- WHERE clause cannot contain aggregates

SELECT system_id,
    date_trunc('day', read_on) AS day,
    round(sum(power) / 4 / 1000, 2) AS kWh,
FROM readings
GROUP BY ALL
HAVING kWh >= 900
ORDER BY kWh DESC;

-- Using the QUALIFY clause
-- want to return rows where the result of a window function matches a filter
-- can't use HAVING because windows get evaluated before an aggregation
-- Qualify let's you filter on the results of a window function
SELECT dense_rank() OVER (ORDER BY power DESC) AS rnk
FROM readings
QUALIFY rnk <= 3;

SELECT system_id,
    day,
    avg(kWh) OVER (
        PARTITION BY system_id
        ORDER BY day ASC
        RANGE BETWEEN INTERVAL 3 Days PRECEDING
                  AND INTERVAL 3 Day FOLLOWING
    ) AS "kWh 7-day moving average"
FROM v_power_per_day
QUALIFY "kWh 7-day moving average" >= 200
ORDER BY system_id, day;

-- Using the FILTER clause
-- you want to compute an aggregate, an average, or a count of values, 
-- and you realize that some rows you don't want to include.

INSERT INTO readings(system_id, read_on, power)
SELECT any_value(SiteID),
        time_bucket(
            INTERVAL '15 Minutes',
            CAST("Date-Time" AS timestamp)
        ) AS read_on,
        COALESCE(avg(ac_power)
            FILTER (
                ac_power IS NOT NULL AND
                ac_power >= 0
            ), 0)
FROM
    read_csv_auto(
        'https://developer.nrel.gov/api/pvdaq/v3/' ||
        'data_file?api_key=DEMO_KEY&system_id=10&year=2019'
    )
GROUP BY read_on
ORDER BY read_on
ON CONFLICT DO NOTHING;



-- PIVOT statement
-- I want a report of the energy production per system and year
-- the years as columns

-- this will appear in rows NOT columns
SELECT system_id, year(day), sum(kWh) FROM v_power_per_day GROUP BY ALL ORDER
BY system_id

-- hardcoding the years
SELECT system_id
    ,sum(power) FILTER (WHERE year(day) = 2019) AS 'kWh in 2019',
    ,sum(power) FILTER (WHERE year(day) = 2020) AS 'kWh in 2020',
FROM v_power_per_day
GROUP BY system_id;

-- PIVOT statement
PIVOT (FROM v_power_per_day)
ON year(day)
USING sum(kWh);

-- PIVOT statement with 
PIVOT (
FROM v_power_per_day WHERE day BETWEEN '2020-05-30' AND '2020-06-02'
)
ON DAY USING first(kWh);


-- ASOF JOIN

-- inner join
WITH prices AS (
    SELECT range AS valid_at,
        random()*10 AS price
    FROM range(
        '2023-01-01 01:00:00'::timestamp,
        '2023-01-01 02:00:00'::timestamp, INTERVAL '15 minutes'
    )
),
sales AS (
    SELECT range AS sold_at,
        random()*10 AS num
    FROM range(
        '2023-01-01 01:00:00'::timestamp,
        '2023-01-01 02:00:00'::timestamp, INTERVAL '5 minutes')
)
SELECT sold_at, valid_at AS 'with_price_at', round(num * price, 2) AS price
FROM sales
JOIN prices ON prices.valid_at = sales.sold_at;


-- ASOF JOIN
-- joins on the inequality or "good enough" value for the gaps
-- where the join columns are not exactly equalty
-- provide an inequality operator -> prices.valid_at <= sales.sold_at
WITH prices AS (
    SELECT range AS valid_at,
        random()*10 AS price
    FROM range(
        '2023-01-01 01:00:00'::timestamp,
        '2023-01-01 02:00:00'::timestamp, INTERVAL '15 minutes'
        )
    ),
    sales AS (
        SELECT range AS sold_at
            ,random()*10 AS num
        FROM range(
            '2023-01-01 01:00:00'::timestamp,
            '2023-01-01 02:00:00'::timestamp, INTERVAL '5 minutes')
        )
    SELECT
        sold_at,
        valid_at AS 'with_price_at',
        round(num * price, 2) AS price
    FROM sales
    ASOF JOIN prices
        ON prices.valid_at <= sales.sold_at;

-- ASOF join defined as p <= v so that each p item will be joined together
-- with 3 v items that have the same or higher timestamp
-- ASOF JOIN will help with a lot of time series data
SELECT power.day,
    power.kWh,
    prices.value AS 'ct/kWh',
    round(sum(prices.value * power.kWh)
        OVER (
            ORDER BY power.day ASC) / 100, 2)
            AS 'Accumulated earnings in EUR'
FROM v_power_per_day power
    ASOF JOIN prices
    ON prices.valid_from <= power.day
WHERE system_id = 34
ORDER BY day;

WITH full_year AS (
    SELECT generate_series AS day
    FROM generate_series(
        '2020-01-01'::date,
        '2020-12-31'::date, INTERVAL '1 day'
    )
)
SELECT strftime(full_year.day, '%Y-%m') AS month,
    avg(kWh) FILTER (kWh IS NOT NULL) AS actual
FROM full_year
LEFT OUTER JOIN v_power_per_day per_day
    ON per_day.day = full_year.day
GROUP BY ALL ORDER BY month;

-- project past data into the future
WITH full_year AS (
    SELECT generate_series AS day
    FROM generate_series(
        '2020-01-01'::date,
        '2020-12-31'::date, INTERVAL '1 day')
)
SELECT strftime(full_year.day, '%Y-%m') AS month,
    round(avg(present.kWh) FILTER (present.kWh IS NOT NULL),3) AS actual,
    round(avg(past.kWh) FILTER (past.kWh IS NOT NULL), 3) AS forecast
FROM full_year
LEFT OUTER JOIN v_power_per_day present
    ON present.day = full_year.day
LEFT OUTER JOIN v_power_per_day past
    ON past.day = full_year.day - INTERVAL '1 year'
GROUP BY ALL ORDER BY month;


-- USING lateral JOINs
-- you want to evaluate precisely the inner query for each value of 
-- an outer query
-- LATERAL JOIN
INSTALL json;
LOAD json;


WITH days AS (
    SELECT generate_series AS value FROM generate_series(7)
    ),
    hours AS (
        SELECT unnest([8, 13, 18]) AS value
    ),
    indexes AS (
        SELECT days.value * 24 + hours.value AS i
        FROM days, hours
    )
    SELECT date_trunc('day', now()) - INTERVAL '7 days' + INTERVAL (indexes.i || ' hours') AS ts,
            ghi.v AS 'GHI in W/m^2'
    FROM indexes,
    LATERAL (
        SELECT hourly.shortwave_radiation_instant[i+1] AS v
        FROM 'code/ch04/ghi_past_and_future.json'
    ) AS ghi
    ORDER BY ts;

-- Comparing the ASOF JOIN to a LATERAL JOIN
SELECT power.day, power.kWh,
        prices.value AS 'EUR/kWh'
FROM v_power_per_day power,
    LATERAL (
        SELECT *
        FROM prices
        WHERE prices.valid_from <= power.day
        ORDER BY valid_from DESC limit 1
    ) AS prices
WHERE system_id = 34
ORDER BY day;

-- for time-series-related computations with DuckDB, we would most
-- certainly use the ASOF JOIN. Lateral is attractive when considering portability
-- There are more db's supporting lateral than ASOF
-- USE LATERAL IN scenarios in which you want to fan out a dataset
-- to produce more rows

/* SUMMARY of ADVANCE AGGREGATION AND ANALYSIS of DATA

 The SQL standard has evolved greatly since its last major revision in 1992
(SQL-92). DuckDB supports a broad range of modern SQLs, including CTEs
(SQL:1999), window functions (SQL:2003), list aggregations (SQL:2016), and
more.
 Grouping sets allow the computation of aggregates over multiple groups, per-
forming a drill down into different levels of detail; ROLLUP and CUBE can be used
to generate subgroups or combinations of grouping keys.
 DuckDB fully supports window functions, including named windows and
ranges, enabling use cases such as computing running totals, ranks, and more.
 All aggregate functions, including statistic computations and interpolations, are
optimized for usage in a windowed context.
 HAVING and QUALIFY can be used to select aggregates and windows after they have
been computed; FILTER prevents unwanted data from going into aggregates.
 DuckDB includes ASOF JOIN, which is necessary in use cases involving time-
series data.
 DuckDB also supports LATERAL joins that help fan out data and can emulate
loops, to an extent.
 Results can be pivoted, either with a simplified, DuckDB-specific PIVOT state-
ment or a more static, standard SQL approach.
*/

-- Chapter 5 exploring data without persistence

-- csv, json, and parquet files
-- you can work with data stored in a remote location like s3
-- postgres -> binary transfer mode of a Postgres client-server protocol 

-- inferring file type and schema
-- auto-inferring file types-With DUCkDB you can query the content of supported
-- file formats, such as CSV, JSON, and Parquet with out of the box functionality

-- duckdb determines filetype and calls appropriate function
-- that knows how to process the data format to read the file

-- SEE import exports
-- arguments for these as well

-- CSV Parsing 
/*
    Boolean
    bigint
    double
    time
    date
    timestamp
    varchar
*/

-- find parameters for function
SELECT distinct function_name,
unnest(parameters) as parameter
FROM duckdb_functions()
WHERE function_name = 'read_csv'
ORDER BY parameter;

-- Shredding Nested JSON

-- DESCRIBE
DESCRIBE FROM '../sample_data/2024_10_29_ws_game_4_pregame_pbp.json';


CREATE TABLE game_data AS
SELECT *
FROM read_json('./sample_data/2024_10_29_ws_game_4_pregame_pbp.json');

CREATE TABLE post_game_data AS
SELECT *
FROM read_json('./sample_data/2024_10_29_ws_game_4_postgame_pbp.json');


WITH unnested_plays AS (
    SELECT unnest(livedata.plays.allplays).result.event AS all_plays
    FROM post_game_data
)

SELECT all_plays
FROM unnested_plays;

CREATE VIEW plays AS 
  FROM (
      FROM '../sample_data/2024_10_29_ws_game_4_postgame_pbp.json'
      SELECT unnest(livedata.plays.allplays).result.event AS all_plays
  );

DESCRIBE plays;

-- 
CREATE OR REPLACE VIEW shots AS
FROM (
FROM 'xg/shots_*.json'
SELECT unnest(h) AS row
UNION ALL
FROM 'xg/shots_*.json'
SELECT unnest(a) AS row
)
SELECT CAST(ROW AS STRUCT(
id BIGINT, "minute" BIGINT, result VARCHAR,
X DOUBLE, Y DOUBLE, xG DOUBLE,
player VARCHAR, h_a VARCHAR, player_id BIGINT,
situation VARCHAR, season BIGINT, shotType VARCHAR,
match_id BIGINT, h_team VARCHAR, a_team VARCHAR,
h_goals BIGINT, a_goals BIGINT, date TIMESTAMP,
player_assisted VARCHAR, lastAction VARCHAR)) AS row;

-- after creating a schema, you can describe it
DESCRIBE shots;
.mode duckbox

-- Translating CSV to Parquet
SELECT filename, count(*)
FROM read_csv('atp/atp_rankings_*.csv',
filename=true
)
GROUP BY ALL
GROUP BY ALL;


-- duckdb -s "SET memory_limit='100MB';
COPY (
    SELECT * EXCLUDE (player, wikidata_id)
        REPLACE (
        cast(strptime(ranking_date::VARCHAR, '%Y%m%d') AS DATE)
            AS ranking_date,
        cast(strptime(dob, '%Y%m%d') AS DATE) AS dob
        )
    FROM 'atp/atp_rankings_*.csv' rankings
    JOIN (
        FROM 'atp/atp_players.csv'
    ) players ON players.player_id = rankings.player
)
TO 'atp_rankings.parquet'
(FORMAT PARQUET, CODEC 'SNAPPY', ROW_GROUP_SIZE 100000);


DESCRIBE FROM 'atp/atp_rankings.parquet';
DESCRIBE FROM parquet_schema('atp/atp_rankings.parquet');

-- analyzing parquet files on the fly

from 'atp/atp_rankings.parquet'
select max(rank), max(points), max(player_id), max(height);

Querying other databases

INSTALL postgres;
LOAD postgres;


INSTALL sqlite;
LOAD sqlite;

ATTACH 'database.sqlite' AS fifa (TYPE sqlite);
USE fifa;

-- datatype bugs or mismatch
USE memory;
DETACH fifa;

SET GLOBAL sqlite_all_varchar=true;

USE main;
CREATE OR REPLACE VIEW Player AS
FROM sqlite_scan('database.sqlite', 'Player')
SELECT * REPLACE (
id :: BIGINT AS id,
player_api_id :: BIGINT AS player_api_id,
player_fifa_api_id :: BIGINT AS player_fifa_api_id,
birthday :: DATE AS birthday,
height :: FLOAT AS height,
weight :: FLOAT AS weight
);

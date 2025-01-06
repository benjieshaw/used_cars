CREATE TABLE used_cars (
brand varchar(50),
base_model varchar(50),
"trim" varchar(55),
model_year smallint,
mileage bigint,
engine_type varchar(50),
fuel_type varchar(50),
horsepower smallint,
engine_size numeric(5,2),
ext_col varchar(10),
transmission_type varchar(25),
number_of_speeds varchar(10),
dual_shift_mode varchar(10),
int_col varchar(25),
accident_damage_reported varchar(10),
clean_title varchar(10),
price bigint
);

--Import table info
COPY used_cars(brand, base_model, "trim", model_year, mileage, engine_type, fuel_type, horsepower, engine_size,
	ext_col, transmission_type, number_of_speeds, dual_shift_mode, int_col, accident_damage_reported, 
	clean_title, price)
FROM '/Users/Shared/used_cars_cleaned.csv'
DELIMITER ','
CSV HEADER;

--Find all cars manufactured after 2015
SELECT * FROM used_cars
WHERE model_year > 2015;

--List cars in descending order of price
SELECT * FROM used_cars
ORDER BY price desc;

--Count number of each brand in dataset
SELECT brand, COUNT(brand) AS total_number FROM used_cars
GROUP BY brand
ORDER BY total_number desc;

--Calculate the average price of cars by fuel type
SELECT fuel_type, ROUND(AVG(price), 2) AS avg_price FROM used_cars
GROUP BY fuel_type
ORDER BY avg_price desc;

--Mocked JOIN
--Assume there's a manufacturers table containing brand and country. 
--Retrieve car details along with the manufacturing country.
SELECT c.brand, c. base_model, c.trim, c.price, m.country FROM used_cars.c
JOIN manufacturers.m ON c.brand=m.brand

--Find avg price of cars. Return only cars listed above the average
WITH avg_price AS (
	SELECT ROUND(AVG(price), 2) AS avg_price FROM used_cars)

SELECT * FROM used_cars
WHERE price > (SELECT avg_price FROM avg_price)

--Rank cars by price within each brand
SELECT brand, base_model, "trim", price, 
	RANK() OVER(PARTITION BY brand ORDER BY price DESC) AS brand_rank
FROM used_cars;

--Determine rank of cars based on their mileage within the same model year
SELECT model_year, base_model, mileage, 
	DENSE_RANK() OVER(PARTITION BY model_year ORDER BY mileage ASC) as mileage_rank
FROM used_cars;

--Find the most expensive car's details for each brand
SELECT * FROM used_cars u
WHERE price = (SELECT MAX(price) FROM used_cars WHERE brand = u.brand);

--Categorize cars into price ranges
SELECT brand, base_model, price,
	CASE
		WHEN price < 10000 THEN 'budget'
		WHEN price BETWEEN 10000 AND 30000 THEN 'mid-range'
		ELSE 'luxury'
	END AS price_category
FROM used_cars;

--Extract car models where the trim includes the word 'sport'
SELECT * FROM used_cars
WHERE "trim" LIKE '%Sport';

--Compute the average price per brand and show the percentage 
--difference of each car's price from it's brand average
SELECT brand, base_model, price,
      	ROUND(AVG(price) OVER (PARTITION BY brand), 2) AS avg_brand_price,
       ROUND((price - AVG(price) OVER (PARTITION BY brand)) / AVG(price) OVER (PARTITION BY brand) * 100, 2) AS price_difference
FROM used_cars
ORDER BY price_difference DESC;

--Find brands that have more than 5 cars priced over $30000
WITH expensive_cars AS (
    SELECT brand, COUNT(*) AS count_above_30k
    FROM used_cars
    WHERE price > 30000
    GROUP BY brand
)
SELECT brand FROM expensive_cars WHERE count_above_30k > 5;

--Search for cars that match keywords "Hybrid" and "Sport"
SELECT * FROM used_cars
WHERE trim LIKE '%Hybrid%' OR trim LIKE '%Sport%';
/* ROCKBUSTER STEALTH ANALYSIS - SQL QUERIES */

/* 1.1. Film Numerical Variables Analysis */
SELECT 
    COUNT(*) AS count_rows,
    MIN(release_year) AS earliest_released_year, 
    MAX(release_year) AS latest_released_year, 
    AVG(release_year) AS average_released_year, 
    COUNT(release_year) AS count_released_year, 
    MIN(rental_duration) AS minimum_rental_duration, 
    MAX(rental_duration) AS maximum_rental_duration, 
    AVG(rental_duration) AS average_rental_duration, 
    COUNT(rental_duration) AS count_rental_duration
FROM film;

/* 1.2. Film & Customer Non-Numerical Analysis */
-- Film Rating Mode (Most Frequent Rating)
SELECT MODE() WITHIN GROUP (ORDER BY rating) AS modal_rating FROM film;

-- Film Language Mode (Most Frequent Language ID)
SELECT MODE() WITHIN GROUP (ORDER BY language_id) AS modal_language_id FROM film;

-- Customer Store ID Mode (Most Frequent Store ID)
SELECT MODE() WITHIN GROUP (ORDER BY store_id) AS modal_store_id FROM customer;


/* 2. Top 10 Countries by Customer Count */

SELECT D.country,
COUNT(A.customer_id) AS customer_count
FROM customer A
INNER JOIN address B ON A.address_id = B.address_id INNER JOIN city C ON B.city_id = C.city_id
INNER JOIN country D ON C.country_ID = D.country_ID GROUP BY D.country
ORDER BY customer_count DESC
LIMIT 10;

/* 3. Top 10 Cities by Customer Count in Selected Countries */

SELECT C.city, D.country,
COUNT(A.customer_id) AS customer_count
FROM customer A
INNER JOIN address B ON A.address_id = B.address_id
INNER JOIN city C ON B.city_id = C.city_id
INNER JOIN country D ON C.country_ID = D.country_ID
WHERE D.country IN ('India', 'China', 'United States', 'Japan', 'Mexico', 'Brazil', 'Russian Federation', 'Philippines', 'Turkey', 'Indonesia')
GROUP BY C.city, D.country
ORDER BY customer_count DESC
LIMIT 10;

/* 4. Top 5 Customers by Total Payments in the Top 10 Cities */

SELECT A.customer_id, A.first_name,
A.last_name,
D.country,
C.city,
SUM(E.amount) AS total_amount_paid
FROM customer A
INNER JOIN address B ON A.address_id = B.address_id INNER JOIN city C ON B.city_id = C.city_id
INNER JOIN country D ON C.country_ID = D.country_ID INNER JOIN payment E ON A.customer_id = E.customer_id WHERE C.city IN (
SELECT C.city
FROM customer A
INNER JOIN address B ON A.address_id = B.address_id
INNER JOIN city C ON B.city_id = C.city_id
INNER JOIN country D ON C.country_ID = D.country_ID
WHERE D.country IN ('India', 'China', 'United States', 'Japan', 'Mexico', 'Brazil', 'Russian Federation',
'Philippines', 'Turkey', 'Indonesia')
GROUP BY C.city
ORDER BY COUNT(A.customer_id) DESC LIMIT 10
)
GROUP BY A.customer_id, A.first_name, A.last_name, D.country, C.city ORDER BY total_amount_paid DESC
LIMIT 5;

/* 5. Average Payment of Top Customers */

SELECT AVG(total_amount_paid) AS average_amount_paid FROM (
SELECT A.customer_id, A.first_name,
A.last_name,
D.country,
C.city,
SUM(E.amount) AS total_amount_paid
FROM customer A
JOIN address B ON A.address_id = B.address_id JOIN city C ON B.city_id = C.city_id
JOIN country D ON C.country_ID = D.country_ID JOIN payment E ON A.customer_id = E.customer_id WHERE C.city IN (
SELECT C.city
FROM customer A
JOIN address B ON A.address_id = B.address_id
JOIN city C ON B.city_id = C.city_id
JOIN country D ON C.country_ID = D.country_ID
WHERE D.country IN ('India', 'China', 'United States', 'Japan', 'Mexico', 'Brazil', 'Russian Federation',
'Philippines', 'Turkey', 'Indonesia') GROUP BY C.city
ORDER BY COUNT(A.customer_id) DESC
LIMIT 5 )
GROUP BY A.customer_id, A.first_name, A.last_name, D.country, C.city ) AS total_amount_paid;

/* 6. Customer Count vs. Top Customers Per Country */

SELECT D.country,
COUNT(DISTINCT A.customer_id) AS all_customer_count,
COUNT(DISTINCT top_5.customer_id) AS top_customer_count FROM customer A
JOIN address B ON A.address_id = B.address_id
JOIN city C ON B.city_id = C.city_id
JOIN country D ON C.country_ID = D.country_ID LEFT JOIN (
SELECT A.customer_id, D.country
FROM customer A
JOIN address B ON A.address_id = B.address_id JOIN city C ON B.city_id = C.city_id
JOIN country D ON C.country_ID = D.country_ID JOIN payment E ON A.customer_id = E.customer_id GROUP BY A.customer_id, D.country
ORDER BY SUM(E.amount) DESC
LIMIT 5
) AS top_5 ON D.country = top_5.country GROUP BY D.country;

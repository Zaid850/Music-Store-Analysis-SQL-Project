--Senior most employee id
SELECT employee_id,
       first_name || ' ' || last_name AS employee,
       title, levels
FROM employee
ORDER BY COALESCE(NULLIF(regexp_replace(levels,'[^0-9]','','g'),''), '0')::int DESC,
         title DESC
LIMIT 1;


--Countries with most invoices
SELECT billing_country, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

--Top 3 invoice totals
SELECT DISTINCT total
FROM invoice
ORDER BY total DESC
LIMIT 3;


--City with the highest total revenue
SELECT billing_city AS city,
       ROUND(SUM(total),2) AS revenue
FROM invoice
GROUP BY billing_city
ORDER BY revenue DESC
LIMIT 1;

--best customer highest spend
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer,
       ROUND(SUM(i.total),2) AS total_spent
FROM customer c
JOIN invoice  i ON i.customer_id = c.customer_id
GROUP BY c.customer_id, customer
ORDER BY total_spent DESC
LIMIT 1;

--Emails of Rock listeners (alphabetical by email)
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice       i  ON i.customer_id = c.customer_id
JOIN invoice_line  il ON il.invoice_id = i.invoice_id
JOIN track         t  ON t.track_id = il.track_id
JOIN genre         g  ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;


--Top 10 artists by number of Rock tracks
SELECT a.name AS artist,
       COUNT(*) AS rock_track_count
FROM artist a
JOIN album  al ON al.artist_id = a.artist_id
JOIN track  t  ON t.album_id = al.album_id
JOIN genre  g  ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.name
ORDER BY rock_track_count DESC
LIMIT 10;


--Tracks longer than average (by milliseconds)
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


--Amount spent by each customer on each artist
SELECT
  c.first_name || ' ' || c.last_name AS customer,
  a.name AS artist,
  ROUND(SUM(il.unit_price * il.quantity),2) AS total_spent
FROM invoice       i
JOIN customer      c  ON c.customer_id = i.customer_id
JOIN invoice_line  il ON il.invoice_id = i.invoice_id
JOIN track         t  ON t.track_id = il.track_id
JOIN album         al ON al.album_id = t.album_id
JOIN artist        a  ON a.artist_id = al.artist_id
GROUP BY customer, a.name
ORDER BY total_spent DESC;


--Most popular genre per country (by number of purchases); include ties
WITH genre_counts AS (
  SELECT
    i.billing_country AS country,
    g.name            AS genre,
    COUNT(*)          AS purchases
  FROM invoice i
  JOIN invoice_line il ON il.invoice_id = i.invoice_id
  JOIN track        t  ON t.track_id = il.track_id
  JOIN genre        g  ON g.genre_id = t.genre_id
  GROUP BY i.billing_country, g.name
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY country ORDER BY purchases DESC) AS rnk
  FROM genre_counts
)
SELECT country, genre, purchases
FROM ranked
WHERE rnk = 1
ORDER BY country;


--Top-spending customer per country; include ties
WITH spend AS (
  SELECT
    c.country,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer,
    ROUND(SUM(i.total),2) AS total_spent
  FROM customer c
  JOIN invoice  i ON i.customer_id = c.customer_id
  GROUP BY c.country, c.customer_id, customer
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rnk
  FROM spend
)
SELECT country, customer, total_spent
FROM ranked
WHERE rnk = 1
ORDER BY country, customer;

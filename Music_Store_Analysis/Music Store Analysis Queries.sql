CREATE DATABASE Music_Store;

-- 1. Who is the senior most employee based on job title ?

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most invoices?

SELECT 
    billing_country, COUNT(invoice_id) AS CNT
FROM
    invoice
GROUP BY billing_country
ORDER BY CNT DESC;

-- 3. What are the top 3 values of total invoices?

SELECT 
    TOTAL
FROM
    invoice
ORDER BY TOTAL DESC
LIMIT 3;

-- 4. Which city has the best customers? we would like to throw a promostional music festival in the city we made the most money.
--    write a query that returns one city that has the highest sum of invoice totals. Return both city name, & sum of invoices totals

SELECT 
    billing_city, SUM(total) AS total_invoices
FROM
    invoice
GROUP BY billing_city
ORDER BY total_invoices DESC
LIMIT 1;

-- 5. Who is the best customer? the customer who spent most money will be declared the best customer. 
--    Write the query the returns the person who has the spent the most money

SELECT 
    C.customer_id,
    CONCAT(C.first_name, ' ', C.Last_name) AS FULL_NAME,
    SUM(I.total) AS Total
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY C.customer_id , FULL_NAME
ORDER BY total DESC
LIMIT 1;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 1. Write a query to return the email , fname, lname, & genre of all ROCK MUSIC listeners. 
--    Return your list ordered alpha by email starting with "A"


SELECT DISTINCT
    email, first_name, Last_name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            Track
                JOIN
            genre ON Track.genre_id = Genre.genre_id
        WHERE
            genre.name = 'Rock')
ORDER BY email;

-- 2. Lets invite the artists who have written the most rock music in our dataset.
--    write a query that returns the artist name and total track count of the top 10 rock bands

SELECT 
    artist.artist_id,
    artist.name,
    COUNT(artist.artist_id) AS No_of_songs
FROM
    Track
        JOIN
    album ON album.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY No_of_songs DESC
LIMIT 10;

-- Another Approach :

SELECT 
    artist.artist_id, artist.name, COUNT(*) AS No_of_songs
FROM
    artist
        JOIN
    album ON album.artist_id = artist.artist_id
        JOIN
    track ON track.album_id = album.album_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
GROUP BY artist.artist_id , artist.name
ORDER BY No_of_songs DESC
LIMIT 10;

-- 3. Return all the track names that have a song length longer than avg song length
--    Return the name and millisecond for each track
--    order by song length with the longest songs listed first

SELECT 
    name, milliseconds
FROM
    Track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS Avg_song_length
        FROM
            Track)
ORDER BY milliseconds DESC;

-- ----------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------

-- 1 . Find how much amount spent by each customer on artists?
--     write a query to return customer name, artist name and total spent.

SELECT 
    artist.artist_id AS artist_id,
    artist.name AS Artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS Total
FROM
    invoice_line
        JOIN
    track ON invoice_line.track_id = track.track_id
        JOIN
    album ON album.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album.artist_id
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 1 ;


-- 2. We want to find out the most popular music Genre for each country.
--    We determine the most popular genre as the genre with the highest amount of purchases.
--    Write a query that returns each country along with the top Genre. 
--    For countries where the maximum number of purchases is shared return all Genres.
 
 WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- 3. Write a query that determines the customer that has spent the most on music for each country. 
--    Write a query that returns the country along with the top customer and how much they spent. 
--    For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;



 
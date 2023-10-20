Create database Music_store_analysis
use Music_store_analysis

----------------------------------------------------------------------Questions--------------------------------------------------------
-----------------------------------------------Easy---------------------------------------------------------------
-- Who is the senior most employee based on job title?

select * from employee
where reports_to is null

--2. Which countries have the most Invoices?
select top 1  billing_country,COUNT(billing_country) as invoice_count from [dbo].[invoice]
group by billing_country
order by billing_country desc
--3. What are top 3 values of total invoice?
select top 3 total from invoice
order by total desc

--4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made 
--the most money.
--Write a query that returns one city that has the highest sum of invoice totals. Return both the 
--city name & sum of all invoice totals

select  top 1 billing_city,sum(total) as total_invoice_value from invoice
group by billing_city
order by total_invoice_value desc

-- so the concert will be in prague

--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

select concat(first_name,' ',last_name) as customer_name from customer
where customer_id in 
			(select  top 1 customer_id from invoice
			group by customer_id
			having sum(total) = (select top 1 sum(total) as total from invoice 
			group by customer_id order by total desc))

------------------------------------------Moderate-----------------------------------------------------------------
--1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
--Return your list ordered alphabetically by email starting with A.
	with genre_name as 		
			(select * from customer
			cross join genre)
	select distinct email,first_name,last_name,name from genre_name
	where name = 'Rock'
	order by email 
------------------------------other ------------------------------------------------
	with cte as 
		(select c.email,c.first_name,c.last_name,g.name from genre g
		join track t 
		on g.genre_id = t.genre_id
		join invoice_line il
		on il.track_id = t.track_id
		join invoice i on
		i.invoice_id = il.invoice_id
		join customer c on
		c.customer_id = i.customer_id)
select distinct * from cte 
where name = 'rock'

--------------------------------------------other -------------------------------------------------
SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--------------------------------------------------------------------------------------------------

--2. Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

select top 10 ar.artist_id,max(ar.name) as Artist_name,count(ar.artist_id) as num_of_songs from artist ar
join album al on
ar.artist_id = al.artist_id
join track t 
on al.album_id = t.album_id
join genre g on 
g.genre_id = t.genre_id
where  g.name = 'rock'
group by ar.artist_id
order by num_of_songs desc;


--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name,milliseconds from track where milliseconds >
	(select avg(milliseconds) as avg_length from track)
order by milliseconds desc


------------------------------------------Advanced----------------------------------------------------------------
--1. Find how much amount spent by each customer on artists? Write a query to return customer name, 
--artist name and total spent.

with cte as 
			(select c.first_name,ar.name,sum(il.quantity*il.unit_price) as  total_spent from customer c
			join invoice i on c.customer_id = i.customer_id
			join invoice_line il on i.invoice_id = il.invoice_id
			join track t on il.track_id = t.track_id
			join album al on t.album_id = al.album_id
			join artist ar on ar.artist_id = al.artist_id 
			group by ar.name,c.first_name
			)
select * from cte 
where name = 'queen'
order by total_spent desc


--2. We want to find out the most popular music Genre for each country. We determine the most popular genre as 
--the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is shared return all Genres.
with cte as 
			(select i.billing_country as country,sum(il.quantity) as purchased_units,g.name from customer c
			join invoice i on c.customer_id = i.customer_id
			join invoice_line il on il.invoice_id = i.invoice_id
			join track t on t.track_id = il.track_id
			join genre g on g.genre_id = t.genre_id
			group by i.billing_country,g.name
			) 
select distinct country,name,sum(purchased_units) as PU from cte 
group by country,name
order by PU desc

--3. Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.


select billing_country,sum(total) as amt from customer c
join invoice i on c.customer_id = i.customer_id
group by billing_country
order by amt desc

		with cte as
				(select min(customer_id) as cust_id,sum(total) as amt,billing_country from invoice
				group by billing_country)
		select c.cust_id,cu.first_name,amt,billing_country from cte c join customer cu 
		on cu.customer_id = c.cust_id
		order by amt desc





select * from [dbo].[album]
select * from  [dbo].[artist]
select * from [dbo].[customer]
select * from [dbo].[employee]
select * from [dbo].[genre]
select * from [dbo].[invoice]
select * from [dbo].[invoice_line]
select * from [dbo].[media_type]
select * from [dbo].[playlist]
select * from [dbo].[playlist_track]
select * from [dbo].[track]


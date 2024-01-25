USE sakila;

-- Creating a Customer Summary Report
-- 1. Create a view that summarizes rental information for each customer. The view should include:
-- customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_summary AS
SELECT customer_id, first_name, last_name, email, COUNT(rental_id) AS num_of_rentals
FROM customer
LEFT JOIN rental
USING(customer_id)
GROUP BY customer_id;

-- 2. Create a temporary table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
-- calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_paid_pc1 AS
SELECT customer.customer_id, 
	CONCAT(first_name, ' ', last_name) AS customer_name, 
    SUM(amount) AS total_paid
FROM customer
LEFT JOIN rental
USING(customer_id)
JOIN payment
USING(rental_id)
GROUP BY customer_id;

SELECT * FROM total_paid_pc1;
SELECT * FROM rental_summary;

# using view from step 1
CREATE TEMPORARY TABLE total_paid_pc2 AS
SELECT payment.customer_id, 
	CONCAT(first_name, ' ', last_name) AS customer_name, 
    SUM(amount) AS total_paid
FROM rental_summary
JOIN payment
USING(customer_id)
GROUP BY customer_id;
SELECT * FROM total_paid_pc2;

-- 3. Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created 
-- in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

#check:
SELECT customer_name, email, num_of_rentals, total_paid
FROM rental_summary
JOIN total_paid_pc2
USING(customer_id);


WITH customer_summary AS ( 
	SELECT customer_name, email, num_of_rentals, total_paid
	FROM rental_summary
	JOIN total_paid_pc2
	USING(customer_id)
)
SELECT customer_name, email, num_of_rentals, total_paid, total_paid/num_of_rentals AS avg_paid_per_rental
FROM customer_summary;
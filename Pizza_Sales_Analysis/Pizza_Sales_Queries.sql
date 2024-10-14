CREATE DATABASE Pizza_hut ;

CREATE TABLE Orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE Order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Basic:

-- 1. Retrieve the total number of orders placed. 

SELECT 
    COUNT(order_id)
FROM
    orders;
    
-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1; 

-- 4. Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.order_details_id) AS Total_quan
FROM
    Pizzas
        JOIN
    order_details ON Pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY total_quan DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, count(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;


 -- ------------------------------------------------------------------------------------------------------------------
 -- ------------------------------------------------------------------------------------------------------------------
 
 
-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- 2. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time) AS order_hours,
    COUNT(order_id) AS dist_of_orders
FROM
    orders
GROUP BY order_hours
ORDER BY dist_of_orders;

-- 3. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity),0) AS Avg_Orders_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS QUAN;

-- 5. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;


-- -----------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------


-- Advanced:

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
 
SELECT 
    pizza_types.category,
    ROUND(ROUND(SUM(order_details.quantity * pizzas.price),
            2) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100 ,2) AS Total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_revenue DESC;

-- 2. Analyze the cumulative revenue generated over time-

SELECT order_date,
ROUND(SUM(revenue) OVER(ORDER BY order_date),2) AS Cum_revenue
FROM 
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date )  AS Total_sales ;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT category, name, revenue
FROM (
SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS RN
FROM(
SELECT 
    pizza_types.category,
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name) AS S ) AS T
WHERE RN <= 3 ;

 
 
 
 
 
 
 
 
 
 
 
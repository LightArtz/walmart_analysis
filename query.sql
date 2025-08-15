select * from walmart limit 1;

-- Q1 Find different payment method and number of transactions, number of qty sold
select
	payment_method,
    count(*) as number_transactions,
    sum(quantity) as quantity_sold
from walmart
group by payment_method;

-- Q2 Identify the highest rated category in each branch, displaying the branch, category, avg rating
with cte as (
	select
		branch,
		category,
		avg(rating) as avg_rating
	from walmart
	group by branch, category
)
select branch, category, avg_rating
from (
	select 
		*,
		rank() over (partition by branch order by avg_rating desc) as rnk
	from cte
) as temp
where rnk = 1;

-- Q3 Identify the busiest day for each branch based on the number of transactions
select branch, days, no_of_transactions
from (
	select
		branch, 
		dayname(str_to_date(date, '%d/%m/%y')) as days,
		count(*) as no_of_transactions,
		rank() over (partition by branch order by count(*) desc) as rnk
	from walmart
	group by branch, dayname(str_to_date(date, '%d/%m/%y'))
) as temp
where rnk = 1;

-- Q4 Calculate the total quantity of items sold per payment method. List payment method and total quantity.
select
	payment_method,
    sum(quantity) as total_sold
from walmart
group by payment_method;

-- Q5 Determine the average, minimum, and maximum rating of products for each city. List the city, average_rating, min_rating, and max_rating.
select 
	city,
    category,
    avg(rating) as avg_rating,
    min(rating) as min_rating,
    max(rating) as max_rating
from walmart
group by city, category;

-- Q6 Calculate total profit for each category. Total profit = unit price * quantity * profit_margin. List category and total profit.alter
select
	category,
    sum(unit_price * quantity * profit_margin) as total_profit
from walmart
group by category
order by total_profit desc;

-- Q7 Determine the most common payment method for each branch. Display branch and the preferred payment method.
select branch, payment_method as preferred_payment_method, total_transactions
from (
	select 
		branch,
		payment_method,
		count(*) as total_transactions,
		rank () over (partition by branch order by count(*) desc) as rnk
	from walmart
	group by branch, payment_method
) as temp
where rnk = 1;

-- Q8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of voices
with cte as (
	select
		*,
		case
			when hour(time(time)) < 12 then 'Morning'
			when hour(time(time)) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end as shift
	from walmart
)

select
	branch,
	shift,
    count(*) as number_of_voices
from cte
group by branch, shift;

-- Q9 Idenfity 5 branch with highest decrease ratio in revenue 
-- compare to last year (cy 2023 and ly 2022)
with rev_2023 as (
	select
		branch,
        sum(total) as total_revenue_2023
	from walmart
    where year(str_to_date(date, '%d/%m/%y')) = 2023
    group by branch
), rev_2022 as (
	select
		branch,
        sum(total) as total_revenue_2022
	from walmart
    where year(str_to_date(date, '%d/%m/%y')) = 2022
    group by branch
)

select 
	a.branch, 
    round((total_revenue_2022 - total_revenue_2023) / total_revenue_2022 * 100, 2) as decrease_ratio
from rev_2023 a
join rev_2022 b on a.branch = b.branch
order by decrease_ratio desc
limit 5



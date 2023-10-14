use database sales;
select * from sales_sample_data limit 5;

--Inspecting Data
SELECT * FROM SALES_SAMPLE_DATA LIMIT 10;
SELECT COUNT(*) FROM SALES_SAMPLE_DATA;--2,747


--Checking unique values
select distinct status from SALES_SAMPLE_DATA;
--there are 6 types of status 
select distinct year_id from SALES_SAMPLE_DATA;
-- we have data from year 2003,2004 & 2005
select distinct PRODUCTLINE from SALES_SAMPLE_DATA;
-- we have 7 types of product in the dataset
select distinct COUNTRY from SALES_SAMPLE_DATA;
--here we have information about 19 countries

select distinct city from sales_sample_data;
--Total 71 cities information is recorded here

select distinct DEALSIZE from SALES_SAMPLE_DATA;
-- here we have 3 types of deal size

select distinct TERRITORY from SALES_SAMPLE_DATA;
--we have data from 4 territory


select distinct MONTH_ID from SALES_SAMPLE_DATA
where year_id = 2005
ORDER BY 1;

-- 2003 and 2004 has all year data but 2005 has only 5 months data


---ANALYSIS
----Let's start by grouping sales by productline
SELECT ORDERNUMBER, ORDERLINENUMBER, PRODUCTLINE, SALES, *  
FROM SALES_SAMPLE_DATA
ORDER BY 1, 2
LIMIT 10;

select round(sum(sales)) as total_revenue from sales_sample_data;
--here we have total sales  revenue is 9,760,222


--now we will find out revenue generating product 
select PRODUCTLINE, ROUND(sum(sales),0) AS Revenue,
round((sum(sales)/(select sum(sales) from sales_sample_data))*100,2) as revenue_percentage,
COUNT(distinct ORDERNUMBER) AS NO_OF_ORDERS
from SALES_SAMPLE_DATA
group by PRODUCTLINE
order by 4 desc;
--Classic cars is the most ordered product and it has also generated most revenue(almost 40%)
-- and train is the lowest revenue generating product


select YEAR_ID, round(sum(sales)) Revenue
from SALES_SAMPLE_DATA
group by YEAR_ID
order by 2 desc;
--2004 and 2003 are the best in terms of revenue

select  DEALSIZE,  round(sum(sales)) Revenue
from SALES_SAMPLE_DATA
group by DEALSIZE
order by 2 desc;
--most of the revenue are generated from Medium and Small size deal


select ordernumber, round(sum(sales)) as total_spending from sales_sample_data
group by 1
order by 2 ;

--order number 10165 has the highest amount of spending and 10408 has the lowest spending


select  round(sum(sales)/sum(quantityordered),2) as average_orders
from sales_sample_data;

--the average monetary value of per itme is worth  101.22


select  round(sum(sales)/count(distinct ordernumber),2) as revenue_per_order
from sales_sample_data;




----What was the best month for sales in a specific year? How much was earned that month? 
select  MONTH_ID, round(sum(sales))  Revenue, count(distinct ORDERNUMBER) Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2004
group by  MONTH_ID
order by 2 desc;

--for the year 2004 november has the most revenue and the amout is 1,058,699 while the least was march



select  MONTH_ID, PRODUCTLINE, round(sum(sales)) Revenue, count(distinct ORDERNUMBER)
from SALES_SAMPLE_DATA
where YEAR_ID = 2004 and MONTH_ID = 11
group by  MONTH_ID, PRODUCTLINE
order by 3 desc;

--November seems to be the best month and the most selling product is Classic Cars


select  MONTH_ID, round(sum(sales))  Revenue, count(distinct ORDERNUMBER) Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2003
group by  MONTH_ID
order by 2 desc;
--In 2003 like 2004 November is the highest revenue generating month while January is the least


select  MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count( distinct ORDERNUMBER) Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2003 and MONTH_ID = 11 
group by  MONTH_ID, PRODUCTLINE
order by 3 desc;

-- Classic Cars again the most selling product in 2003

select  MONTH_ID, round(sum(sales))  Revenue, count(distinct ORDERNUMBER) Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2005
group by  MONTH_ID
order by 2 desc;
--in 2005 May has the highest revenue which is 457,861

select  MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(distinct ORDERNUMBER) as Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2005 and MONTH_ID = 5
group by  MONTH_ID, PRODUCTLINE
order by 3 desc;

-- Most selling product in May is Classic Cars


--As Classic Cars is the best Product ,now we will see which county is the biggest buyer of it

select productline, country, round(sum(sales)) as Revenue ,
count( distinct ordernumber) as Frequency
from sales_sample_data
where productline='Classic Cars'
group by 1,2
order by 3 desc;
--USA is the biggest market for the product Classic Cars


select country, round(sum(sales)) as Revenue,
round((sum(sales)/(select sum(sales) from sales_sample_data))*100,2) as percentage
from sales_sample_data
group by 1
order by 2 desc;

--Most of the revenue are from USA(almost 35%) and the lowest are from Ireland(less than 1%)


select  distinct country from sales_sample_data
where status ='Cancelled';-- only 4 country has cancelled orders



select country, count( ordernumber) as number_of_cancelled_orders
from sales_sample_data
where status='Cancelled'
group by 1
order by 2 desc;--Sweden and Spain has the most cancelled orders 


select status, sum(sales) as revenue 
from sales_sample_data
where status='Cancelled'
group by 1; --Almost 194,487.48 worth of revenue is lost due to cancelled orders

select dealsize, count(dealsize)
from sales_sample_data
where status='Cancelled'
group by 1
order by 2 desc;
--most of the cancelled dealsize was medium(33) and small(27).No large dealsize was cancelled


select city, count( distinct ordernumber) as number_of_orders
from sales_sample_data
group by city order by 2 desc limit 5;
--most of the orders have been placed from Madrid(31). Other city of the top orders are San Rafael, NYC,Paris,Singapore

select city, round(sum(sales)) as revenue
from sales_sample_data
group by city order by 2 desc limit 5;

--We can see the similar pattern in Revenue. Here we can say that number of orders is directly proportonal to the revenue generated



select country, count(distinct city) as number_of_city
from sales_sample_data
group by country
 having count(distinct city)>3
;


select customername, round(sum(sales)) as revenue,
dense_rank() over(order by sum(sales) desc) as ranking
from sales_sample_data
group by 1
;

select count(distinct customername) from sales_sample_data;--we have information about 89 customers

--Top 3 city with the highest revenue in a specific country


CREATE OR REPLACE PROCEDURE get_top_3_city_of_the_country(country_name varchar)
RETURNS TABLE()
LANGUAGE SQL
AS
DECLARE
  temporary_object RESULTSET DEFAULT (
  SELECT city, ROUND(SUM(SALES),0) AS Revenue
FROM SALES_SAMPLE_DATA
WHERE country = :country_name
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
  );
BEGIN
  RETURN TABLE(temporary_object);
END;

call get_top_3_city_of_the_country('Norway');


--Top 3 product in a specific country 
select PRODUCTLINE ,country, YEAR_ID,  sum(sales) Revenue
from SALES_SAMPLE_DATA
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc;


CREATE OR REPLACE PROCEDURE get_top_3_product_of_the_country(country_name varchar)
RETURNS TABLE()
LANGUAGE SQL
AS
DECLARE
  temporary_object RESULTSET DEFAULT (

  select PRODUCTLINE,country, YEAR_ID, sum(sales) Revenue
from SALES_SAMPLE_DATA
where country =:country_name
group by country,  YEAR_ID, PRODUCTLINE
order by 4 desc
 limit 3
  );
BEGIN
  RETURN TABLE(temporary_object);
END;

call get_top_3_product_of_the_country('Denmark');

SELECT TO_CHAR(TO_DATE(ORDERDATE, 'DD/MM/YYYY'), 'DD/MM/YY') AS converted_date from SALES_SAMPLE_DATA;

SELECT ORDERDATE FROM SALES_SAMPLE_DATA;
 --this is in varchar format. Now we will transform it into date format
SELECT TO_DATE(ORDERDATE, 'DD/MM/YYYY')  from SALES_SAMPLE_DATA;

--now we will find the earliest order date and latest order date
SELECT MAX(TO_DATE(ORDERDATE, 'DD/MM/YYYY')) AS LATESTDATE from SALES_SAMPLE_DATA;--2005-05-31
SELECT MIN(TO_DATE(ORDERDATE, 'DD/MM/YYYY')) AS EARLIESTDATE from SALES_SAMPLE_DATA;--2003-01-06

--the difference between earliest and latest order date
SELECT 
datediff('MONTH', MIN(TO_DATE(ORDERDATE, 'DD/MM/YYYY')), MAX(TO_DATE(ORDERDATE, 'DD/MM/YYYY'))) as difference_between_orders
FROM SALES_SAMPLE_DATA; 


--RFM SEGMENTATION: SEGMENTING  CUSTOMERS BASEN ON RECENCY (R), FREQUENCY (F), AND MONETARY (M) SCORES

 create view rfm_segment as 

 WITH CTE1 AS
 (select 
		CUSTOMERNAME, 
		ROUND(sum(sales),0) AS MonetaryValue,
		ROUND(avg(sales),0) AS AvgMonetaryValue,
		count(distinct ORDERNUMBER) AS Frequency, 
		MAX(TO_DATE(ORDERDATE, 'DD/MM/YYYY')) AS last_order_date, --last order date for that specific customer
		(select MAX(TO_DATE(ORDERDATE, 'DD/MM/YYYY')) from SALES_SAMPLE_DATA) AS max_order_date,--from the overall data, the latest order date
		DATEDIFF('DAY', last_order_date,  max_order_date) AS Recency --higher value of frequency is not good, it means we are loosing that 
                                                                         --customer
	from SALES_SAMPLE_DATA
	group by CUSTOMERNAME
          ),
                                        /**ntile() is used to divide the data into different number of buckets,usually we divide 
                                            the customers into 4 groups , the lowest 25% will get score 1 ,the next 25% will get score 2 and 
                                      the last 25% will get score 4 accordingly. **/
 rfm_calc as
(
	select C.*,
		NTILE(4) OVER (order by Recency DESC) rfm_recency,           --here 4 means the data will be divided into 4 buckets
		NTILE(4) OVER (order by Frequency ASC) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue ASC) rfm_monetary
	from CTE1 as C
    
    )

    select 
	R.*, (rfm_recency+ rfm_frequency+ rfm_monetary) as rfm_total_score,
	concat(cast(rfm_recency as varchar),cast(rfm_frequency as varchar),cast(rfm_monetary  as varchar)) as rfm_score_category
from rfm_calc R;

select * from  rfm_segment;



select distinct rfm_score_category from rfm_segment
order by 1;




select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_score_category in (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_score_category in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven t purchased lately) slipping away
		when rfm_score_category in (311, 411, 331) then 'new customers'
		when rfm_score_category in (222, 231, 221,  223, 233, 322) then 'potential churners'
		when rfm_score_category in (323, 333,321, 341, 422, 332,431,421,424, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_score_category in (433, 434, 443, 444) then 'loyal'
        else 'Other'
	end as Customer_Segment
from rfm_segment;
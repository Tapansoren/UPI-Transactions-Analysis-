-- total transactions amount
select sum(amount) as total_amount 
from upi_transaction_history;
-- Average Transaction Amount
select round(avg(amount),2) as average_amount from upi_transaction_history;

-- Transaction trend over time 
select timestamp,amount
from upi_transaction_history
order by timestamp ;

-- transaction by device_type
select device_type , avg(amount)
from upi_transaction_history
group by device_type;

-- transactions by status
select status,sum(amount)
from upi_transaction_history
group by status;

-- transactions by merchant_type
select m.merchant_type,sum(u.amount)
from upi_transaction_history u
join merchant_info m
on m.merchant_id=u.merchant_id
group by merchant_type
order by sum(u.amount) desc;

-- transactions by region
select m.region,sum(u.amount)
from upi_transaction_history u
join merchant_info m
on m.merchant_id=u.merchant_id
group by region
order by sum(u.amount) desc;

-- device_type distribution
select count(*),device_type
from device_info
group by device_type;

-- Top Failure Reason
select failure_reason as top_failed_reason , count(transaction_id)
from upi_transaction_history
where status ='failed'
group by top_failed_reason
limit 1;
-- Worst Performing Device
-- Peak Failure Time
 
-- Fraud Analysis
SELECT fraud_flag,
       COUNT(*)
FROM upi_transaction_history
GROUP BY fraud_flag;

-- failed transactions rate
select round(COUNT(CASE WHEN status = 'Failed' THEN transaction_id END)*100.0/count(transaction_id),2) as failed_txn_rate
from upi_transaction_history;

-- success transactions rate
select round(COUNT(CASE WHEN status = 'Success' THEN merchant_id END)*100.0/count(merchant_id),2) as Success_txn_rate
from upi_transaction_history;

-- failed vs success vs pending transactions
SELECT status,
       COUNT(*)
FROM upi_transaction_history
GROUP BY status;


-- Overall fraud detection rate
SELECT
    COUNT(*) AS total_transactions,
    SUM(fraud_flag) AS fraud_transactions,
    ROUND(
        (SUM(fraud_flag) * 100.0) / COUNT(*),
        2
    ) AS fraud_detection_rate
FROM upi_transaction_history;
-- Total Users
select count(distinct(customer_id)) as Total_Users from upi_transaction_history;


-- Fraud Rate by Channel(Payment Method)
SELECT
    channel,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_txns,
    ROUND(
        (SUM(fraud_flag) * 100.0) / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history
GROUP BY channel;

-- fraud rate by Device Type
select device_type ,count(*) as total_txns,
       sum(fraud_flag) as fraud_txns,
       round((sum(fraud_flag)*100.0)/count(*),2
       ) as fraud_rate
from upi_transaction_history	
group by device_type;


-- Fraud rate by Merchant 
SELECT
    m.merchant_name,u.merchant_id,
    COUNT(*) AS total_txns,
    SUM(u.fraud_flag) AS fraud_txns,
    ROUND(
        (SUM(u.fraud_flag) * 100.0) / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history u
join merchant_info m 
on m.merchant_id=u.merchant_id
GROUP BY u.merchant_id
ORDER BY fraud_rate desc
limit 10;	

-- fraud by customer
select c.full_name,u.customer_id,count(u.fraud_flag) as frauds
from upi_transaction_history u
join customer_master c 
on c.customer_id=u.customer_id
join fraud_alert_history f
on f.transaction_id=u.transaction_id
where fraud_flag=1 and resolved = 0
group by customer_id
order by frauds desc ;

-- fraud by region
select c.region,sum(u.fraud_flag)as frauds
from upi_transaction_history u
join customer_master c
on c.customer_id = u.customer_id
where u.fraud_flag= 1
group by c.region;

-- fraud by rooted device
select 
count(*) as total_transactions,
sum(is_rooted) as rooted,
round(sum(is_rooted)*100.0/count(*),2) as rooted_rate
from upi_transaction_history u
join device_info d
on u.customer_id=d.customer_id
where fraud_flag = 1;

-- fraud by (day/night)
SELECT
    CASE
        WHEN HOUR(timestamp) BETWEEN 6 AND 17 THEN 'Day'
        ELSE 'Night'
    END AS time_period,

    COUNT(*) AS total_transactions,

    SUM(fraud_flag) AS fraud_transactions,

    ROUND(
        SUM(fraud_flag) * 100.0 / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history
GROUP BY time_period;

-- fraud by amount size                          
select amount,fraud_flag
from upi_transaction_history
where fraud_flag = 1
order by amount desc;

-- fraud by gender
select c.gender,sum(u.fraud_flag)
from upi_transaction_history u
join customer_master c
on c.customer_id=u.customer_id
group by c.gender;

-- fraud by txn type
select transaction_type,sum(fraud_flag)
from upi_transaction_history
group by transaction_type;

-- Compliance Requirements Analysis
-- 1. KYC/Account Completeness Analysis
SELECT COUNT(*) AS customers_without_upi
FROM customer_master c
LEFT JOIN upi_account_details u
ON c.customer_id = u.customer_id
WHERE u.customer_id IS NULL;
-- 2.Invalid device mapping
SELECT COUNT(*)
FROM upi_transaction_history t
LEFT JOIN device_info d
ON t.device_id=d.device_id
WHERE d.device_id IS NULL;

-- fraud alert resolution rate
SELECT
ROUND(
SUM(resolved)*100.0/COUNT(*),
2
) AS resolution_rate
FROM fraud_alert_history;

-- Average Resolution Time
SELECT
AVG(
TIMESTAMPDIFF(
HOUR,
alert_date,
resolution_date
)
) AS avg_resolution_hours
FROM fraud_alert_history
WHERE resolved=1;

-- New vs Old Customers 
SELECT
CASE
WHEN DATEDIFF(CURDATE(),date_joined)<90
THEN 'New'
ELSE 'Existing'
END customer_segment,
COUNT(*)
FROM customer_master
GROUP BY customer_segment;

-- Fraud by Customer Age Group
SELECT
CASE
WHEN age<25 THEN '18-24'
WHEN age<35 THEN '25-34'
WHEN age<45 THEN '35-44'
ELSE '45+'
END age_group,
SUM(fraud_flag)
FROM customer_master c
JOIN upi_transaction_history t
ON c.customer_id=t.customer_id
GROUP BY age_group;

-- Fraud by gender
select c.gender, count(u.fraud_flag) as total_frauds
from upi_transaction_history u
join customer_master c
on c.customer_id=u.customer_id
where u.fraud_flag = 1
group by c.gender;

-- Failure Rate by Device Type
SELECT
device_type,
ROUND(
SUM(status='Failed')*100.0/COUNT(*),
2
) failure_rate
FROM upi_transaction_history
GROUP BY device_type;

-- failure rate by channel
SELECT
channel,
ROUND(
SUM(status='Failed')*100.0/COUNT(*),
2
) failure_rate
FROM upi_transaction_history
GROUP BY channel;

-- failure by merchant
SELECT
m.merchant_name,
ROUND(
SUM(u.status='Failed')*100.0/COUNT(*),
2
) failure_rate
FROM upi_transaction_history u 
join merchant_info m
on m.merchant_id=u.merchant_id
GROUP BY m.merchant_name
order by failure_rate desc;

-- top failure reason 
SELECT
failure_reason,
COUNT(*)
FROM upi_transaction_history
WHERE status='Failed'
GROUP BY failure_reason
ORDER BY COUNT(*) DESC;		

-- Transaction Value by Region
select m.region,round(sum(u.amount),2)as transaction_value
from upi_transaction_history u
join merchant_info m
on m.merchant_id = u.merchant_id
group by m.region
order by transaction_value desc;

-- Revenue by Merchant
select m.merchant_name,round(sum(u.amount),2) as revenue
from upi_transaction_history u 
join merchant_info m
on m.merchant_id=u.merchant_id
group by merchant_name
order by revenue desc
limit 10;

-- Active Customers by Region
SELECT 
    c.region,
    COUNT(CASE WHEN u.status = 'active' THEN c.customer_id END) AS active_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(CASE WHEN u.status = 'active' THEN c.customer_id END) * 100.0
        / COUNT(*),
        2
    ) AS active_rate
FROM  upi_account_details u
LEFT JOIN customer_master c
    ON c.customer_id = u.customer_id
GROUP BY c.region;
-- fraud rate by risk score
SELECT
CASE
    WHEN m.risk_score <= 0.30 THEN 'Low Risk'
    WHEN m.risk_score <= 0.60 THEN 'Medium Risk'
    WHEN m.risk_score <= 0.80 THEN 'High Risk'
    ELSE 'Critical Risk'
END AS risk_category,
COUNT(*) total_txns,
SUM(t.fraud_flag) fraud_txns,
ROUND(SUM(t.fraud_flag)*100.0/COUNT(*),2) fraud_rate
FROM merchant_info m
JOIN upi_transaction_history t
ON m.merchant_id=t.merchant_id
GROUP BY risk_category
ORDER BY fraud_rate DESC;

-- Merchant Risk Category Distribution
SELECT
CASE
    WHEN risk_score <= 0.30 THEN 'Low Risk'
    WHEN risk_score <= 0.60 THEN 'Medium Risk'
    WHEN risk_score <= 0.80 THEN 'High Risk'
    ELSE 'Critical Risk'
END AS risk_category,
COUNT(*) AS merchant_count
FROM merchant_info
GROUP BY risk_category;

-- #Transaction Volume by merchants
select m.merchant_name,count(u.merchant_id) as merchant_txns
from merchant_info m
join upi_transaction_history u
on u.merchant_id=m.merchant_id
group by merchant_name
order by merchant_txns desc;

-- Failure rate by merchant 	                             #####
select m.merchant_name,count(u.transaction_id) as total_txn,
COUNT(CASE WHEN u.status = 'Failed' THEN m.merchant_id END) as failed_txn,
round(COUNT(CASE WHEN u.status = 'Failed' THEN m.merchant_id END)*100.0/count(u.merchant_id),2) as failed_txn_rate
from upi_transaction_history u
join merchant_info m
on m.merchant_id=u.merchant_id
group by merchant_name
order by failed_txn_rate desc;

-- failure rate by Bank
select up.bank_name, round(COUNT(CASE WHEN u.status = 'failed' THEN u.transaction_id END)*100.0/count(transaction_id),2) as failed_txn_rate
from upi_transaction_history u
join upi_account_details up
on u.upi_id=up.upi_id
group by bank_name;

-- High Risk Merchant 
SELECT
    m.merchant_name,u.merchant_id,
    COUNT(*) AS total_txns,
    SUM(u.fraud_flag) AS fraud_txns,
    ROUND(
        (SUM(u.fraud_flag) * 100.0) / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history u
join merchant_info m 
on m.merchant_id=u.merchant_id
GROUP BY u.merchant_id
having fraud_rate >5.00
ORDER BY fraud_rate desc;

-- transaction by payment method
select channel as method, count(*) as total_transactions
from upi_transaction_history
group by method;

-- transaction by device type
select device_type, count(transaction_id)as total_transactions
from upi_transaction_history
group by device_type;

-- Active UPI customers
select count(distinct(c.customer_id)) as active_cust
from customer_master c
join upi_account_details u
on c.customer_id = u.customer_id
where status = 'active';

-- customer with upi account
select count( distinct(c.customer_id)) as with_upi
from customer_master c
join  upi_account_details u
on c.customer_id = u.customer_id;

-- Non active customers
SELECT
COUNT(DISTINCT c.customer_id) AS non_active_customers

FROM customer_master c

JOIN upi_account_details u
ON c.customer_id = u.customer_id

WHERE u.status IN ('suspended','blocked');


-- Hypothesis Testing (t-test,ANOVA,chi-square)                 
select device_type, amount
from upi_transaction_history;

-- ANOVA
SELECT
m.merchant_type,
u.fraud_flag

FROM upi_transaction_history u

JOIN merchant_info m
ON m.merchant_id = u.merchant_id;

-- chi-square
select channel, fraud_flag
from upi_transaction_history;

-- corelation 
select m.risk_score,u.fraud_flag
from merchant_info m 
join upi_transaction_history u
on m.merchant_id = u.merchant_id;



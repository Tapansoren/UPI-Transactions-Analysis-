CREATE DATABASE upi_transactions;

use upi_transactions;
-- 1. Customer Master Table
CREATE TABLE customer_master (
    customer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15),
    age INT CHECK (age >= 18),
    gender VARCHAR(15),
    region VARCHAR(50),
    date_joined DATE,
    is_business_user BOOLEAN DEFAULT FALSE,
    risk_score FLOAT CHECK (risk_score BETWEEN 0 AND 1)
    
);
DESCRIBE customer_master;

-- 2. Device Info Table
CREATE TABLE device_info (
    device_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    device_type VARCHAR(30),
    app_version VARCHAR(20),
    is_rooted BOOLEAN DEFAULT FALSE,
    last_active DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

-- 3. UPI Account Details Table
CREATE TABLE upi_account_details (
    upi_id VARCHAR(100) PRIMARY KEY,
    customer_id VARCHAR(50),
    bank_name VARCHAR(100),
    account_type VARCHAR(30),
    date_added DATE,
    status VARCHAR(20) CHECK (status IN ('Active', 'Blocked', 'Suspended')),
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

-- 4. Merchant Info Table
CREATE TABLE merchant_info (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(100),
    merchant_type VARCHAR(50),
    region VARCHAR(50),
    onboard_date DATE,
    risk_score FLOAT CHECK (risk_score BETWEEN 0 AND 1)
);

-- 5. UPI Transaction History Table
CREATE TABLE upi_transaction_history (
    transaction_id VARCHAR(50) PRIMARY KEY,
    upi_id VARCHAR(100),
    customer_id VARCHAR(50),
    timestamp DATETIME NOT NULL,
    amount FLOAT CHECK (amount > 0),
    transaction_type VARCHAR(40),
    merchant_id VARCHAR(50) NULL,
    counterparty_upi VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')),
    device_id VARCHAR(50),
    channel VARCHAR(30),
    fraud_flag BOOLEAN DEFAULT FALSE,
    reversal_flag BOOLEAN DEFAULT FALSE,
    failure_reason VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id),
    FOREIGN KEY (upi_id) REFERENCES upi_account_details(upi_id),
    FOREIGN KEY (device_id) REFERENCES device_info(device_id),
    FOREIGN KEY (merchant_id) REFERENCES merchant_info(merchant_id)
);


-- 6. Customer Feedback Surveys Table
CREATE TABLE customer_feedback_surveys (
    feedback_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    date_submitted DATE NOT NULL,
    feedback_text TEXT,
    satisfaction_score INT CHECK (satisfaction_score BETWEEN 1 AND 5), -- 1 = Low, 5 = High
    issue_type VARCHAR(50) CHECK (issue_type IN ('fraud', 'transaction', 'app_usability', 'other')),
    resolved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id) ON DELETE CASCADE
);

-- 7. Fraud Alert History Table
CREATE TABLE fraud_alert_history (
    alert_id VARCHAR(50) PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    alert_type VARCHAR(50) CHECK (alert_type IN ('frequent_failure','unusual_time','unusual_amount','suspicious_login')), -- e.g., 'Suspicious Login', 'Velocity Trigger', 'High-Value Anomaly'
    alert_date DATETIME NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    resolution_date DATETIME NULL, -- Kept nullable because open alerts do not have a resolution timestamp yet
    remarks TEXT NULL,
    FOREIGN KEY (transaction_id) REFERENCES upi_transaction_history(transaction_id) ON DELETE CASCADE
);

-- Loaded data into table customer_master
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_master.csv'
INTO TABLE customer_master
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id,
 full_name,
 mobile_number,
 age,
 gender,
 region,
 @date_joined,
 @is_business_user,
 risk_score
 )

SET 
is_business_user = CASE
    WHEN @is_business_user='True' THEN 1
    WHEN @is_business_user='False' THEN 0
END,

date_joined = STR_TO_DATE(@date_joined,'%Y-%m-%d');
select * from upi_account_details;
-- load data into device_info table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/device_info.csv'
INTO TABLE device_info
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(device_id,customer_id,device_type,app_version,@is_rooted,@last_active)
set 
is_rooted =case
   when @is_rooted='True' then 1
   when @is_rooted= 'False' then 0
end,
last_active = str_to_date(@last_active,'%Y-%m-%d %H:%i:%s.%f');

-- data loaded into table upi_account_details
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/upi_account_details.csv'
into table upi_account_details
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

-- data loaded into table merchant info table
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/merchant_info.csv'
INTO TABLE merchant_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
merchant_id,
merchant_name,
merchant_type,
region,
@onboard_date,
@risk_score
)

SET

onboard_date = STR_TO_DATE(
TRIM(@onboard_date),
'%d-%m-%Y'
),

risk_score = TRIM(@risk_score);
select*from fraud_alert_history;
-- data loaded into table customer_feedback_surveys
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_feedback_surveys.csv'
INTO TABLE customer_feedback_surveys
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(feedback_id,
 customer_id,
 date_submitted,
 feedback_text,
 satisfaction_score,
 issue_type,
  @resolved)

SET resolved = CASE
   WHEN @resolved = 'True' THEN 1
   WHEN @resolved = 'False' THEN 0
END;
   
-- data loaded into table fraud_alert_history
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fraud_alert_history.csv'
INTO TABLE fraud_alert_history
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(alert_id,
 transaction_id,
 alert_type,
 @alert_date,
 @resolved,
 @resolution_date,
 remarks)

SET

resolved = CASE
   WHEN LOWER(TRIM(@resolved))='true' THEN 1
   WHEN LOWER(TRIM(@resolved))='false' THEN 0
END,

alert_date = STR_TO_DATE(
   NULLIF(TRIM(@alert_date),''),
   '%Y-%m-%d %H:%i:%s.%f'
),

resolution_date = CASE
   WHEN TRIM(@resolution_date)='' THEN NULL
   ELSE STR_TO_DATE(
      TRIM(@resolution_date),
      '%Y-%m-%d %H:%i:%s.%f'
   )
END;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_feedback_surveys.csv'
into table customer_feedback_surveys
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(feedback_id,customer_id,date_submitted,feedback_text,satisfaction_score,issue_type,@resolved)
SET resolved = CASE
   WHEN @resolved = 'True' THEN 1
   WHEN @resolved = 'False' THEN 0
END;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fraud_alert_history.csv'
into table fraud_alert_history
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(alert_id,transaction_id,alert_type,@alert_date,@resolved,@resolution_date,remarks)
set resolved = case
    when @resolved = 'True' then 1
    when @resolved = 'Flase' then 0
end,
alert_date= str_to_date(@alert_date, '%Y-%m-%d %H:%i:%s.%f'),
resolution_date=str_to_date(@resolution_date,'%Y-%m-%d %H:%i:%s.%f');



describe upi_transaction_history;




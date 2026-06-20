# 💳 UPI Transaction Analysis Capstone Project
## 📌 Project Executive Summary
This capstone project focuses on analyzing a large-scale, multi-table synthetic dataset containing over 100K+ UPI transactions. The goal is to provide data-driven insights to detect fraud, understand customer and merchant behaviors, evaluate merchant risk, and analyze systemic operational failure points.  By building a robust end-to-end data pipeline—from cleaning raw text and file databases to executing advanced statistical modeling—this analysis provides actionable strategic recommendations to optimize UPI ecosystem platform scalability and transactional security.

# 📊 Core Performance Metrics (KPIs)
Total Transactions: 100K+ transactions  Total Active Users: 7,032  Total Transaction Value: ₹4.24M  Transaction Success Rate: 92.14%  Transaction Failure Rate: 5.87%  Average Transaction Amount: ₹42.42  Fraud Detection Rate: 2.00% (2,000 total fraud transactions)  Avg. Fraud Alert Resolution Time: 35.40 Hours  

# 🛠️ Tech Stack & Tools Used
Data Processing & Engineering: Python (Pandas, NumPy) for raw dataset formatting, schema alignment, data transformation, and cleaning.  Relational Database Management: MySQL for structural tables staging, metadata management, and deep query execution.  Development Environment: Jupyter Notebook for exploratory data analysis (EDA), data cleaning steps, and statistical tests.  Business Intelligence (BI) Visualization: Power BI for interactive dashboard visualization, monitoring core KPIs, and plotting transactional trends.

# 📂 Database Architecture & Tables
The database consists of a multi-table relational schema structured into six key tables:  
customer_master: Customer demographic details, registration regions, and system metadata.  upi_transaction_history: Records transactional logs, channel endpoints, failure reasons, and timestamps.  merchant_info: Profiles merchant details, transaction categories, and static risk scores.  device_info: Logs device specifications, application versions, and root status flags.  upi_account_details: Monitors active bank mappings, account types, and status metrics.  fraud_alert_history: Tracks system alert triggers, investigative remarks, and resolution dates.  

# 🔄 Data Pipeline & ETL Methodology
Missing Value Handling: Identified structural anomalies across dataset columns; replaced or imputed null values safely and audited data cross-references.  Data Transformation: Standardized text string categories to Boolean indices (e.g., is_rooted, fraud_flag); parsed timestamp records into dedicated date/time formats; engineered feature ranges like age brackets.  Data Validation: Enforced cross-key consistency, mapped operational failure reason classifications, and audited transactional behavior flags across joined dimensions.  Relational Database Seeding: Migrated and scaled formatted local .csv files into a production-ready MySQL instance using optimized Python database connections.  

#💡 Key Business Insights
## 1. Growth & System Capacity
The platform processed over 100K successful transactions for 7k+ active users, resulting in a strong 92.14% success rate.  Transaction volumes exhibited massive geometric scaling from 2020 through 2025, validating robust user adoption and system stability. 
## 2. Fraud & Security Risk Vulnerabilities
While the baseline macro fraud rate sits at a controlled 2.00%, the platform reached an alarming historical peak of 1.3K fraud transactions during 2025.  Deep metrics reveal that QR-code transactions and rooted devices (27.46%) represent the vast majority of malicious security violations. 
## 3. Operational Performance & Failure Hotspots
The platform encountered 5,871 transaction drops, with Incorrect PIN inputs and system-wide network dropped logs emerging as top systemic factors.  Systemic failure events regularly surge into a heavy peak block around 05:00 AM, highlighting batch sync vulnerabilities, maintenance update friction, or off-peak merchant processing limits. 
## 4. Demographics & Merchant Concentrations
The 45+ age group contributes nearly half of the platform's financial transaction footprint, indicating high platform reliance among older demographic tiers.  Apparel and Electronics merchant categories dominate transactional throughput, while the North region leads geographic transaction value concentration.  A major operational bottleneck was detected: 2,967 customers remain active without linked UPI accounts, presenting an onboarding optimization gap. 
# 🚀 Strategic Recommendations
## 1. Device Security Enforcement
Introduce stricter validation checks for rooted device environment access and employ adaptive multi-factor verification checks during high-risk QR-code payment interactions to reduce fraud exposure. 
## 2. Dynamic Merchant Risk Monitoring
Continuously audit merchant transaction frequency and volume behaviors. Establish enhanced real-time compliance review processes for merchants experiencing elevated fraud alerts or failure histories. 
## 3. User Experience & Failure Minimization
Deploy proactive in-app context messages to reduce Incorrect PIN entry rates. Build fail-safe offline transaction queues or caching states to manage dropped bank pipelines seamlessly. 
## 4. Infrastructure Scaling
Redesign core network processing capacity and shift systemic backend system tasks away from the 05:00 AM bottleneck window to accommodate expanding transaction scale. 
## 5. Onboarding Campaign Expansion
Launch target marketing outreach programs focused on unmapped account holders (the 2,967 unlinked users) and deploy promotional incentives to drive active usage within lower-performing categories like Grocery and Transport.  

# Pharmacy Expansion Optimization Using SQL & SafeGraph
SQL-based analysis of pharmacy demand, brand dominance, and optimal hours using SafeGraph data



## Project Overview 
This project leveraged **SafeGraph foot traffic and demographic data** to identify ideal expansion sites for pharmacy chains. Using SQL queries on Google BigQuery, we evaluated:

- Brand popularity
- Underserved counties with elderly populations
- Business hour optimization based on visit patterns
- Demographic explanations for traffic behavior

The outcome supports **data-driven real estate investment** in the healthcare sector.

## Tech Stack
- SQL (BigQuery)
- SafeGraph Mobility + Demographic Datasets
- Python (Pandas for post-query refinement)
- Excel for summary tables
- DOCX for reporting

## Modeling Highlights

### A. Popular Brand Identification
Used 5-year visit history to identify Walgreens as the most visited U.S. pharmacy chain.

### B. High-Demand Geography
Cook County, IL stood out with the **highest elderly population per pharmacy**, signaling urgent expansion potential.

### C. Traffic by Day
Analyzed daily popularity data to find that **Friday has the highest traffic**, while **Sunday is lowest**.

### D. Demographics Analysis
Compared age distributions of Cook County vs. national trends, revealing that its **larger middle-aged population** explains low Sunday activity.

## Key Insights
- Walgreens is a top-performing brand and a strong benchmark.
- Cook County, IL has unmet pharmacy demand, especially for elderly care.
- Strategic business hours (e.g., close on Sunday) can cut costs without sacrificing sales.
- Demographic structure plays a critical role in consumer patterns.

##  Repository Structure
- `report`: Summary of the insights from the dataset
- `sql_query`: SQL query including the pharmacy expension analysis

---
📍 Aug – Oct 2024  
🏫 Purdue University Daniels School of Business


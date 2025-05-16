# 🏅 Collegiate Sports

This repository presents a full-stack data analysis of collegiate sports programs across the Globe. Using a dataset of over 100,000 rows, I built a clean, scalable pipeline using **Google Cloud Platform (GCP)**, **BigQuery**, and **Looker Studio** to uncover trends in revenue, participation, and school demographics.

---

## 📁 Repository Structure

```
Collegiate-Sports/
├── README.md
├── Phase_1/              # Initial MySQL script
├── Phase_2/              # BigQuery tables, cleaned schemas, analytics queries, and dashboard link
```

---

## 🔍 Project Summary

The goal of this project was to analyze participation and financial data from U.S. collegiate athletic programs. After encountering row limitations in MySQL, I transitioned to **Google BigQuery** to take advantage of its scalability and integration with visualization tools such as Looker.

---

## 🚀 Tech Stack

### 💾 Data Processing
- **Source**: Collegiate sports data from Kaggle
- **Cleaning**: Handled inconsistencies in ZIP codes, revenue formats, and null participation values
- **Schema Design**: Normalized the original flat file into structured dimension and fact tables

### ☁️ Google Cloud & BigQuery
- Uploaded the full dataset to **Google Cloud Storage**
- Queried and transformed data using **BigQuery**
- Created analytical tables such as:
  - `university`
  - `location`
  - `sector`
  - `sportname`
  - `program` and `participation` (with composite primary keys)
- Used `SAFE_CAST`, `CONCAT`, and `JOIN` logic to restructure raw data

### 📊 Looker Studio Dashboard (Phase 2)
- Built an interactive **Looker Studio dashboard** connected directly to BigQuery
- Features:
  - Filter by **state**, **institution**, and **year**
  - Visualizations of **top sports by participation and revenue**
  - Geographic analysis via ZIP code mapping
- 📍 The supporting queries are located in the `Phase_2/` folder
- 📊 The dashboard can be accessed through this link: https://lookerstudio.google.com/reporting/4ca1993a-5905-40bd-b6c8-3d6def134afa

---

## 📎 Example Queries

- Top sports by female participation
- Highest revenue-generating programs
- States with the most athletic institutions
- Schools with the largest expenditure on athletics

---

## 📌 How to Use

1. Browse `Phase_1/` for early SQL development in MySQL
2. Review `Phase_2/` for all BigQuery transformation scripts
3. View or replicate the dashboard using Looker Studio’s [BigQuery connector](https://lookerstudio.google.com)

---

## 🧠 What I Learned

- Migrating from row-limited environments (MySQL) to scalable cloud solutions
- Structuring a normalized schema from flat files
- Handling real-world inconsistencies in ZIP codes, data types, and missing values
- Building a user-friendly dashboard to share insights with non-technical audiences

---

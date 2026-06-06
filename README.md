# 🏏 CrickBuzz Analysis - International Cricket Insights (Feb - 2024)

An end-to-end data analytics project that takes raw cricket match data from
Cricbuzz (sourced via Kaggle), cleans it, models it, and turns it into
business-style insights using **Python, SQL, Excel, and Tableau**.

The central question: **does batting first and posting a big total actually help
you win?** Along the way the project also profiles formats, venues, teams, and
run-rate momentum across **202 international matches** played in **February 2024**.

---

## 📊 Dataset

- **Source:** [Kaggle](https://www.kaggle.com/) - Cricbuzz match data
- **Scope:** 202 international matches, February 2024
- **Breakdown:** T20 (107) · TEST (59) · ODI (36) · Men (164) · Women (38)
- **Coverage:** 78 venues · 136 teams
- **Files:** `Cricket_raw_data.csv` (raw) - `CrickBuzz_data_CLEANED.csv` (analysis-ready)

> The raw export had duplicated/misaligned innings columns, epoch-millisecond
> dates, float IDs, and result info buried in free text. All of this is fixed in
> the cleaning notebook.

---

## 🔑 Key Insights

- **Bigger first-innings scores strongly help you defend.** Bat-first win rate
  rises from **~14%** in the lowest score quartile to **~74%** in the third
  quartile - posting a competitive total is decisive in limited-overs cricket.
- **Format defines tempo.** Average first-innings run rate: **T20 ≈ 7.4**,
  **ODI ≈ 4.9**, **TEST ≈ 3.3** - exactly the aggression gradient you'd expect.
- **T20 dominates the calendar** with 107 of 202 matches, making it the most
  active format in the window.
- **Venue and run-rate momentum** profiles surface high-scoring grounds and
  whether chasing sides accelerate relative to the team batting first.

---

## 🛠️ Tools & Tech Stack

| Stage | Tool |
|-------|------|
| Cleaning & EDA | **Python** (Jupyter Notebook) |
| Querying & analysis | **SQL** (PostgreSQL) |
| Reporting / pivots | **Microsoft Excel** |
| Dashboard / viz | **Tableau** |

**Python libraries:** `pandas` · `numpy` · `matplotlib` · `seaborn` · `re` (regex)

**SQL techniques:** CTEs · Views · Window functions (`RANK`, `NTILE`,
`PERCENT_RANK`, `ROW_NUMBER`, running `SUM`) · `FILTER` aggregates · `PERCENTILE_CONT`

---

## 📁 Repository Structure

```
CrickBuzz-Analysis/
├── data/
│   ├── Cricket_raw_data.csv              # raw Kaggle export
│   └── CrickBuzz_data_CLEANED.csv        # cleaned, analysis-ready
├── notebooks/
│   └── Cricket_Buzz_Analysis.ipynb       # cleaning + EDA + charts
├── sql/
│   └── CrickBuzz_Analysis.sql            # schema, views, analytical queries
├── excel/
│   └── CrickBuzz_Analysis_Excel.xlsx     # cleaned data, data dictionary, pivots
├── tableau/
│   └── CrickBuzz_Analysis_Dashboard.twbx # interactive dashboard
├── charts/
│   ├── chart1_matches_by_format_and_run_rate.png
│   └── adv_defend_by_score.png
└── README.md
```

---

## 🔄 Project Workflow

1. **Collect** - raw match data pulled from Kaggle.
2. **Clean (Python)** - fix data types, untangle innings columns, parse epoch
   dates, and extract `winner`, `win_type`, `win_margin` from result text;
   derive `year`, `month`, `gender`, run rates, and total runs.
3. **Model (SQL)** - load into PostgreSQL, build a team-centric view (one row
   per team per match), and run window-function analytics.
4. **Report (Excel)** - cleaned table, data dictionary, and summary pivots.
5. **Visualize (Tableau)** - interactive dashboard for formats, venues, and
   the bat-first-vs-chase story.

---

## 📈 Sample Visuals

**Matches by format & average first-innings run rate**
![Matches by format and run rate]<img width="1000" height="400" alt="chart1_matches_by_format_and_run_rate" src="https://github.com/user-attachments/assets/ed444ed3-e104-4767-9c36-d2cadab2cf23" />

**Does a bigger first-innings score help you defend?**
![Bat-first win % by score quartile]<img width="840" height="480" alt="adv_defend_by_score" src="https://github.com/user-attachments/assets/a5a917ee-437f-44ec-a56e-15ddb632ad30" />


---

## 🚀 How to Run

```bash
# 1. Clone
git clone https://github.com/<vaishali-parmar0801>/CrickBuzz-Analysis.git
cd CrickBuzz-Analysis

# 2. Install Python dependencies
pip install pandas numpy matplotlib seaborn

# 3. Open the notebook
jupyter notebook notebooks/Cricket_Buzz_Analysis.ipynb
```

For the SQL: create the schema and run `sql/CrickBuzz_Analysis.sql` in PostgreSQL,
then import `CrickBuzz_data_CLEANED.csv` into the `matches` table.

---

## 👤 Author
**Vaishali Parmar**  
Data Analytics Portfolio Project  
Tools: Excel · SQL · Python · Power BI

---

## 📝 License

Released under the MIT License. Dataset belongs to its original Kaggle source.

# pharma-larc-sob-analysis
Commercial patient-level analytics & Source of Business (SOB) study on US Long-Acting Reversible Contraceptives (LARC) and postpartum treatment journeys using SQL & Excel.
# US LARC Commercial Analytics: Source of Business (SOB) & Postpartum Patient Journey

## Project Overview
This commercial analytics project evaluates longitudinal patient dynamics within the US **Long-Acting Reversible Contraceptive (LARC)** market. Using transaction-level patient data, the study focuses on two core commercial objectives:
1. **Source of Business (SOB) Analysis:** Identifying the clinical origins, prior contraceptive therapies (e.g., Oral Contraceptives, Depo injections), and life events (Postpartum, Abortion) for patients initiating brand LARCs (Mirena, Kyleena, Skyla, Liletta, Nexplanon, Paragard).
2. **Postpartum Treatment Journey:** Mapping contraceptive adoption patterns following childbirth, evaluating conversion rates to prescription (Rx) contraceptives and brand preference distributions.

---

## Business Questions & Objectives

* **SOB Analysis 1:** Where do new LARC patients come from? Isolate index LARC starts in 2022, map the immediately preceding clinical milestone/therapy event within patient history, and evaluate recurring utilization versus new starts.
* **SOB Analysis 2:** What contraceptive options do postpartum patients adopt following childbirth? Track a cohort of patients delivering in 2021 and measure subsequent adoption patterns across oral contraceptives, implants, and hormonal/non-hormonal IUDs.

---

## Analytics Workflow & Methodology

### 1. Cohort Construction & Patient History (SQL)
- **Index Event Isolation:** Leveraged SQL window functions (`ROW_NUMBER() OVER (PARTITION BY SRC_PTNT_ID ORDER BY START_DATE)`) to capture patients' earliest 2022 LARC starts.
- **Chronological Patient Trajectories:** Built chronological event paths using string aggregation (`STRING_AGG`) to visualize event flow before brand initiation.
- **Preceding Event Mapping:** Isolated the latest historical event (Delivery, Abortion, or alternative contraceptive methods) prior to the index LARC date.
- **Recurring Cohort Analysis:** Computed repeat utilization and method persistence within brand cohorts.

### 2. Standardization & Segmentation
- Categorized diverse event types into standardized clinical buckets: *Postpartum, Implant, Other Hormonal IUD, Hormonal IUD Continue, Injection, Abortion, Oral Contraceptives (OC), Ring, Patch, Paragard, Gel, and None*.
- Aggregated individual brand metrics alongside portfolio-level rollups (e.g., **Bayer IUD Cohort** combining *Mirena, Kyleena, and Skyla*).

### 3. Metric Aggregation & Reporting (Excel / BI)
- Computed brand-level volume share, percentage event attribution, and post-delivery drop-off vs. conversion rates.
- Synthesized findings into executive-ready slides and KPI summaries.

---

## Key Insights & Commercial Findings

* **Prior Therapy Conversion:** Oral Contraceptives (OC) represent the single largest prior switch pool for hormonal IUDs, accounting for **24% (Paragard)** to **45% (Kyleena)** of pre-initiation history.
* **Postpartum Inflow:** Childbirth is a major entry driver for IUDs—driving **25% to 30%** of initiations for Paragard, Liletta, and Mirena (with Nexplanon at **18%**).
* **Bayer IUD Performance:** Across the combined Bayer IUD portfolio, **22%** of patients initiated therapy directly following postpartum events.
* **Postpartum Rx Contraception Mix:** Following 2021 deliveries, patients adopting prescription contraception showed high preference for **Mirena (23.3%)**, followed by **Depo (20.2%)**, **Nexplanon (17.1%)**, and **OCs (14%)**—with LARCs comprising **61.8%** of total Rx events.

---

## Repository Structure

```text
├── sql/
│   └── Ex-onco_SQL_5.sql           # T-SQL scripts for cohort extraction, window functions & SOB matrices
├── data/
│   └── Ex-Oncology_case_study_5.xlsx # Raw pivot aggregations, percentage distribution & reporting tables
├── presentations/
│   └── Ex-Onco case study 5.pptx   # Executive commercial readout & patient journey flowcharts
└── README.md

# Home Credit Default Risk Prediction

## Overview
End-to-end machine learning pipeline predicting loan default probability on real-world applications from the [Home Credit Kaggle Competition](https://www.kaggle.com/c/home-credit-default-risk). Target variable is binary — 1 indicates default, 0 indicates no default — with significant class imbalance of 8.1% default rate.

---

## Project Structure
```
Home_Default_Credit_Risk/
│
├── sql/                          
│   ├── staging
│   │   ├── 01_create_tables.sql
│   │   └── 02_load_data.sql
│   │
│   └── analytics
│       └── 01_fact_table.sql
│
├── python/
│   ├── 01_eda.ipynb          
│   └── 02_analysis.ipynb     
│
└── README.md
```

---

## Dataset
| File | Description | Rows |
|---|---|---|
| application_train.csv | Main training data with target | 307,511 |
| application_test.csv | Test data without target | 48,744 |
| bureau.csv | Previous credits from other institutions | 1,716,428 |
| bureau_balance.csv | Monthly balance of bureau credits | 27,299,925 |

Data source: [Kaggle — Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk/data)

---

## Methodology

### 1. Data Preparation
- Bureau aggregation — engineered applicant-level features 
  from bureau.csv and bureau_balance.csv
- Domain cleaning — replaced known placeholders (DAYS_EMPLOYED=365243),
  impossible values, and XNA categories
- Missingness flags — created binary indicators for informative 
  missing patterns (EXT_SOURCE, building info)

### 2. Feature Engineering
- **Financial ratios** — debt-to-income, annuity-to-income, 
  credit-to-goods, bureau debt burden
- **Bureau features** — total active debt, closed loan count, 
  past default rate, delinquency rate
- **External scores** — EXT_SOURCE mean and minimum across 
  three credit bureau sources

### 3. Preprocessing Pipeline
- Stratified train/validation/test split
- Median imputation 
- Outlier capping at 99th percentile 
- Ordinal encoding 
- One hot encoding 
- StandardScaler 

### 4. Class Imbalance Handling
- class_weight='balanced' for sklearn models
- scale_pos_weight for XGBoost
- Primary evaluation metric: ROC-AUC

### 5. Models Compared
- Logistic Regression
- Decision Tree
- Random Forest
- XGBoost
- LightGBM

### 6. Hyperparameter Tuning
- GridSearchCV with StratifiedKFold (5 folds)
- RandomizedSearchCV for tree-based models
- Primary scoring metric: roc_auc

---

## Results

| Model | Validation ROC-AUC |
|---|---|
| Logistic Regression | 0.7496 |
| Decision Tree | 0.7089 |
| Random Forest | 0.7158 |
| LightGBM | 0.7677 |
| XGBoost | 0.7698 |

---

## Key Findings


---

## Tech Stack
```
Python 3.13.9
├── pandas, numpy          # Data manipulation
├── scikit-learn           # Preprocessing, modelling, evaluation
├── xgboost                # XGBoost classifier
├── lightgbm               # LightGBM classifier
└── matplotlib, seaborn    # Visualisation
```

## Acknowledgements
- [Home Credit Group](https://www.homecredit.net/) for providing 
  the dataset
- [Kaggle](https://www.kaggle.com/c/home-credit-default-risk) 
  for hosting the competition

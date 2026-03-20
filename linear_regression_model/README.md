# Summative: Student Exam Performance Regression

## Mission and Problem
My mission is to empower minds through quality education and improve support for learners who may be at risk of underperforming.
This project builds a predictive model for exam scores using student study behavior, school context, and home environment variables.
The goal is practical: identify influential factors and support earlier, data-driven academic intervention.

## Required Assignment Structure
The repository now matches the required assignment structure:

linear_regression_model/
|
|-- summative/
|   |-- linear_regression/
|   |   |-- multivariate.ipynb
|   |
|   |-- API/
|   |   |-- .gitkeep
|   |
|   |-- FlutterApp/
|       |-- .gitkeep

Note: Git does not track truly empty folders, so .gitkeep is used only to preserve the required empty directories.

## Dataset
- Name: Student Performance Factors
- Size: 6,607 records, 20 columns
- Source: Kaggle (lainguyn123)
- URL: https://www.kaggle.com/datasets/lainguyn123/student-performance-factors

## Notebook
- Main analysis notebook: summative/linear_regression/multivariate.ipynb

## Method Summary
The notebook performs the following pipeline:

1. Loads and inspects raw data (shape, distributions, nulls, types).
2. Handles missing data:
	- Numeric missing values filled with column mean.
	- Selected categorical missing values filled with column mode before mapping.
3. Encodes categorical variables into numeric form:
	- Ordinal mapping for ordered categories (for example, Low/Medium/High).
	- Binary mapping for yes/no variables.
4. Uses correlation analysis to remove weak features:
	- Dropped columns with absolute correlation below 0.05 with target.
	- Dropped features: Sleep_Hours, Physical_Activity.
5. Splits data into train and test sets:
	- 80 percent train, 20 percent test.
	- Random state 42.
6. Applies StandardScaler (fit on train only, transform train and test).
7. Trains and compares three regression models:
	- LinearRegression
	- DecisionTreeRegressor (max_depth=8)
	- RandomForestRegressor (n_estimators=200, max_depth=10)

## Model Performance (Test Set)
Results from the evaluated notebook run:

| Model | Train MSE | Test MSE | R2 |
|---|---:|---:|---:|
| Linear Regression | 4.3934 | 3.2682 | 0.7688 |
| Decision Tree | 3.9787 | 7.9659 | 0.4364 |
| Random Forest | 1.4753 | 4.7720 | 0.6624 |

Best model selected by lowest test MSE:
- regression_model (Linear Regression)
- Best test MSE: 3.2682

## Saved Artifacts
The notebook exports the trained inference assets used by Task 2 API integration:

- summative/linear_regression/best_model.pkl
- summative/linear_regression/scaler.pkl
- summative/linear_regression/feature_names.pkl

## Key Findings
- Hours_Studied and Attendance were among the strongest positive predictors of exam score.
- The linear model generalized better than the tree-based alternatives on unseen test data.
- Removing weakly related features improved model focus and reduced noise.

## Limitations
- This is observational data, so findings indicate association, not proven causation.
- The model is sensitive to preprocessing consistency; production inference must apply the same feature order and scaling used during training.
- Additional validation (cross-validation and subgroup error analysis) can further improve reliability.

## Ethics and Responsible Use
- Predictions should support teachers, not replace professional judgment.
- Model outputs should not be used to label or penalize students.
- Any deployment should include fairness checks across demographic and socioeconomic groups.

## How to Reproduce
1. Open summative/linear_regression/multivariate.ipynb.
2. Run all cells in order.
3. Review the model comparison table and exported artifact files.

## Submission Checklist
- Mission and problem clearly stated.
- Dataset source and description included.
- Notebook path provided.
- Preprocessing and modeling pipeline documented.
- Quantitative results table included.
- Best model and saved artifacts listed.
- Folder structure aligned with assignment requirement.

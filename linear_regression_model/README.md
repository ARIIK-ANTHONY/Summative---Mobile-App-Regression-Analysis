# Summative: Mobile App Regression Analysis

This repository contains my full end-to-end project for predicting student exam performance: model training in Jupyter, FastAPI deployment on Render, and a one-page Flutter mobile app that consumes the API.

I designed this as one connected workflow, not three separate tasks. The notebook finds the most reliable model, the API serves that model with strict validation, and the Flutter app makes it usable in a real prediction interface.

## Mission and Problem (4 lines)
My mission is to support earlier academic intervention for students at risk of underperforming.
I built a regression system that predicts exam score from study habits, school context, and family background factors.
The focus is not generic house pricing, it is an education-centered use case aligned to learner support.
The output is used in a mobile app for quick decision support.

## Dataset (Source + Description)
- Name: Student Performance Factors
- Source: Kaggle (lainguyn123)
- URL: https://www.kaggle.com/datasets/lainguyn123/student-performance-factors
- Size: 6,607 rows, 20 columns
- Why this dataset: rich mix of behavioral, school, and socioeconomic variables suitable for regression and feature analysis.

## Key Visualizations
See the following visualizations in [multivariate.ipynb](summative/linear_regression/multivariate.ipynb):
- **Correlation Heatmap:** Shows relationships between all variables and helps select features.
- **Score Distribution Histogram:** Reveals the spread and skew of the target variable.

These plots directly influenced feature selection and model performance.

## Repository Structure
```text
linear_regression_model/
	README.md
	render.yaml
	summative/
		linear_regression/
			multivariate.ipynb
			best_model.pkl
			scaler.pkl
			feature_names.pkl
			x_test.csv
		API/
			prediction.py
			requirements.txt
		FlutterApp/
			lib/main.dart
			pubspec.yaml
```

## Task 1: Linear Regression Notebook
Notebook path: `summative/linear_regression/multivariate.ipynb`

I started from data understanding and feature preparation, then compared multiple regressors under the same preprocessing pipeline to choose the best model for deployment.

### What is implemented
- Data loading, inspection, and cleaning.
- Categorical encoding to numeric values.
- Feature engineering with correlation-based filtering.
- Standardization with `StandardScaler`.
- Model training for:
	- `LinearRegression`
	- `DecisionTreeRegressor`
	- `RandomForestRegressor`
- Gradient-descent style learning analysis (`SGDRegressor`) with train/test loss tracking.
- Visualizations including correlation heatmap and model-related plots.
- Scatter/fit visualization for linear relationship and fitted regression line.
- Best-model selection by lowest test MSE.
- One-row test-set prediction using saved model artifacts (Task 2 preparation).


### Model Results (test set)
| Model | Train MSE | Test MSE | R2 |
|---|---:|---:|---:|
| Linear Regression | 4.3934 | 3.2682 | 0.7688 |
| Decision Tree | 3.9787 | 7.9659 | 0.4364 |
| Random Forest | 1.4753 | 4.7720 | 0.6624 |

**Model Justification:**
Linear Regression was selected for deployment because it achieved the lowest test MSE and highest R², indicating the best generalization to unseen data. The dataset's relationships were mostly linear, making this model the most appropriate and interpretable for the problem context.

### Saved Artifacts
- `summative/linear_regression/best_model.pkl`
- `summative/linear_regression/scaler.pkl`
- `summative/linear_regression/feature_names.pkl`

## Task 2: FastAPI Service
API path: `summative/API/prediction.py`

I implemented the API to be deployment-ready and safe for input quality, with explicit datatypes/ranges and a retraining path for model updates.


### Features implemented
- `POST /predict` endpoint for exam score prediction.
- `POST /retrain` endpoint to retrain model on uploaded CSV data.
- Strong request validation using Pydantic (`BaseModel`, typed fields, realistic ranges).
- CORS middleware configured without wildcard by default (`ALLOWED_ORIGINS` env variable).
- Required libraries included in `requirements.txt` (`fastapi`, `pydantic`, `uvicorn`, etc.).

### Public Deployment (Render)
- Live API Base URL: https://summative-mobile-app-regression-analysis-2rfp.onrender.com
- Swagger UI: https://summative-mobile-app-regression-analysis-2rfp.onrender.com/docs
- Predict endpoint: `POST /predict`
- Retrain endpoint: `POST /retrain`

## Task 3: Flutter Mobile App
Flutter entry: `summative/FlutterApp/lib/main.dart`

The app is intentionally one page to match the brief and make the prediction flow fast to test during demonstration.


### Run the Flutter App
From `summative/FlutterApp`:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://summative-mobile-app-regression-analysis-2rfp.onrender.com
```

Or for local API testing:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001
```



## Task 4: Video Demo
YouTube demo link (max 7 min required by brief):
- https://www.youtube.com/watch?si=D3i6BAdyDPd6pMMF&v=FAjqIMxgXLM&feature=youtu.be


## Reproduce Locally
### 1. Notebook workflow
1. Open `summative/linear_regression/multivariate.ipynb`.
2. Run all cells in order.
3. Confirm model metrics and artifact export.

### 2. API local run
From `summative/API`:

```bash
pip install -r requirements.txt
python -m uvicorn prediction:app --host 127.0.0.1 --port 8001 --reload
```

Docs: `http://127.0.0.1:8001/docs`


### 3. Flutter local run
From `summative/FlutterApp`:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001
```

This command ensures the Flutter app connects to your locally running FastAPI server. If you want to use the deployed API instead, set:

```bash
flutter run --dart-define=API_BASE_URL=https://summative-mobile-app-regression-analysis-2rfp.onrender.com
```

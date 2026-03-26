import pickle
import numpy as np
import pandas as pd
import io
import os
from pathlib import Path

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sklearn.preprocessing import StandardScaler


# ----------------------------------------------------------------
# load the three files saved from the notebook
# best_model.pkl, scaler.pkl, feature_names.pkl
# without all three the predictions will be wrong
# ----------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR.parent / "linear_regression"
BEST_MODEL_PATH = MODEL_DIR / "best_model.pkl"
SCALER_PATH = MODEL_DIR / "scaler.pkl"
FEATURE_NAMES_PATH = MODEL_DIR / "feature_names.pkl"

with open(BEST_MODEL_PATH, "rb") as f: model = pickle.load(f)
with open(SCALER_PATH, "rb") as f: scaler = pickle.load(f)
with open(FEATURE_NAMES_PATH, "rb") as f: feature_names = pickle.load(f)


# ----------------------------------------------------------------
# create the app
# ----------------------------------------------------------------
app = FastAPI(
    title="Student Exam Score Predictor",
    description=(
        "Predicts a student exam score based on study habits, "
        "teacher quality, parental involvement and other factors. "
        "Mission: improve education outcomes through data driven insights."
    ),
    version="1.0.0",
)


# ----------------------------------------------------------------
# CORS middleware
# not using wildcard * because that would allow any site to call
# the API which is a security risk
# allowing only the origins that actually need access
# ----------------------------------------------------------------
allowed_origins = [
    origin.strip()
    for origin in os.getenv("ALLOWED_ORIGINS", "").split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)


# ----------------------------------------------------------------
# pydantic input model
# every field has a type and a realistic range from the dataset
# fastapi returns 422 automatically if a value is out of range
# ----------------------------------------------------------------
class StudentInput(BaseModel):
    Hours_Studied: int = Field(
        ..., ge=1, le=44,
        description="Hours studied per week, between 1 and 44"
    )
    Attendance: int = Field(
        ..., ge=0, le=100,
        description="Attendance percentage, between 0 and 100"
    )
    Parental_Involvement: int = Field(
        ..., ge=0, le=2,
        description="0 is Low, 1 is Medium, 2 is High"
    )
    Access_to_Resources: int = Field(
        ..., ge=0, le=2,
        description="0 is Low, 1 is Medium, 2 is High"
    )
    Extracurricular_Activities: int = Field(
        ..., ge=0, le=1,
        description="0 is No, 1 is Yes"
    )
    Previous_Scores: int = Field(
        ..., ge=0, le=100,
        description="Previous exam score, between 0 and 100"
    )
    Motivation_Level: int = Field(
        ..., ge=0, le=2,
        description="0 is Low, 1 is Medium, 2 is High"
    )
    Internet_Access: int = Field(
        ..., ge=0, le=1,
        description="0 is No, 1 is Yes"
    )
    Tutoring_Sessions: int = Field(
        ..., ge=0, le=8,
        description="Number of tutoring sessions per week, between 0 and 8"
    )
    Family_Income: int = Field(
        ..., ge=0, le=2,
        description="0 is Low, 1 is Medium, 2 is High"
    )
    Teacher_Quality: int = Field(
        ..., ge=0, le=2,
        description="0 is Low, 1 is Medium, 2 is High"
    )
    Peer_Influence: int = Field(
        ..., ge=0, le=2,
        description="0 is Negative, 1 is Neutral, 2 is Positive"
    )
    Learning_Disabilities: int = Field(
        ..., ge=0, le=1,
        description="0 is No, 1 is Yes"
    )
    Parental_Education_Level: int = Field(
        ..., ge=0, le=2,
        description="0 is High School, 1 is College, 2 is Postgraduate"
    )
    Distance_from_Home: int = Field(
        ..., ge=0, le=2,
        description="0 is Far, 1 is Moderate, 2 is Near"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "Hours_Studied": 25,
                "Attendance": 85,
                "Parental_Involvement": 2,
                "Access_to_Resources": 2,
                "Extracurricular_Activities": 1,
                "Previous_Scores": 78,
                "Motivation_Level": 2,
                "Internet_Access": 1,
                "Tutoring_Sessions": 3,
                "Family_Income": 1,
                "Teacher_Quality": 2,
                "Peer_Influence": 2,
                "Learning_Disabilities": 0,
                "Parental_Education_Level": 1,
                "Distance_from_Home": 2
            }
        }


# ----------------------------------------------------------------
# GET / health check
# ----------------------------------------------------------------
@app.get("/")
def root():
    return {
        "message": "Student Exam Score Prediction API is running",
        "docs": "/docs"
    }


# ----------------------------------------------------------------
# POST /predict
# takes one student record, scales it the same way training data
# was scaled, returns the predicted exam score
# ----------------------------------------------------------------
@app.post("/predict")
def predict(student: StudentInput):
    try:
        input_df     = pd.DataFrame([student.dict()])[feature_names]
        input_scaled = scaler.transform(input_df)
        prediction   = model.predict(input_scaled)[0]
        score        = round(float(np.clip(prediction, 0, 100)), 2)

        return {
            "predicted_exam_score": score,
            "input_received": student.dict()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ----------------------------------------------------------------
# POST /retrain
# upload a new CSV to retrain the model on fresh data
# the CSV must have the same columns as the original dataset
# this is how the model stays up to date when new data comes in
# ----------------------------------------------------------------
@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        new_df   = pd.read_csv(io.StringIO(contents.decode("utf-8")))

        required = feature_names + ["Exam_Score"]
        missing  = [c for c in required if c not in new_df.columns]
        if missing:
            raise HTTPException(
                status_code=400,
                detail=f"These columns are missing from your file: {missing}"
            )

        X_new      = new_df[feature_names]
        y_new      = new_df["Exam_Score"]
        new_scaler = StandardScaler()
        X_scaled   = new_scaler.fit_transform(X_new)
        model.fit(X_scaled, y_new)

        with open(BEST_MODEL_PATH, "wb") as f: pickle.dump(model, f)
        with open(SCALER_PATH, "wb") as f: pickle.dump(new_scaler, f)

        globals()["model"]  = model
        globals()["scaler"] = new_scaler

        return {
            "message": "Model retrained successfully on new data",
            "rows_used": len(new_df)
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
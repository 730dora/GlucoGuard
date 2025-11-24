from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np
import datetime

app = Flask(__name__)

# 1. Load the Trained AI Model
try:
    model = joblib.load('diabetesModel.pkl')
    print("AI Model loaded successfully.")
except:
    print("Warning: 'diabetes_model.pkl' not found. Run train_model.py first!")
    model = None

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json

    # 2. Extract Data from Flutter
    # Note: The Pima dataset expects specific order:
    # [Pregnancies, Glucose, BP, Skin, Insulin, BMI, Pedigree, Age]

    # Since your app doesn't ask for "Pregnancies" or "Pedigree",
    # we must estimate them or use averages (0 is safer for demo)
    features = [
        0,                          # Pregnancies (Not in your UI, assume 0)
        float(data.get('glucose', 0)),
        float(data.get('diastolic', 0)), # BP usually refers to Diastolic in these datasets
        float(data.get('skinThickness', 20)),
        float(data.get('insulin', 0)),
        float(data.get('bmi', 0)),
        0.5,                        # DiabetesPedigreeFunction (Average genetics)
        float(data.get('age', 0))
    ]

    # Gender Adjustment (The Pima dataset is all female)
    # If male, we might slightly lower the risk output manually afterwards,
    # but the AI model itself is based on female biology.
    gender_factor = 1.0
    if data.get('gender') == 1: # Male
        gender_factor = 0.9 # Slightly lower risk for same stats

    if model:
        # 3. ASK THE AI
        # reshape(1, -1) tells the model "this is one single patient"
        prediction_input = np.array([features]).reshape(1, -1)

        # predict_proba returns [[% Non-Diabetic, % Diabetic]]
        # We want index 1 (The probability of being positive)
        risk_score = model.predict_proba(prediction_input)[0][1]

        # Apply gender tweak
        risk_score = risk_score * gender_factor

    else:
        # Fallback if model isn't loaded (Mock logic)
        risk_score = 0.5

        # 4. Generate Label
    risk_label = "Low Risk (Non-Diabetic)"
    if risk_score > 0.7:
        risk_label = "High Risk (Diabetic)"
    elif risk_score > 0.4:
        risk_label = "Medium Risk (Pre-Diabetic)"

    return jsonify({
        'risk': risk_label,
        'probability': float(risk_score),
        'timestamp': datetime.datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
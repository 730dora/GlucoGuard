from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np
import datetime

app = Flask(__name__)

# load the Trained AI Model
try:
    model = joblib.load('diabetesModel.pkl')
    print("AI Model loaded successfully.")
except:
    print("Warning: 'diabetes_model.pkl' not found. Run train_model.py first!")
    model = None

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json

    # Extract Data from Flutter
    # Note: The Pima dataset expects specific order:
    # [Pregnancies, Glucose, BP, Skin, Insulin, BMI, Pedigree, Age]

    # we do not have "pregnancies" or "pedigree" like the csv so we estimated
    # 0 is the safe option or average
    features = [
        0,                          # Pregnancies
        float(data.get('glucose', 0)),
        float(data.get('diastolic', 0)), # BP is Diastolic in these datasets
        float(data.get('skinThickness', 20)),
        float(data.get('insulin', 0)),
        float(data.get('bmi', 0)),
        0.5,                        # DiabetesPedigreeFunction
        float(data.get('age', 0))
    ]

    #the AI is based purely on female cause Pima is like that so for male we slightly lower the risk
    gender_factor = 1.0
    if data.get('gender') == 1: # male
        gender_factor = 0.9

      required_fields = ['glucose','bmi','age','systolic','diastolic','insulin','skinThickness','gender']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing field: {field}'}), 400
        try:
            val = float(data[field])
        except (ValueError, TypeError):
            return jsonify({'error': f'Invalid value for {field}, must be a number'}), 400
    # optionally: check ranges, e.g. if val < 0 or outside plausible bounds
    # then proceed to prediction

    if model:
        # here we ask the AI
        # reshape(1, -1) = "one patient"
        prediction_input = np.array([features]).reshape(1, -1)

        # predict_proba returns [[% Non-Diabetic, % Diabetic]]
        # index 1 is the probability of being positive
        risk_score = model.predict_proba(prediction_input)[0][1]

        # gender tweak
        risk_score = risk_score * gender_factor

    else:
        # for when the model is not loaded (if)
        risk_score = 0.5

        # label generator
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

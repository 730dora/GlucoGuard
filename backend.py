from flask import Flask, request, jsonify
import joblib
import pandas as pd
import numpy as np
import datetime
import os
import math
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Configuration from environment
MODEL_PATH = os.getenv('GLUCOGUARD_MODEL', 'diabetesModel.pkl')
PORT = int(os.getenv('GLUCOGUARD_PORT', 5000))

# Request size limit: 1MB to prevent DoS attacks
app.config['MAX_CONTENT_LENGTH'] = 1024 * 1024  # 1MB

# load the Trained AI Model
try:
    model = joblib.load(MODEL_PATH)
    print(f"AI Model loaded successfully from {MODEL_PATH}.")
except Exception as e:
    print(f"Warning: could not load model from {MODEL_PATH}: {e}")
    model = None

@app.errorhandler(413)
def request_entity_too_large(error):
    return jsonify({'error': 'Request payload too large'}), 413

@app.route('/predict', methods=['POST'])
def predict():
    # Validate JSON structure
    if not request.is_json:
        return jsonify({'error': 'Invalid request format. Expected JSON.'}), 400
    
    try:
        data = request.get_json() or {}
    except Exception:
        return jsonify({'error': 'Invalid JSON format'}), 400

    # Server-side validation of expected numeric fields and ranges
    def _validate_predict_payload(payload):
        if not isinstance(payload, dict):
            raise ValueError('Invalid input format')
        
        # Limit payload size (prevent DoS with too many fields)
        if len(payload) > 20:
            raise ValueError('Too many input fields')
        
        schema = {
            'glucose': (0.0, 1000.0),
            'diastolic': (0.0, 300.0),
            'skinThickness': (0.0, 100.0),
            'insulin': (0.0, 2000.0),
            'bmi': (0.0, 200.0),
            'age': (0.0, 130.0),
            'gender': (0.0, 1.0)
        }
        cleaned = {}
        for key, (lo, hi) in schema.items():
            if key in payload and payload[key] is not None:
                try:
                    v = float(payload[key])
                except (TypeError, ValueError):
                    raise ValueError(f"Invalid value for {key}")
                
                # Check for NaN and Infinity
                if math.isnan(v) or math.isinf(v):
                    raise ValueError(f"Invalid value for {key}")
                
                # Range validation
                if not (lo <= v <= hi):
                    raise ValueError(f"Value out of valid range")
                
                cleaned[key] = v
            else:
                cleaned[key] = None
        return cleaned

    try:
        cleaned = _validate_predict_payload(data)
    except ValueError as e:
        # Sanitize error message - don't leak internal details
        return jsonify({'error': 'Invalid input data'}), 400
    except Exception as e:
        # Generic error for unexpected exceptions
        return jsonify({'error': 'Processing error occurred'}), 500

    # Build feature vector expected by the trained model
    features = [
        0,  # pregnancies (estimated)
        cleaned.get('glucose') or 0.0,
        cleaned.get('diastolic') or 0.0,
        cleaned.get('skinThickness') or 20.0,
        cleaned.get('insulin') or 0.0,
        cleaned.get('bmi') or 0.0,
        0.5,  # DiabetesPedigreeFunction (estimated)
        cleaned.get('age') or 0.0
    ]

    gender = cleaned.get('gender')
    gender_factor = 0.9 if gender == 1.0 else 1.0

    if model is not None:
        prediction_input = np.array([features]).reshape(1, -1)
        try:
            risk_score = float(model.predict_proba(prediction_input)[0][1])
            # Validate the prediction result
            if math.isnan(risk_score) or math.isinf(risk_score):
                risk_score = 0.5
        except Exception:
            # fallback if model can't provide proba
            risk_score = float(model.predict(prediction_input)[0]) if hasattr(model, 'predict') else 0.5
            if math.isnan(risk_score) or math.isinf(risk_score):
                risk_score = 0.5
        risk_score = max(0.0, min(1.0, risk_score * gender_factor))
    else:
        risk_score = 0.5

    if risk_score > 0.7:
        risk_label = "High Risk (Diabetic)"
    elif risk_score > 0.4:
        risk_label = "Medium Risk (Pre-Diabetic)"
    else:
        risk_label = "Low Risk (Non-Diabetic)"

    return jsonify({
        'risk': risk_label,
        'probability': float(risk_score),
        'timestamp': datetime.datetime.now().isoformat()
    })


@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({'status': 'ok', 'message': 'Backend reachable', 'timestamp': datetime.datetime.now().isoformat()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
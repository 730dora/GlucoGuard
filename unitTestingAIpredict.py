import unittest
import json
from backend import app

class TestDiabetesPrediction(unittest.TestCase):

    def setUp(self):
        # fake server for testing
        self.app = app.test_client()
        self.app.testing = True

    def test_prediction_api_online(self):
        """Test if the API endpoint returns a 200 OK and valid JSON"""
        # Mock data for a healthy person (female)
        payload = {
            "glucose": 85,
            "bmi": 22.0,
            "age": 25,
            "gender": 0, # female
            "insulin": 80,
            "skinThickness": 20,
            "systolic": 110,
            "diastolic": 70
        }

        # fake POST request sent
        response = self.app.post('/predict',
                                 data=json.dumps(payload),
                                 content_type='application/json')

        data = json.loads(response.data)

        # the test
        self.assertEqual(response.status_code, 200)
        self.assertIn('risk', data)
        self.assertIn('probability', data)
        print("\n✅ API Connection Test Passed!")

    def test_high_risk_logic(self):
        """Test if high values actually trigger High Risk"""
        payload = {
            "glucose": 200, # very high
            "bmi": 40.0,    # very high
            "age": 60,
            "gender": 1     # male
        }

        response = self.app.post('/predict',
                                 data=json.dumps(payload),
                                 content_type='application/json')

        data = json.loads(response.data)

        # here a high risk is expected
        self.assertTrue(data['probability'] > 0.6)
        print(f"✅ High Risk Logic Test Passed! (Prob: {data['probability']})")

if __name__ == '__main__':
    unittest.main()
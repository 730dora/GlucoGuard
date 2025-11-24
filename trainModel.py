import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib

# 1. Load the "Real Reality" Data
# Make sure diabetes.csv is in the same folder!
try:
    data = pd.read_csv('diabetes.csv')
    print("Dataset loaded successfully.")
except FileNotFoundError:
    print("Error: 'diabetes.csv' not found. Please download it first.")
    exit()

# 2. Prepare the Data
# X = The Inputs (Glucose, BMI, Age, etc.)
# y = The Answer (1 = Diabetic, 0 = Non-Diabetic)
X = data.drop('Outcome', axis=1)
y = data['Outcome']

# Split data: 80% for training, 20% to test accuracy
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 3. Train the Model (The "AI" part)
# We use RandomForest because it handles complex medical data very well
model = RandomForestClassifier(n_estimators=100, random_state=42)
print("Training the AI model...")
model.fit(X_train, y_train)

# 4. Test Accuracy
predictions = model.predict(X_test)
accuracy = accuracy_score(y_test, predictions)
print(f"Model Training Complete!")
print(f"Accuracy on test data: {accuracy * 100:.2f}%")

# 5. Save the "Brain" to a file
joblib.dump(model, 'diabetesModel.pkl')
print("Model saved as 'diabetesModel.pkl'")
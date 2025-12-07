import pandas as pd
import joblib
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, StratifiedKFold, RandomizedSearchCV
from sklearn.metrics import roc_auc_score, accuracy_score
import numpy as np


# Load dataset
try:
    data = pd.read_csv('diabetes.csv')
    print("Dataset loaded successfully.")
except FileNotFoundError:
    print("Error: 'diabetes.csv' not found. Please download it first.")
    raise


# Prepare X/y
X = data.drop('Outcome', axis=1)
y = data['Outcome']

# Simple feature engineering: pulse pressure if both present
if {'systolic', 'diastolic'}.issubset(X.columns):
    X['pulse_pressure'] = X['systolic'] - X['diastolic']

# Holdout split
X_train, X_hold, y_train, y_hold = train_test_split(X, y, test_size=0.15, stratify=y, random_state=42)

# Build pipeline: impute -> scale -> classifier
pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler()),
    ('clf', RandomForestClassifier(random_state=42))
])

param_dist = {
    'clf__n_estimators': [100, 200, 400],
    'clf__max_depth': [None, 6, 12, 20],
    'clf__min_samples_split': [2, 5, 10],
    'clf__min_samples_leaf': [1, 2, 4],
    'clf__class_weight': [None, 'balanced']
}

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

search = RandomizedSearchCV(
    pipeline,
    param_distributions=param_dist,
    n_iter=12,
    cv=cv,
    scoring='roc_auc',
    n_jobs=-1,
    random_state=42,
    verbose=2
)

print("Starting hyperparameter search (this may take a few minutes)...")
search.fit(X_train, y_train)

print(f"Best CV ROC AUC: {search.best_score_:.4f}")
best = search.best_estimator_

# Evaluate on holdout
proba = best.predict_proba(X_hold)[:, 1]
pred = best.predict(X_hold)
print(f"Holdout ROC AUC: {roc_auc_score(y_hold, proba):.4f}")
print(f"Holdout Accuracy: {accuracy_score(y_hold, pred):.4f}")

# Save the model
joblib.dump(best, 'diabetesModel.pkl')
print("Saved best model to 'diabetesModel.pkl'")
import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.calibration import CalibratedClassifierCV
from sklearn.metrics import brier_score_loss, roc_auc_score
import shutil

# Load data
try:
    data = pd.read_csv('diabetes.csv')
    print('Dataset loaded successfully.')
except FileNotFoundError:
    print("Error: 'diabetes.csv' not found.")
    raise

X = data.drop('Outcome', axis=1)
y = data['Outcome']

# Split using same params as training script (holdout 15%)
X_train, X_hold, y_train, y_hold = train_test_split(X, y, test_size=0.15, stratify=y, random_state=42)

# Load existing model
model_path = 'diabetesModel.pkl'
cal_model_path = 'diabetesModel_calibrated.pkl'
backup_path = 'diabetesModel_uncalibrated_backup.pkl'

print(f'Loading model from {model_path}...')
model = joblib.load(model_path)
print('Model loaded.')

# Evaluate before calibration
try:
    proba_before = model.predict_proba(X_hold)[:, 1]
    auc_before = roc_auc_score(y_hold, proba_before)
    brier_before = brier_score_loss(y_hold, proba_before)
    print(f'Before calibration - Holdout AUC: {auc_before:.4f}, Brier score: {brier_before:.4f}')
except Exception as e:
    print('Warning: could not compute probabilities for the loaded model:', e)

# Calibrate using holdout (cv='prefit')
print('Fitting CalibratedClassifierCV (method=sigmoid) on holdout...')
# sklearn versions differ in parameter name: use 'estimator' if 'base_estimator' unsupported
try:
    calibrator = CalibratedClassifierCV(base_estimator=model, method='sigmoid', cv='prefit')
except TypeError:
    calibrator = CalibratedClassifierCV(estimator=model, method='sigmoid', cv='prefit')
calibrator.fit(X_hold, y_hold)

# Evaluate after calibration
proba_after = calibrator.predict_proba(X_hold)[:, 1]
auc_after = roc_auc_score(y_hold, proba_after)
brier_after = brier_score_loss(y_hold, proba_after)
print(f'After calibration - Holdout AUC: {auc_after:.4f}, Brier score: {brier_after:.4f}')

# Backup old model and save calibrated
print('Backing up original model...')
shutil.copyfile(model_path, backup_path)
print(f'Backup saved to {backup_path}')

print('Saving calibrated model...')
joblib.dump(calibrator, cal_model_path)
# Also overwrite main model file
joblib.dump(calibrator, model_path)
print(f'Calibrated model saved to {cal_model_path} and replaced {model_path}')

print('Calibration complete.')

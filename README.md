# interdisciplinary

What we changed: 
1. Added a small feature (pulse_pressure) if systolic/diastolic exist.
2. Training pipeline: median imputation + StandardScaler + RandomForest inside an sklearn Pipeline.
3. Hyperparameter tuning using RandomizedSearchCV with StratifiedKFold and ROC-AUC scoring.
4. Calibrated predicted probabilities using CalibratedClassifierCV (Platt scaling).
5. Saved the calibrated model as diabetesModel.pkl (backup of uncalibrated model preserved).
6. Accepts partial input with sensible defaults.


Team
1. Petre Teodora Maria
2. Nedelcu-Holtea Catalina
3. Florea Ioana Ana Maria 

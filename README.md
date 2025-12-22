# GlucoGuard - AI-Powered Diabetes Risk Prediction System

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)
![Python](https://img.shields.io/badge/Python-3.9+-green.svg)

**GlucoGuard** is an interdisciplinary mobile health application designed to predict the risk of diabetes in patients using Machine Learning. It features a cross-platform mobile interface (Flutter), secure cloud database (Firebase), and an AI-powered backend (Python/Flask) with comprehensive input sanitization and Docker support.

---

## Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Stakeholders](#stakeholders)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Docker Deployment](#docker-deployment)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Environment Variables](#environment-variables)
- [Security Features](#security-features)
- [Scripts Reference](#scripts-reference)
- [Contributors](#contributors)

---

## Overview

GlucoGuard is a **fair, accessible diabetes risk prediction platform** designed to help individuals assess their diabetes risk using AI-powered analysis. Unlike traditional medical consultations that may be expensive or inaccessible, GlucoGuard provides:

- **Free AI-powered risk assessment** using machine learning models
- **Privacy-focused** - user data stored securely in Firebase
- **Offline capabilities** - works even when backend is unreachable
- **Cross-platform** - runs on Android, iOS, and Web
- **Real-time predictions** with visual risk indicators

The platform uses a trained Random Forest Classifier model based on the Pima Indians Diabetes Database, re-trained for feature consistency and accuracy.

---

## Problem Statement

**Current Challenges:**
- **Medical Consultations:** Expensive and time-consuming for routine risk assessments
- **Accessibility:** Limited access to healthcare professionals in remote areas
- **Data Privacy:** Concerns about sharing sensitive health information
- **Lack of Awareness:** Many people don't know their diabetes risk until symptoms appear

**Solution:**
GlucoGuard provides an accessible, privacy-focused platform that allows users to:
- Assess diabetes risk from the comfort of their home
- Track prediction history over time
- Make informed decisions about lifestyle changes
- Access professional-grade AI analysis without cost barriers

---

## Stakeholders

- **Primary Users:** Individuals seeking to assess their diabetes risk
- **Healthcare Providers:** Can recommend the app for patient self-assessment
- **Researchers:** Open to collaboration for model improvement
- **Developers:** Contributing to open-source health technology

---

## Architecture

The system follows a modern client-server architecture with offline capabilities and comprehensive security measures.

### System Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer                              │
│  Flutter Mobile App (Android/iOS/Web)                       │
│  - User Authentication (Firebase Auth)                      │
│  - Input Forms with Validation                              │
│  - Real-time Risk Visualization (Gauge Charts)              │
│  - Prediction History Management                            │
│  - Offline Fallback Logic                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP/HTTPS
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    API Layer                                 │
│  Python Flask REST API (Port 5000)                         │
│  - /predict - AI Model Predictions                          │
│  - /ping - Health Check                                      │
│  - Input Sanitization & Validation                           │
│  - Error Handling                                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                 Business Logic Layer                         │
│  - JWT Authentication (Firebase)                            │
│  - Input Sanitization (XSS, DoS Prevention)                 │
│  - Range Validation                                         │
│  - NaN/Infinity Checks                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    Data Layer                                │
│  - Prisma ORM (via Firebase SDK)                            │
│  - Cloud Firestore (User Profiles, Predictions)              │
│  - Local Storage (Offline Data)                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                 AI Model Layer                               │
│  - Scikit-Learn Random Forest Classifier                     │
│  - Trained on Pima Indians Diabetes Database                 │
│  - Model File: diabetesModel.pkl                            │
└─────────────────────────────────────────────────────────────┘
```

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Mobile Device (Flutter App)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Android    │  │     iOS      │  │     Web      │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │      Firebase Services               │
          │  - Authentication                    │
          │  - Cloud Firestore                   │
          └──────────────────┬──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │   Docker Container (Backend)         │
          │  - Flask API (Port 5000)             │
          │  - AI Model (diabetesModel.pkl)      │
          │  - Input Validation                  │
          └─────────────────────────────────────┘
```

*All services can run in Docker containers for consistent deployment*

---

## Tech Stack

### Frontend
- **Framework:** Flutter 3.9.2 (Dart)
- **UI Components:** Material Design
- **Charts:** fl_chart 0.68.0
- **State Management:** Flutter StatefulWidget
- **Local Storage:** shared_preferences 2.2.2

### Backend
- **Language:** Python 3.9+
- **Framework:** Flask 3.1.2
- **ML Library:** Scikit-Learn 1.6.1
- **Data Processing:** Pandas 2.3.3, NumPy 2.0.2
- **Model Persistence:** Joblib 1.5.3

### Database & Authentication
- **Service:** Google Firebase
- **Authentication:** Firebase Auth (Email/Password)
- **Database:** Cloud Firestore
- **Real-time Updates:** Firestore Streams

### Validation & Security
- **Input Sanitization:** Custom InputSanitizer utility
- **Email Validation:** RFC 5322 compliant regex
- **Numeric Validation:** Range checks, NaN/Infinity protection
- **Request Limits:** 1MB payload limit (DoS prevention)

### Deployment
- **Containerization:** Docker, Docker Compose
- **Base Image:** Python 3.9-slim
- **Health Checks:** Automated container health monitoring

---

## Features

### Core Features
- ✅ **AI-Powered Risk Prediction** - Machine learning model analyzes health metrics
- ✅ **User Authentication** - Secure login/signup with Firebase Auth
- ✅ **Prediction History** - Track all predictions with timestamps
- ✅ **Visual Risk Indicators** - Gauge charts and percentage displays
- ✅ **Offline Mode** - Local fallback calculations when backend is unreachable
- ✅ **Cross-Platform** - Android, iOS, and Web support

### Security Features
- ✅ **Input Sanitization** - XSS prevention, DoS protection
- ✅ **Range Validation** - Ensures valid medical data
- ✅ **Type Safety** - NaN/Infinity checks prevent invalid calculations
- ✅ **Error Sanitization** - Prevents information leakage
- ✅ **Request Size Limits** - Prevents resource exhaustion attacks

### User Experience
- ✅ **Intuitive Forms** - Clear input fields with validation
- ✅ **Real-time Feedback** - Immediate validation messages
- ✅ **History Tracking** - View past predictions with details
- ✅ **Profile Management** - User profile with gender and preferences

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.2 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
- **Python** (3.9 or higher)
  - Download from: https://www.python.org/downloads/
- **Docker Desktop** (Optional, for containerized deployment)
  - Download from: https://www.docker.com/products/docker-desktop
- **Firebase Account** (for authentication and database)
  - Sign up at: https://firebase.google.com/

---

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/730dora/GlucoGuard.git
cd GlucoGuard
```

### Step 2: Backend Setup

1. **Install Python Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Train the AI Model** (Optional - model file included):
   ```bash
   python trainModel.py
   ```
   This generates `diabetesModel.pkl` (already included in repo)

3. **Configure Environment Variables:**
   Create a `.env` file (optional):
   ```env
   GLUCOGUARD_MODEL=diabetesModel.pkl
   GLUCOGUARD_PORT=5000
   ```

### Step 3: Frontend Setup

1. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   - Add your `google-services.json` (Android) to `android/app/`
   - Configure Firebase for iOS if needed
   - Update `lib/firebase_options.dart` with your Firebase config

3. **Update Backend URL:**
   Edit `assets/config.json`:
   ```json
   {
     "backend_url": "http://YOUR_LOCAL_IP:5000",
     "backend_url_public": "https://your-ngrok-url.ngrok-free.dev"
   }
   ```

---

## Running the Application

### Option 1: Manual Setup

**Terminal 1 - Start Backend:**
```bash
python backend.py
```
Backend will start on `http://localhost:5000`

**Terminal 2 - Run Flutter App:**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome

# For Windows
flutter run -d windows
```

### Option 2: Docker Compose (Recommended)

**Start Backend with Docker:**
```bash
docker compose up -d
```

**Run Flutter App:**
```bash
flutter run
```

**View Backend Logs:**
```bash
docker compose logs -f backend
```

**Stop Backend:**
```bash
docker compose down
```

### Option 3: Using Helper Scripts

**Windows PowerShell:**
```powershell
# Start backend
.\run_project.ps1

# Or with ngrok for mobile testing
.\start_backend_with_ngrok.ps1
```

---

## Docker Deployment

### Quick Start

```bash
# Build and start
docker compose up -d

# View logs
docker compose logs -f backend

# Stop
docker compose down
```

### Custom Configuration

Edit `docker-compose.yml` to customize:
- Port mapping
- Environment variables
- Volume mounts
- Health check intervals

For detailed Docker documentation, see [README_DOCKER.md](README_DOCKER.md)

---

## API Documentation

The backend exposes RESTful endpoints for diabetes risk prediction.

### **POST** `/predict`

Calculates diabetes risk probability based on physiological inputs.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "glucose": 120.0,
  "bmi": 24.5,
  "age": 35.0,
  "diastolic": 75.0,
  "insulin": 80.0,
  "skinThickness": 20.0,
  "gender": 1.0
}
```

**Field Descriptions:**
| Field | Type | Range | Description |
|-------|------|-------|-------------|
| `glucose` | float | 0.0 - 1000.0 | Plasma glucose concentration (mg/dL) |
| `bmi` | float | 0.0 - 200.0 | Body Mass Index |
| `age` | float | 0.0 - 130.0 | Age in years |
| `diastolic` | float | 0.0 - 300.0 | Diastolic blood pressure (mmHg) |
| `insulin` | float | 0.0 - 2000.0 | Insulin level (mu U/ml) |
| `skinThickness` | float | 0.0 - 100.0 | Triceps skin fold thickness (mm) |
| `gender` | float | 0.0 or 1.0 | 0 = Female, 1 = Male |

**Response (200 OK):**
```json
{
  "risk": "Low Risk (Non-Diabetic)",
  "probability": 0.12,
  "timestamp": "2025-12-21T00:00:00.000000"
}
```

**Risk Categories:**
- `Low Risk (Non-Diabetic)`: probability < 0.4
- `Medium Risk (Pre-Diabetic)`: 0.4 ≤ probability < 0.7
- `High Risk (Diabetic)`: probability ≥ 0.7

**Error Responses:**

**400 Bad Request** - Invalid input:
```json
{
  "error": "Invalid input data"
}
```

**413 Payload Too Large** - Request exceeds 1MB:
```json
{
  "error": "Request payload too large"
}
```

### **GET** `/ping`

Health check endpoint to verify backend availability.

**Response (200 OK):**
```json
{
  "status": "ok",
  "message": "Backend reachable",
  "timestamp": "2025-12-21T00:00:00.000000"
}
```

---

## Testing

### Backend Tests

**Run Unit Tests:**
```bash
python unitTestingAIpredict.py
```

**Test API Endpoints:**
```bash
# Test ping
curl http://localhost:5000/ping

# Test prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"glucose": 120, "bmi": 24.5, "age": 35, "diastolic": 75, "insulin": 80, "skinThickness": 20, "gender": 1.0}'
```

### Frontend Tests

**Run Flutter Tests:**
```bash
flutter test
```

**Test Coverage:**
```bash
flutter test --coverage
```

### Input Validation Tests

The project includes comprehensive input sanitization tests covering:
- Invalid data types
- Out-of-range values
- NaN/Infinity values
- Missing required fields
- XSS prevention
- DoS prevention

---

## Environment Variables

| Variable | Description | Default Value | Required |
|----------|-------------|--------------|----------|
| `GLUCOGUARD_MODEL` | Path to trained model file | `diabetesModel.pkl` | No |
| `GLUCOGUARD_PORT` | Backend server port | `5000` | No |

**Example `.env` file:**
```env
GLUCOGUARD_MODEL=diabetesModel.pkl
GLUCOGUARD_PORT=5000
```

---

## Security Features

### Input Sanitization

**Backend:**
- ✅ NaN/Infinity value checks
- ✅ Range validation for all numeric inputs
- ✅ Request size limits (1MB max)
- ✅ JSON structure validation
- ✅ Sanitized error messages

**Frontend:**
- ✅ Username sanitization (XSS prevention)
- ✅ Email validation (RFC 5322 compliant)
- ✅ Password strength requirements
- ✅ Numeric range validation
- ✅ Input length limits

**API Service:**
- ✅ Pre-validation before backend calls
- ✅ UID format validation
- ✅ Type safety checks

### Security Best Practices

- All user inputs are validated and sanitized
- Firebase Auth handles secure authentication
- Cloud Firestore provides encrypted data storage
- Docker containers isolate backend services
- Health checks monitor service availability

---

## Scripts Reference

### Backend Scripts

| Script | Description |
|--------|-------------|
| `python backend.py` | Start Flask backend server |
| `python trainModel.py` | Train the AI model (generates .pkl file) |
| `python calibrate_model.py` | Calibrate model predictions |
| `python unitTestingAIpredict.py` | Run unit tests |

### Docker Scripts

| Command | Description |
|---------|-------------|
| `docker compose up` | Start all services |
| `docker compose up -d` | Start in background |
| `docker compose down` | Stop all services |
| `docker compose logs -f backend` | View backend logs |
| `docker compose restart backend` | Restart backend service |

### Flutter Scripts

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app on connected device |
| `flutter build apk` | Build Android APK |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code for issues |

### Helper Scripts (Windows)

| Script | Description |
|--------|-------------|
| `.\run_project.ps1` | Start backend with helper messages |
| `.\start_backend_with_ngrok.ps1` | Start backend with ngrok tunnel |
| `.\start_backend_public.ps1` | Start backend with serveo tunnel |
| `.\install_to_phone.ps1` | Install APK to connected Android device |

---

## Contributors

- **Petre Teodora Maria**
- **Nedelcu-Holtea Cătălina**
- **Florea Ioana Ana Maria**

---

## Acknowledgments

- **Dataset:** Pima Indians Diabetes Database
- **ML Framework:** Scikit-Learn
- **Mobile Framework:** Flutter
- **Backend Framework:** Flask
- **Cloud Services:** Google Firebase

---

## Support

For issues, questions, or contributions, please open an issue on the [GitHub repository](https://github.com/730dora/GlucoGuard).

---

**Note:** This application is for educational and informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions regarding a medical condition.



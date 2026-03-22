# Learnvis - Interactive Physics Simulation Platform

Learnvis is a full-stack educational platform built with Flutter (Frontend) and FastAPI (Backend), designed for real-time physics simulations with a 3-panel UI.

## 🧱 Tech Stack
- **Frontend:** Flutter Web, CustomPainter, Riverpod, fl_chart
- **Backend:** Python FastAPI, SQLModel
- **Database:** PostgreSQL

## 📂 Project Structure
- `/backend`: FastAPI app, database models, and API endpoints.
- `/frontend_flutter`: Flutter web app with modular simulation logic.
- `/database`: SQL schema and initialization scripts.

## 🚀 Setup Guide

### Backend
1. `cd backend`
2. `pip install fastapi uvicorn sqlmodel psycopg2-binary`
3. Set `DATABASE_URL` environment variable.
4. Run `uvicorn main:app --reload`

### Frontend
1. `cd frontend_flutter`
2. `flutter pub get`
3. `flutter run -d chrome`

## 🧪 Simulation Modules
- **Mechanics:** Projectile Motion (Implemented)
- **Optics:** Mirror & Lens Simulation (Planned)
- **Electricity:** Circuit Builder (Planned)
- **Waves:** Wave Interference (Planned)
- **Modern Physics:** Photoelectric Effect (Planned)

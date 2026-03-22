# LearnViz - Interactive Physics Simulation Platform

LearnViz is a comprehensive, full-stack educational platform designed to make physics intuitive through interactive simulations. Built with **Flutter Web** and **FastAPI**, it provides a real-time, 3-panel learning experience where students can experiment with parameters, visualize outcomes, and master theoretical concepts.

---

## 🌟 Key Features

### 🎮 Interactive Simulations
Explore a wide range of physics topics with high-fidelity simulations:
- **Mechanics:** Projectile Motion (Trajectory, Range, Height calculations).
- **Optics:** Snell's Law (Refraction & Total Internal Reflection), Mirror and Lens equations.
- **Electricity:** Ohm's Law and basic circuit parameters.
- **Waves:** Superposition and Wave Interference visualization.
- **Modern Physics:** Photoelectric Effect (Work function, Kinetic energy, Threshold frequency).

### 📖 Integrated Learning
Each simulation is paired with:
- **Real-time Parameters:** Adjust variables like velocity, angle, refractive index, or frequency.
- **Formula Bank:** View the mathematical foundations in LaTeX.
- **Interactive Quizzes:** Test your knowledge with experiment-specific questions.
- **Progress Tracking:** Secure user accounts to save completed modules and quiz scores.

### 💻 Modern Tech Stack
- **Frontend:** Flutter Web
  - **State Management:** Riverpod
  - **Navigation:** go_router
  - **Networking:** Dio
  - **Visuals:** fl_chart, flutter_animate, CustomPainter (Engine)
- **Backend:** Python FastAPI
  - **ORM:** SQLModel (SQLAlchemy + Pydantic)
  - **Database:** PostgreSQL
  - **Security:** JWT Authentication, Bcrypt password hashing

---

## 🏗 Database Schema

The platform uses a relational schema designed to support hierarchical educational content:
- **Module:** High-level categories (e.g., Mechanics, Optics).
- **Experiment:** Specific simulations within a module.
- **Formula:** Mathematical expressions associated with an experiment.
- **Quiz:** Assessment questions for each simulation.
- **User:** Authentication and profile data.
- **UserProgress:** Tracks which experiments a user has completed and their quiz scores.

---

## 📂 Project Structure

```text
├── backend/                # FastAPI application
│   ├── main.py             # Entry point & API routes
│   ├── models.py           # Database models & Physics engine
│   ├── database.py         # DB connection & Session management
│   ├── routers/            # Auth and Progress tracking endpoints
│   └── venv/               # Python virtual environment
├── frontend_flutter/       # Flutter web application
│   ├── lib/
│   │   ├── features/       # Modular simulation logic (Optics, Mechanics, etc.)
│   │   ├── models/         # Physics data models
│   │   ├── services/       # API integration
│   │   └── widgets/        # Reusable UI components (GlassCard, CustomPainters)
├── database/               # SQL schema and seeding scripts
└── README.md               # You are here!
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.9+
- Flutter SDK (stable channel)
- PostgreSQL (or use SQLite for local dev by changing `DATABASE_URL`)

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt # Or manual: pip install fastapi uvicorn sqlmodel psycopg2-binary passlib[bcrypt] python-jose[cryptography]

# Set your environment variables
export DATABASE_URL="postgresql://user:password@localhost/learnviz"
# Or for SQLite: export DATABASE_URL="sqlite:///./learnviz.db"

python main.py # Runs on http://localhost:8000
```

### 2. Frontend Setup
```bash
cd frontend_flutter
flutter pub get
flutter run -d chrome --web-port 3000
```

---

## 🛠 API Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/modules` | Fetch all physics modules and their experiments |
| `POST` | `/calculate/{id}` | Perform backend physics calculations for an experiment |
| `POST` | `/auth/register` | User registration |
| `POST` | `/auth/token` | User login (JWT) |
| `GET` | `/progress` | Fetch current user's learning progress |

---

## 🤝 Contributing
Contributions are welcome! Whether it's adding a new simulation module, improving the UI, or fixing a bug, please feel free to open a PR.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

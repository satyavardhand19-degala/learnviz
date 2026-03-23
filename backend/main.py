from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
from typing import List, Dict
import json

from database import engine, init_db, get_session
from models import Module, Experiment, Formula, Quiz, User, UserProgress
from routers import auth, progress

app = FastAPI(title="Learnvis API")

# ✅ CORS (VERY IMPORTANT)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # later replace with your Vercel URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Routers
app.include_router(auth.router)
app.include_router(progress.router)


# ================================
# 🚀 STARTUP (SEED DATA)
# ================================
@app.on_event("startup")
def on_startup():
    init_db()
    with Session(engine) as session:

        # ✅ MODULES
        if not session.exec(select(Module)).first():
            modules = [
                Module(name="Mechanics", description="Motion, force, and energy.", icon="physics"),
                Module(name="Optics", description="Light and vision.", icon="light_mode"),
                Module(name="Electricity", description="Circuits and currents.", icon="bolt"),
                Module(name="Waves", description="Sound and vibration.", icon="waves"),
                Module(name="Modern Physics", description="Quantum mechanics.", icon="science")
            ]
            for m in modules:
                session.add(m)
            session.commit()

        # ✅ EXPERIMENTS
        if not session.exec(select(Experiment)).first():

            mech = session.exec(select(Module).where(Module.name == "Mechanics")).first()
            session.add(Experiment(
                module_id=mech.id,
                name="Projectile Motion",
                description="Trajectory of a moving object.",
                formula_template=r"y = v_0 \sin(\theta) t - \frac{1}{2}gt^2",
                initial_params_json=json.dumps({"angle": 45, "velocity": 20})
            ))

            optics = session.exec(select(Module).where(Module.name == "Optics")).first()
            session.add(Experiment(
                module_id=optics.id,
                name="Refraction (Snell's Law)",
                description="Bending of light.",
                formula_template=r"n_1 \sin(\theta_1) = n_2 \sin(\theta_2)",
                initial_params_json=json.dumps({"n1": 1.0, "n2": 1.5})
            ))

            elec = session.exec(select(Module).where(Module.name == "Electricity")).first()
            session.add(Experiment(
                module_id=elec.id,
                name="Ohm's Law",
                description="Voltage and current relation.",
                formula_template=r"V = IR",
                initial_params_json=json.dumps({"voltage": 12, "resistance": 10})
            ))

            waves = session.exec(select(Module).where(Module.name == "Waves")).first()
            session.add(Experiment(
                module_id=waves.id,
                name="Wave Interference",
                description="Superposition of waves.",
                formula_template=r"y = A \sin(kx - \omega t)",
                initial_params_json=json.dumps({"amplitude": 1})
            ))

            modern = session.exec(select(Module).where(Module.name == "Modern Physics")).first()
            session.add(Experiment(
                module_id=modern.id,
                name="Photoelectric Effect",
                description="Electron emission.",
                formula_template=r"KE = hf - \phi",
                initial_params_json=json.dumps({"frequency": 6e14})
            ))

            session.commit()


# ================================
# 🧠 EXISTING API (KEEP)
# ================================
@app.get("/api/modules", response_model=List[Module])
def get_modules(session: Session = Depends(get_session)):
    return session.exec(select(Module)).all()


@app.get("/api/experiments/{module_id}", response_model=List[Experiment])
def get_experiments(module_id: int, session: Session = Depends(get_session)):
    return session.exec(select(Experiment).where(Experiment.module_id == module_id)).all()


# ================================
# ✅ FRONTEND API (NEW)
# ================================

@app.get("/modules")
def frontend_modules(session: Session = Depends(get_session)):
    modules = session.exec(select(Module)).all()

    return [
        {
            "id": m.id,
            "name": m.name,
            "description": m.description,
            "icon": m.icon,
        }
        for m in modules
    ]


@app.get("/experiments")
def frontend_experiments(module: str, session: Session = Depends(get_session)):
    mod = session.exec(select(Module).where(Module.name == module)).first()

    if not mod:
        return []

    experiments = session.exec(
        select(Experiment).where(Experiment.module_id == mod.id)
    ).all()

    return [
        {
            "id": e.id,
            "title": e.name,
            "description": e.description,
            "route": map_route(e.name),
        }
        for e in experiments
    ]


# ================================
# 🔗 ROUTE MAPPING
# ================================
def map_route(name: str):
    routes = {
        "Projectile Motion": "/projectile",
        "Refraction (Snell's Law)": "/optics",
        "Ohm's Law": "/electricity",
        "Wave Interference": "/waves",
        "Photoelectric Effect": "/modern",
    }
    return routes.get(name, "/")


# ================================
# ROOT
# ================================
@app.get("/")
def root():
    return {"message": "API running 🚀"}

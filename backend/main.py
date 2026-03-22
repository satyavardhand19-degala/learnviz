from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
from typing import List, Dict
import json

from database import engine, init_db, get_session
from models import Module, Experiment, Formula, Quiz, User, UserProgress
from routers import auth, progress

app = FastAPI(title="Learnvis API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(progress.router)

@app.on_event("startup")
def on_startup():
    init_db()
    with Session(engine) as session:
        # Seed Modules if they don't exist
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
        
        # Seed Experiments if they don't exist
        if not session.exec(select(Experiment)).first():
            # Mechanics Experiments
            mech = session.exec(select(Module).where(Module.name == "Mechanics")).first()
            exp1 = Experiment(
                module_id=mech.id,
                name="Projectile Motion",
                description="Trajectory of a moving object.",
                formula_template = r"y = v_0 \sin(\theta) t - \frac{1}{2}gt^2",
                initial_params_json=json.dumps({"angle": 45, "velocity": 20, "gravity": 9.8})
            )
            session.add(exp1)
            
            exp_proj_challenge = Experiment(
                module_id=mech.id,
                name="Projectile Challenge",
                description="Hit the target by adjusting angle and velocity.",
                formula_template = r"R = \frac{v^2 \sin(2\theta)}{g}",
                initial_params_json=json.dumps({"angle": 45, "velocity": 20, "target_distance": 40})
            )
            session.add(exp_proj_challenge)

            # Optics Experiments
            optics = session.exec(select(Module).where(Module.name == "Optics")).first()
            exp2 = Experiment(
                module_id=optics.id,
                name="Refraction (Snell's Law)",
                description="Bending of light as it passes between media.",
                formula_template = r"n_1 \sin(\theta_1) = n_2 \sin(\theta_2)",
                initial_params_json=json.dumps({"n1": 1.0, "n2": 1.5, "theta1": 30})
            )
            session.add(exp2)

            exp_mirror = Experiment(
                module_id=optics.id,
                name="Mirror & Lens Simulation",
                description="Ray diagram for mirrors and lenses.",
                formula_template = r"\frac{1}{f} = \frac{1}{d_o} + \frac{1}{d_i}",
                initial_params_json=json.dumps({"focal_length": 10, "object_distance": 25, "object_height": 5})
            )
            session.add(exp_mirror)

            # Electricity Experiments
            elec = session.exec(select(Module).where(Module.name == "Electricity")).first()
            exp3 = Experiment(
                module_id=elec.id,
                name="Ohm's Law",
                description="Relationship between voltage, current, and resistance.",
                formula_template = r"V = I \times R",
                initial_params_json=json.dumps({"voltage": 12, "resistance": 10})
            )
            session.add(exp3)

            exp_circuit = Experiment(
                module_id=elec.id,
                name="Circuit Builder",
                description="Build and simulate simple circuits.",
                formula_template = r"I = \frac{V}{R_{total}}",
                initial_params_json=json.dumps({"voltage": 9, "resistance": 100})
            )
            session.add(exp_circuit)
            
            # Waves Experiments
            waves = session.exec(select(Module).where(Module.name == "Waves")).first()
            exp_waves = Experiment(
                module_id=waves.id,
                name="Wave Interference",
                description="Superposition of two waves.",
                formula_template = r"y = A_1 \sin(kx - \omega t) + A_2 \sin(kx - \omega t + \phi)",
                initial_params_json=json.dumps({"amplitude1": 1, "amplitude2": 1, "frequency1": 1, "frequency2": 1, "phase_diff": 0})
            )
            session.add(exp_waves)

            # Modern Physics Experiments
            modern = session.exec(select(Module).where(Module.name == "Modern Physics")).first()
            exp_photo = Experiment(
                module_id=modern.id,
                name="Photoelectric Effect",
                description="Emission of electrons from a metal surface.",
                formula_template = r"KE_{max} = hf - \phi",
                initial_params_json=json.dumps({"frequency": 6e14, "work_function": 2.0, "intensity": 1.0})
            )
            session.add(exp_photo)

            session.commit()
            session.refresh(exp1)

            # Seed Formulas
            formulas = [
                Formula(experiment_id=exp1.id, name="Vertical Displacement", latex_string=r"y = v_0 \sin(\theta) t - \frac{1}{2}gt^2", explanation="Vertical position at time t."),
                Formula(experiment_id=exp2.id, name="Snell's Law", latex_string=r"n_1 \sin(\theta_1) = n_2 \sin(\theta_2)", explanation="Law of refraction."),
                Formula(experiment_id=exp3.id, name="Ohm's Law", latex_string=r"V = I \times R", explanation="Relationship between V, I, R."),
                Formula(experiment_id=exp_mirror.id, name="Mirror/Lens Equation", latex_string=r"\frac{1}{f} = \frac{1}{d_o} + \frac{1}{d_i}", explanation="Relates focal length, object distance, and image distance."),
                Formula(experiment_id=exp_photo.id, name="Einstein's Photoelectric Equation", latex_string=r"KE_{max} = hf - \phi", explanation="Energy of emitted electrons."),
                Formula(experiment_id=exp_waves.id, name="Superposition Principle", latex_string=r"y_{total} = y_1 + y_2", explanation="Total displacement is the sum of individual displacements.")
            ]
            for f in formulas:
                session.add(f)
            
            # Seed Quizzes
            quizzes = [
                Quiz(experiment_id=exp1.id, question="Horizontal acceleration of a projectile?", options_json=json.dumps(["9.8 m/s²", "0 m/s²", "Variable", "Infinity"]), correct_option=1),
                Quiz(experiment_id=exp_photo.id, question="What determines the maximum KE of emitted electrons?", options_json=json.dumps(["Light intensity", "Light frequency", "Metal volume", "Exposure time"]), correct_option=1),
                Quiz(experiment_id=exp_mirror.id, question="A virtual image is always...", options_json=json.dumps(["Inverted", "Upright", "Larger", "Smaller"]), correct_option=1),
                Quiz(experiment_id=exp_waves.id, question="Constructive interference occurs when phase difference is...", options_json=json.dumps(["0°", "180°", "90°", "270°"]), correct_option=0)
            ]
            for q in quizzes:
                session.add(q)
            
            session.commit()

@app.get("/api/modules", response_model=List[Module])
def get_modules(session: Session = Depends(get_session)):
    return session.exec(select(Module)).all()

@app.get("/api/experiments/{module_id}", response_model=List[Experiment])
def get_experiments(module_id: int, session: Session = Depends(get_session)):
    return session.exec(select(Experiment).where(Experiment.module_id == module_id)).all()

@app.get("/api/experiment/{id}", response_model=Experiment)
def get_experiment(id: int, session: Session = Depends(get_session)):
    exp = session.get(Experiment, id)
    if not exp:
        raise HTTPException(status_code=404, detail="Experiment not found")
    return exp

@app.get("/api/formulas/{experiment_id}", response_model=List[Formula])
def get_formulas(experiment_id: int, session: Session = Depends(get_session)):
    return session.exec(select(Formula).where(Formula.experiment_id == experiment_id)).all()

@app.get("/api/quizzes/{experiment_id}", response_model=List[Quiz])
def get_quizzes(experiment_id: int, session: Session = Depends(get_session)):
    return session.exec(select(Quiz).where(Quiz.experiment_id == experiment_id)).all()

@app.post("/api/calculate/{experiment_id}")
def calculate_experiment(experiment_id: int, params: Dict, session: Session = Depends(get_session)):
    exp = session.get(Experiment, experiment_id)
    if not exp:
        raise HTTPException(status_code=404, detail="Experiment not found")
    return exp.calculate_results(params)

from typing import Optional, List, Dict
from sqlmodel import Field, SQLModel, Relationship
import json
import math

class Module(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None
    icon: Optional[str] = None
    experiments: List["Experiment"] = Relationship(back_populates="module")

class Experiment(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    module_id: int = Field(foreign_key="module.id")
    name: str
    description: Optional[str] = None
    formula_template: Optional[str] = None
    initial_params_json: str = Field(default="{}") 
    difficulty_level: Optional[str] = "Beginner"
    
    module: Module = Relationship(back_populates="experiments")
    formulas: List["Formula"] = Relationship(back_populates="experiment")
    quizzes: List["Quiz"] = Relationship(back_populates="experiment")

    @property
    def initial_params(self) -> Dict:
        return json.loads(self.initial_params_json)

    @initial_params.setter
    def initial_params(self, value: Dict):
        self.initial_params_json = json.dumps(value)

    def calculate_results(self, params: Dict) -> Dict:
        """Calculate physics results based on experiment type."""
        if self.name == "Projectile Motion":
            v0 = params.get("velocity", 20.0)
            theta = params.get("angle", 45.0)
            g = params.get("gravity", 9.8)

            angle_rad = math.radians(theta)
            t_max = (2 * v0 * math.sin(angle_rad)) / g if math.sin(angle_rad) != 0 else 0

            trajectory = []
            for i in range(21):
                t = (t_max / 20) * i if t_max > 0 else 0
                x = v0 * math.cos(angle_rad) * t
                y = v0 * math.sin(angle_rad) * t - 0.5 * g * t * t
                trajectory.append({"x": x, "y": y, "t": t})

            return {
                "trajectory": trajectory,
                "max_range": v0 * math.cos(angle_rad) * t_max,
                "max_height": (v0 * math.sin(angle_rad))**2 / (2 * g) if g != 0 else 0,
                "flight_time": t_max
            }

        elif "Refraction" in self.name:
            n1 = params.get("n1", 1.0)
            n2 = params.get("n2", 1.5)
            theta1 = params.get("theta1", 30.0)
            
            theta1_rad = math.radians(theta1)
            # n1 * sin(theta1) = n2 * sin(theta2)
            sin_theta2 = (n1 * math.sin(theta1_rad)) / n2
            
            if abs(sin_theta2) > 1:
                return {
                    "theta2": None,
                    "is_tir": True,
                    "critical_angle": math.degrees(math.asin(n2/n1)) if n1 > n2 else None
                }
            
            theta2_rad = math.asin(sin_theta2)
            return {
                "theta2": math.degrees(theta2_rad),
                "is_tir": False,
                "n1": n1,
                "n2": n2
            }

        elif "Projectile Challenge" in self.name:
            v0 = params.get("velocity", 20.0)
            theta = params.get("angle", 45.0)
            target_d = params.get("target_distance", 40.0)
            g = 9.8

            angle_rad = math.radians(theta)
            # Range R = (v^2 * sin(2*theta)) / g
            actual_range = (v0**2 * math.sin(2 * angle_rad)) / g
            
            distance_from_target = abs(actual_range - target_d)
            is_hit = distance_from_target < 2.0 # 2 meter tolerance
            
            return {
                "actual_range": actual_range,
                "distance_from_target": distance_from_target,
                "is_hit": is_hit,
                "score": max(0, 100 - int(distance_from_target * 5)) if is_hit else 0
            }

        elif "Mirror" in self.name or "Lens" in self.name:
            f = params.get("focal_length", 10.0)
            do = params.get("object_distance", 20.0)
            ho = params.get("object_height", 5.0)
            
            # 1/f = 1/do + 1/di  => 1/di = 1/f - 1/do = (do - f) / (f * do)
            if do == f:
                di = float('inf')
                m = float('inf')
                hi = float('inf')
            else:
                di = (f * do) / (do - f)
                m = -di / do
                hi = m * ho
            
            return {
                "image_distance": di,
                "magnification": m,
                "image_height": hi,
                "is_real": di > 0 if di != float('inf') else False,
                "is_upright": m > 0 if m != float('inf') else False
            }

        elif "Photoelectric Effect" in self.name:
            freq = params.get("frequency", 6e14) # Hz
            phi = params.get("work_function", 2.0) # eV
            intensity = params.get("intensity", 1.0)
            
            h_ev_s = 4.135667696e-15 # Planck's constant in eV*s
            ke_max = h_ev_s * freq - phi
            threshold_freq = phi / h_ev_s
            
            return {
                "ke_max": max(0, ke_max),
                "threshold_frequency": threshold_freq,
                "is_emission": freq > threshold_freq,
                "current_proportional": intensity if freq > threshold_freq else 0
            }

        elif "Wave Interference" in self.name:
            a1 = params.get("amplitude1", 1.0)
            a2 = params.get("amplitude2", 1.0)
            f1 = params.get("frequency1", 1.0)
            f2 = params.get("frequency2", 1.0)
            phase = params.get("phase_diff", 0.0) # degrees
            
            phase_rad = math.radians(phase)
            points = []
            for i in range(101):
                x = (i / 100) * 10 # x from 0 to 10
                # Simple superposition at t=0: y = A1*sin(k1*x) + A2*sin(k2*x + phase)
                # Assuming k = 2*pi*f/v, taking v=1 for simplicity
                y1 = a1 * math.sin(2 * math.pi * f1 * x)
                y2 = a2 * math.sin(2 * math.pi * f2 * x + phase_rad)
                points.append({"x": x, "y1": y1, "y2": y2, "y_total": y1 + y2})
            
            return {"points": points}

        elif "Circuit" in self.name or "Ohm's Law" in self.name:
            v = params.get("voltage")
            i = params.get("current")
            r = params.get("resistance")

            if v is not None and i is not None and r is not None:
                 return {"voltage": v, "current": i, "resistance": r}

            # Find the missing variable
            if v is None and i is not None and r is not None:
                v = i * r
            elif i is None and v is not None and r is not None:
                i = v / r if r != 0 else 0
            elif r is None and v is not None and i is not None:
                r = v / i if i != 0 else 0

            return {"voltage": v, "current": i, "resistance": r}

        return {}

class Formula(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    experiment_id: int = Field(foreign_key="experiment.id")
    name: str
    latex_string: str
    explanation: Optional[str] = None
    experiment: Experiment = Relationship(back_populates="formulas")

class Quiz(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    experiment_id: int = Field(foreign_key="experiment.id")
    question: str
    options_json: str = Field(default="[]") 
    correct_option: int # Index
    experiment: Experiment = Relationship(back_populates="quizzes")

    @property
    def options(self) -> List[str]:
        return json.loads(self.options_json)

    @options.setter
    def options(self, value: List[str]):
        self.options_json = json.dumps(value)

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True)
    email: str = Field(unique=True)
    hashed_password: str
    progress: List["UserProgress"] = Relationship(back_populates="user")

class UserProgress(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    experiment_id: int = Field(foreign_key="experiment.id")
    completed: bool = Field(default=False)
    quiz_score: Optional[int] = None
    last_accessed: Optional[str] = None
    
    user: User = Relationship(back_populates="progress")

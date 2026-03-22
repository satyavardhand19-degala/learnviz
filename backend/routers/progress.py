from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from pydantic import BaseModel

from database import get_session
from models import User, UserProgress, Experiment
from .auth import get_current_user

router = APIRouter(prefix="/api/progress", tags=["progress"])

class ProgressUpdate(BaseModel):
    experiment_id: int
    completed: Optional[bool] = None
    quiz_score: Optional[int] = None

@router.get("/", response_model=List[UserProgress])
def get_user_progress(current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    return current_user.progress

@router.post("/", response_model=UserProgress)
def update_progress(progress_data: ProgressUpdate, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    # Check if experiment exists
    exp = session.get(Experiment, progress_data.experiment_id)
    if not exp:
        raise HTTPException(status_code=404, detail="Experiment not found")

    # Find existing progress or create new
    statement = select(UserProgress).where(
        UserProgress.user_id == current_user.id,
        UserProgress.experiment_id == progress_data.experiment_id
    )
    progress = session.exec(statement).first()

    if not progress:
        progress = UserProgress(
            user_id=current_user.id,
            experiment_id=progress_data.experiment_id
        )
        session.add(progress)

    if progress_data.completed is not None:
        progress.completed = progress_data.completed
    if progress_data.quiz_score is not None:
        progress.quiz_score = progress_data.quiz_score
    
    progress.last_accessed = datetime.now(timezone.utc).isoformat()
    
    session.commit()
    session.refresh(progress)
    return progress

@router.get("/{experiment_id}", response_model=UserProgress)
def get_experiment_progress(experiment_id: int, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    statement = select(UserProgress).where(
        UserProgress.user_id == current_user.id,
        UserProgress.experiment_id == experiment_id
    )
    progress = session.exec(statement).first()
    if not progress:
        return UserProgress(user_id=current_user.id, experiment_id=experiment_id, completed=False)
    return progress
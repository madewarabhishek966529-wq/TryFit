import uuid
from datetime import datetime
from typing import Dict, List, Optional
from fastapi import FastAPI, HTTPException, Header, Query, status
from fastapi.middleware.cors import CORSMiddleware

from .models.schemas import (
    UploadUrlRequest, UploadUrlResponse,
    AssetCompleteRequest, AssetResponse,
    CreateJobRequest, JobResponse, JobStatusEnum,
    HistoryResponse, UserConsentsRequest, UserProfileResponse,
    ConsentItem, StylistRequest, StylistRecommendation, GarmentCategoryEnum
)
from ..worker.adapters.mock_adapter import MockTryOnAdapter

app = FastAPI(
    title="TryFit Virtual Try-On API",
    version="1.0.0",
    description="API for AI Virtual Try-On and Personal Fashion Studio"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage for local execution & testing
adapter = MockTryOnAdapter()
assets_db: Dict[str, Dict] = {}
jobs_db: Dict[str, Dict] = {}
idempotency_map: Dict[str, str] = {}
user_consents_db: Dict[str, List[ConsentItem]] = {}

def get_current_user_id(authorization: Optional[str] = Header(None)) -> str:
    """Extract authenticated user ID or fallback to standard demo user."""
    if authorization and authorization.startswith("Bearer "):
        token = authorization.replace("Bearer ", "").strip()
        if token:
            return f"user_{token}"
    return "guest_demo_user"

# ----------------- Assets ----------------- #

@app.post("/api/v1/assets/upload-url", response_model=UploadUrlResponse)
def request_upload_url(req: UploadUrlRequest, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    asset_id = str(uuid.uuid4())
    
    asset_record = {
        "id": asset_id,
        "user_id": user_id,
        "purpose": req.purpose,
        "file_name": req.file_name,
        "mime_type": req.content_type,
        "byte_size": req.byte_size,
        "status": "pending_upload",
        "created_at": datetime.utcnow()
    }
    assets_db[asset_id] = asset_record
    
    return UploadUrlResponse(
        asset_id=asset_id,
        upload_url=f"http://127.0.0.1:8000/api/v1/mock-storage/upload/{asset_id}",
        expires_in_seconds=900,
        headers={"Content-Type": req.content_type}
    )

@app.post("/api/v1/assets/{asset_id}/complete", response_model=AssetResponse)
def complete_asset_upload(asset_id: str, req: AssetCompleteRequest, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    asset = assets_db.get(asset_id)
    if not asset or asset["user_id"] != user_id:
        raise HTTPException(status_code=404, detail="Asset not found or unauthorized")
        
    asset["status"] = "uploaded"
    return AssetResponse(
        id=asset["id"],
        purpose=asset["purpose"],
        file_name=asset["file_name"],
        mime_type=asset["mime_type"],
        byte_size=asset["byte_size"],
        created_at=asset["created_at"]
    )

@app.delete("/api/v1/assets/{asset_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_asset(asset_id: str, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    asset = assets_db.get(asset_id)
    if not asset or asset["user_id"] != user_id:
        raise HTTPException(status_code=404, detail="Asset not found or unauthorized")
    del assets_db[asset_id]
    return None

# ----------------- Try-On Jobs ----------------- #

@app.post("/api/v1/tryon/jobs", response_model=JobResponse)
def create_tryon_job(req: CreateJobRequest, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    
    # Idempotency check (FR-025)
    if req.idempotency_key and req.idempotency_key in idempotency_map:
        existing_job_id = idempotency_map[req.idempotency_key]
        existing_job = jobs_db[existing_job_id]
        if existing_job["user_id"] == user_id:
            return _format_job_response(existing_job)
            
    job_id = str(uuid.uuid4())
    job_record = {
        "id": job_id,
        "user_id": user_id,
        "category": req.category,
        "status": JobStatusEnum.queued,
        "progress_message": "Job queued for virtual try-on synthesis",
        "simulation_disclaimer": "AI Visual Simulation only. Sizing or fit is not guaranteed.",
        "result_asset_id": None,
        "result_url": None,
        "error_message": None,
        "created_at": datetime.utcnow(),
        "completed_at": None,
        "is_demo": True
    }
    
    jobs_db[job_id] = job_record
    if req.idempotency_key:
        idempotency_map[req.idempotency_key] = job_id
        
    return _format_job_response(job_record)

@app.get("/api/v1/tryon/jobs/{job_id}", response_model=JobResponse)
def get_tryon_job(job_id: str, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    job = jobs_db.get(job_id)
    if not job or job["user_id"] != user_id:
        raise HTTPException(status_code=404, detail="Job not found or access denied")
        
    # Simulate step transitions
    if job["status"] == JobStatusEnum.queued:
        job["status"] = JobStatusEnum.validating
        job["progress_message"] = "Validating pose keypoints and garment boundary"
    elif job["status"] == JobStatusEnum.validating:
        job["status"] = JobStatusEnum.processing
        job["progress_message"] = "Blending cloth drape and texture synthesis"
    elif job["status"] == JobStatusEnum.processing:
        job["status"] = JobStatusEnum.succeeded
        job["progress_message"] = "Simulation complete"
        job["completed_at"] = datetime.utcnow()
        job["result_url"] = "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80"
        job["result_asset_id"] = str(uuid.uuid4())
        
    return _format_job_response(job)

@app.post("/api/v1/tryon/jobs/{job_id}/cancel", response_model=JobResponse)
def cancel_tryon_job(job_id: str, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    job = jobs_db.get(job_id)
    if not job or job["user_id"] != user_id:
        raise HTTPException(status_code=404, detail="Job not found or access denied")
        
    if job["status"] not in [JobStatusEnum.succeeded, JobStatusEnum.failed, JobStatusEnum.cancelled]:
        job["status"] = JobStatusEnum.cancelled
        job["progress_message"] = "Simulation cancelled by user request"
        job["completed_at"] = datetime.utcnow()
        
    return _format_job_response(job)

@app.get("/api/v1/tryon/history", response_model=HistoryResponse)
def get_history(limit: int = 20, cursor: Optional[str] = None, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    user_jobs = [j for j in jobs_db.values() if j["user_id"] == user_id]
    user_jobs.sort(key=lambda x: x["created_at"], reverse=True)
    
    return HistoryResponse(
        items=[_format_job_response(j) for j in user_jobs[:limit]],
        next_cursor=None
    )

@app.delete("/api/v1/tryon/results/{result_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_result(result_id: str, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    matched_job = None
    for j_id, job in list(jobs_db.items()):
        if (job["id"] == result_id or job.get("result_asset_id") == result_id) and job["user_id"] == user_id:
            del jobs_db[j_id]
            matched_job = j_id
            break
            
    if not matched_job:
        raise HTTPException(status_code=404, detail="Result not found or access denied")
    return None

# ----------------- Profile & Privacy ----------------- #

@app.get("/api/v1/me", response_model=UserProfileResponse)
def get_profile(authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    consents = user_consents_db.get(user_id, [])
    return UserProfileResponse(
        user_id=user_id,
        consents=consents,
        created_at=datetime.utcnow()
    )

@app.post("/api/v1/me/consents", response_model=UserProfileResponse)
def update_consents(req: UserConsentsRequest, authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    user_consents_db[user_id] = req.consents
    return UserProfileResponse(
        user_id=user_id,
        consents=req.consents,
        created_at=datetime.utcnow()
    )

@app.post("/api/v1/me/export")
def export_user_data(authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    user_jobs = [j for j in jobs_db.values() if j["user_id"] == user_id]
    user_assets = [a for a in assets_db.values() if a["user_id"] == user_id]
    return {
        "exported_at": datetime.utcnow().isoformat(),
        "user_id": user_id,
        "total_jobs": len(user_jobs),
        "total_assets": len(user_assets),
        "jobs": [_format_job_response(j) for j in user_jobs],
        "assets": user_assets
    }

@app.delete("/api/v1/me", status_code=status.HTTP_204_NO_CONTENT)
def purge_account_data(authorization: Optional[str] = Header(None)):
    user_id = get_current_user_id(authorization)
    # Delete all user assets, jobs, and consents
    for a_id in list(assets_db.keys()):
        if assets_db[a_id]["user_id"] == user_id:
            del assets_db[a_id]
    for j_id in list(jobs_db.keys()):
        if jobs_db[j_id]["user_id"] == user_id:
            del jobs_db[j_id]
    if user_id in user_consents_db:
        del user_consents_db[user_id]
    return None

# ----------------- Stylist (Phase 2) ----------------- #

@app.post("/api/v1/stylist/recommendations", response_model=List[StylistRecommendation])
def get_recommendations(req: StylistRequest):
    return [
        StylistRecommendation(
            title=f"{req.style_vibe} Curated Ensemble",
            occasion=req.occasion,
            styling_rationale=f"Balanced silhouette tailored for {req.occasion} prioritizing your {req.style_vibe} mood.",
            harmony_score=95,
            garment_title="Tailored Wool Blazer & Silk Trousers",
            image_url="https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80"
        ),
        StylistRecommendation(
            title="Monochrome Draped Silhouette",
            occasion=req.occasion,
            styling_rationale="Fluid drape contrasted with sharp lines for a modern editorial feel.",
            harmony_score=92,
            garment_title="Emerald Silk Slip Dress",
            image_url="https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80"
        )
    ]

def _format_job_response(job: Dict) -> JobResponse:
    return JobResponse(
        id=job["id"],
        status=job["status"],
        category=job["category"],
        progress_message=job["progress_message"],
        simulation_disclaimer=job["simulation_disclaimer"],
        result_asset_id=job.get("result_asset_id"),
        result_url=job.get("result_url"),
        error_message=job.get("error_message"),
        created_at=job["created_at"],
        completed_at=job.get("completed_at"),
        is_demo=job.get("is_demo", True)
    )

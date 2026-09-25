from enum import Enum
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field
from datetime import datetime
import uuid

class GarmentCategoryEnum(str, Enum):
    tops = "tops"
    bottoms = "bottoms"
    dresses = "dresses"
    outerwear = "outerwear"
    full_outfit = "full_outfit"

class JobStatusEnum(str, Enum):
    queued = "queued"
    validating = "validating"
    processing = "processing"
    succeeded = "succeeded"
    failed = "failed"
    cancelled = "cancelled"

class UploadUrlRequest(BaseModel):
    purpose: str = Field(..., description="person or garment")
    file_name: str
    content_type: str
    byte_size: int

class UploadUrlResponse(BaseModel):
    asset_id: str
    upload_url: str
    expires_in_seconds: int = 900
    headers: Dict[str, str] = {}

class AssetCompleteRequest(BaseModel):
    checksum: Optional[str] = None

class AssetResponse(BaseModel):
    id: str
    purpose: str
    file_name: str
    mime_type: str
    byte_size: int
    created_at: datetime

class CreateJobRequest(BaseModel):
    person_asset_id: str
    garment_asset_id: str
    category: GarmentCategoryEnum
    idempotency_key: Optional[str] = None

class JobResponse(BaseModel):
    id: str
    status: JobStatusEnum
    category: GarmentCategoryEnum
    progress_message: str
    simulation_disclaimer: str
    result_asset_id: Optional[str] = None
    result_url: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime
    completed_at: Optional[datetime] = None
    is_demo: bool = True

class HistoryResponse(BaseModel):
    items: List[JobResponse]
    next_cursor: Optional[str] = None

class ConsentItem(BaseModel):
    policy_id: str
    consented: bool
    consented_at: datetime

class UserConsentsRequest(BaseModel):
    consents: List[ConsentItem]

class UserProfileResponse(BaseModel):
    user_id: str
    tier: str = "guest_demo"
    consents: List[ConsentItem]
    created_at: datetime

class StylistRequest(BaseModel):
    occasion: str
    style_vibe: str
    use_owned_only: bool = False

class StylistRecommendation(BaseModel):
    title: str
    occasion: str
    styling_rationale: str
    harmony_score: int
    garment_title: str
    image_url: str

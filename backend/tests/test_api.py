import pytest
from fastapi.testclient import TestClient
from backend.api.main import app

client = TestClient(app)

def test_request_upload_url():
    payload = {
        "purpose": "person",
        "file_name": "portrait.jpg",
        "content_type": "image/jpeg",
        "byte_size": 102400
    }
    response = client.post("/api/v1/assets/upload-url", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "asset_id" in data
    assert "upload_url" in data
    assert data["expires_in_seconds"] == 900

def test_job_lifecycle_and_idempotency():
    # 1. Create Job with Idempotency Key
    idempotency_key = "test-job-key-abc-123"
    job_payload = {
        "person_asset_id": "person-123",
        "garment_asset_id": "garment-456",
        "category": "tops",
        "idempotency_key": idempotency_key
    }
    create_resp = client.post("/api/v1/tryon/jobs", json=job_payload)
    assert create_resp.status_code == 200
    job_data = create_resp.json()
    job_id = job_data["id"]
    assert job_data["status"] == "queued"
    assert job_data["is_demo"] is True

    # 2. Duplicate Submission with Same Idempotency Key returns same job
    dup_resp = client.post("/api/v1/tryon/jobs", json=job_payload)
    assert dup_resp.status_code == 200
    assert dup_resp.json()["id"] == job_id

    # 3. Poll step 1 -> validating
    step1 = client.get(f"/api/v1/tryon/jobs/{job_id}")
    assert step1.status_code == 200
    assert step1.json()["status"] == "validating"

    # 4. Poll step 2 -> processing
    step2 = client.get(f"/api/v1/tryon/jobs/{job_id}")
    assert step2.status_code == 200
    assert step2.json()["status"] == "processing"

    # 5. Poll step 3 -> succeeded
    step3 = client.get(f"/api/v1/tryon/jobs/{job_id}")
    assert step3.status_code == 200
    final_data = step3.json()
    assert final_data["status"] == "succeeded"
    assert final_data["result_url"] is not None

def test_cross_user_isolation():
    # User A creates a job
    headers_user_a = {"Authorization": "Bearer token_user_a"}
    headers_user_b = {"Authorization": "Bearer token_user_b"}

    job_payload = {
        "person_asset_id": "person-a",
        "garment_asset_id": "garment-a",
        "category": "outerwear"
    }
    create_resp = client.post("/api/v1/tryon/jobs", json=job_payload, headers=headers_user_a)
    assert create_resp.status_code == 200
    job_id = create_resp.json()["id"]

    # User B attempts to access User A's job -> 404 access denied
    forbidden_resp = client.get(f"/api/v1/tryon/jobs/{job_id}", headers=headers_user_b)
    assert forbidden_resp.status_code == 404

    # User B attempts to cancel User A's job -> 404 access denied
    cancel_resp = client.post(f"/api/v1/tryon/jobs/{job_id}/cancel", headers=headers_user_b)
    assert cancel_resp.status_code == 404

def test_user_data_export_and_purge():
    headers = {"Authorization": "Bearer token_user_privacy"}
    # Create an asset
    client.post(
        "/api/v1/assets/upload-url",
        json={"purpose": "person", "file_name": "photo.jpg", "content_type": "image/jpeg", "byte_size": 50000},
        headers=headers
    )
    # Export
    export_resp = client.post("/api/v1/me/export", headers=headers)
    assert export_resp.status_code == 200
    assert export_resp.json()["total_assets"] >= 1

    # Purge
    purge_resp = client.delete("/api/v1/me", headers=headers)
    assert purge_resp.status_code == 204

    # Verify export is now empty
    empty_export = client.post("/api/v1/me/export", headers=headers)
    assert empty_export.json()["total_assets"] == 0

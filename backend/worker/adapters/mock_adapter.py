from typing import Dict, Any
from .base import TryOnModelAdapter

class MockTryOnAdapter(TryOnModelAdapter):
    """
    Deterministic mock inference adapter clearly labeled DEMO.
    Fulfills ADR-002 allowing end-to-end testing without GPU or paid services.
    """
    def __init__(self):
        self.model_version = "TryFit-MockEngine-v1.0 (DEMO SYNTHETIC)"

    def health_check(self) -> Dict[str, Any]:
        return {
            "status": "healthy",
            "adapter": "mock",
            "model_version": self.model_version,
            "gpu_required": False
        }

    def validate_inputs(self, person_bytes: bytes, garment_bytes: bytes, category: str) -> bool:
        if not person_bytes or not garment_bytes:
            return False
        return len(person_bytes) >= 100 and len(garment_bytes) >= 100

    def infer(self, person_bytes: bytes, garment_bytes: bytes, category: str) -> Dict[str, Any]:
        # Return deterministic synthetic result fixture
        return {
            "model_identifier": self.model_version,
            "status": "succeeded",
            "simulation_disclaimer": "AI Visual Simulation only. Not a sizing or fabric guarantee.",
            "is_demo": True,
            "quality_flags": {
                "pose_detected": True,
                "garment_warp_score": 0.98,
                "artifacts_detected": False
            },
            "output_url": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80"
        }

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional

class TryOnModelAdapter(ABC):
    @abstractmethod
    def health_check(self) -> Dict[str, Any]:
        """Verify model adapter availability and hardware state."""
        pass

    @abstractmethod
    def validate_inputs(self, person_bytes: bytes, garment_bytes: bytes, category: str) -> bool:
        """Validate input binary assets and categories."""
        pass

    @abstractmethod
    def infer(self, person_bytes: bytes, garment_bytes: bytes, category: str) -> Dict[str, Any]:
        """Execute simulation generation."""
        pass

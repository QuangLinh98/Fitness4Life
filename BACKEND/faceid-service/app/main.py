# main.py
from fastapi import FastAPI, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
from .services.faceService import FaceRecognitionService

# Cấu hình logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Face Recognition API")

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Khởi tạo service
face_service = FaceRecognitionService(tolerance=0.5)

class CompareRequest(BaseModel):
    known_encoding: str
    unknown_encoding: str

@app.post("/encode-face")
async def encode_face_endpoint(file: UploadFile):
    """
    Endpoint để encode khuôn mặt từ ảnh upload
    Returns: Base64 encoded face features
    """
    try:
        logger.info(f"Processing image: {file.filename}")
        
        # Xử lý và validate ảnh
        image_array = face_service.validate_and_process_image(file)
        
        # Phát hiện khuôn mặt
        face_service.detect_faces(image_array)
        
        # Encode khuôn mặt
        encoding = face_service.encode_face(image_array)
        
        # Chuyển sang base64
        encoding_base64 = face_service.encoding_to_base64(encoding)
        
        logger.info("Face encoding successful")
        return encoding_base64
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in encode_face_endpoint: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/compare-faces")
async def compare_faces_endpoint(request: CompareRequest):
    try:
        logger.info("Comparing face encodings")
        
        known_encoding = face_service.base64_to_encoding(request.known_encoding)
        unknown_encoding = face_service.base64_to_encoding(request.unknown_encoding)
        
        result = bool(face_service.compare_faces(known_encoding, unknown_encoding))
        
        logger.info(f"Face comparison result: {result}")
        return {"match": result}
        
    except Exception as e:
        logger.error(f"Error in compare_faces_endpoint: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
@app.get("/health")
async def health_check():
    """
    Health check endpoint
    """
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
# services.py
import cv2
import numpy as np
from PIL import Image
import io
import face_recognition
import base64
from fastapi import HTTPException, UploadFile
import logging

logger = logging.getLogger(__name__)

class FaceRecognitionService:
    def __init__(self, tolerance=0.5):
        self.tolerance = tolerance

    def validate_and_process_image(self, file: UploadFile):
        try:
            # Đọc file bytes
            image_bytes = file.file.read()
            file.file.seek(0)
            
            # Chuyển đổi sang PIL Image
            image = Image.open(io.BytesIO(image_bytes))
            
            # Chuyển RGB
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Resize nếu cần
            max_size = 1500
            if max(image.size) > max_size:
                ratio = max_size / max(image.size)
                new_size = tuple(int(dim * ratio) for dim in image.size)
                image = image.resize(new_size, Image.Resampling.LANCZOS)
            
            # Chuyển sang numpy array
            try:
                image_array = np.array(image)
            except Exception:
                image_array = np.asarray(image.getdata(), dtype=np.uint8).reshape(image.size[1], image.size[0], 3)
            
            # Chuẩn hóa dữ liệu
            if image_array.dtype != np.uint8:
                image_array = (image_array * 255).clip(0, 255).astype(np.uint8)
            
            if len(image_array.shape) != 3 or image_array.shape[2] != 3:
                raise ValueError("Image must be RGB format with 3 channels")
            
            # Nâng cao chất lượng
            bgr_image = cv2.cvtColor(image_array, cv2.COLOR_RGB2BGR)
            bgr_image = cv2.normalize(bgr_image, None, 0, 255, cv2.NORM_MINMAX)
            image_array = cv2.cvtColor(bgr_image, cv2.COLOR_BGR2RGB)
            
            return image_array

        except Image.UnidentifiedImageError:
            raise HTTPException(
                status_code=400,
                detail="Invalid image format. Please upload a valid JPEG or PNG image."
            )
        except ValueError as e:
            raise HTTPException(status_code=400, detail=str(e))
        except Exception as e:
            logger.error(f"Error processing image: {str(e)}")
            raise HTTPException(
                status_code=400,
                detail=f"Error processing image: {str(e)}. Please try with a different image."
            )
        finally:
            file.file.seek(0)

    def detect_faces(self, image_array):
        try:
            face_locations = face_recognition.face_locations(image_array)
            
            if len(face_locations) == 0:
                raise HTTPException(
                    status_code=400,
                    detail="No face detected. Please ensure the image contains a clear, well-lit face."
                )
            elif len(face_locations) > 1:
                raise HTTPException(
                    status_code=400,
                    detail="Multiple faces detected. Please upload an image with a single face."
                )
                
            return face_locations
            
        except Exception as e:
            logger.error(f"Error detecting faces: {str(e)}")
            raise HTTPException(
                status_code=400,
                detail=f"Face detection failed: {str(e)}. Please try with a clearer image."
            )

    def encode_face(self, image_array):
        # Giảm kích thước để tối ưu
        small_image = cv2.resize(image_array, (0, 0), fx=0.25, fy=0.25)
        
        # Encode khuôn mặt
        encodings = face_recognition.face_encodings(small_image)
        if not encodings:
            raise HTTPException(status_code=400, detail="Could not encode face")
            
        return encodings[0]
    
    def encoding_to_base64(self, encoding):
        encoding_bytes = encoding.tobytes()
        return base64.b64encode(encoding_bytes).decode('utf-8')
    
    def base64_to_encoding(self, base64_string):
        try:
            encoding_bytes = base64.b64decode(base64_string)
            return np.frombuffer(encoding_bytes, dtype=np.float64)
        except Exception as e:
            logger.error(f"Error decoding base64: {str(e)}")
            raise HTTPException(
                status_code=400,
                detail="Invalid face encoding format"
            )

    def compare_faces(self, known_encoding, unknown_encoding):
        try:
            # Kiểm tra input
            if known_encoding is None or unknown_encoding is None:
                logger.error("Null encoding received")
                return False
                
            # Kiểm tra kích thước vector
            if known_encoding.shape != unknown_encoding.shape:
                logger.error(f"Encoding shape mismatch: {known_encoding.shape} vs {unknown_encoding.shape}")
                return False
                
            # Giảm tolerance để nghiêm ngặt hơn 
            self.tolerance = 0.3  # hoặc thấp hơn như 0.3
            
            # Chuẩn hóa vectors trước khi so sánh
            known_norm = known_encoding / np.linalg.norm(known_encoding)
            unknown_norm = unknown_encoding / np.linalg.norm(unknown_encoding)
            
            # Tính khoảng cách
            distance = np.linalg.norm(known_norm - unknown_norm)
            
            # Log chi tiết để debug
            logger.info(f"Known encoding shape: {known_encoding.shape}")
            logger.info(f"Unknown encoding shape: {unknown_encoding.shape}")
            logger.info(f"Distance: {distance}")
            logger.info(f"Tolerance: {self.tolerance}")
            
            result = bool(distance < self.tolerance)
            return result
            
        except Exception as e:
            logger.error(f"Error in face comparison: {str(e)}")
            return False
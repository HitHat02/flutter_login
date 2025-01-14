from pydantic import BaseModel, Field
from typing import List, Optional
from bson import ObjectId
from datetime import datetime

class User(BaseModel):
    username: str
    email: str
    password: str
    
class UserName(BaseModel):
    username: str
    
class UserLogin(BaseModel):
    username: str
    password: str

class FileModel(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    filename: str
    path: str
    uploaded_at: datetime

    class Config:
        orm_mode = True
        allow_population_by_field_name = True

# 요청 및 응답용 모델
class FileUploadResponse(BaseModel):
    message: str
    file_ids: List[str]

class FileListResponse(BaseModel):
    files: List[FileModel]

# MongoDB에서 ObjectId를 처리하기 위한 헬퍼 함수
def bson_objectid_encoder(obj):
    if isinstance(obj, ObjectId):
        return str(obj)
    raise TypeError(f"Cannot encode {type(obj)}")
from fastapi import FastAPI, HTTPException, Depends
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.exceptions import RequestValidationError
from starlette.requests import Request
from pymongo import MongoClient
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from passlib.context import CryptContext
import os

MONGO_URL = "mongodb://localhost:27017"
client = AsyncIOMotorClient(MONGO_URL)
db = client.my_database
users_collection = db.users

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 필요 시 허용할 도메인 설정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class User(BaseModel):
    username: str
    email: str
    password: str
    
class UserName(BaseModel):
    username: str
    
class UserLogin(BaseModel):
    username: str
    password: str


# 정적 파일 디렉토리 설정
app.mount("/auth", StaticFiles(directory="build/web", html=True), name="auth")

@app.get("/{path:path}")
async def catch_all(request: Request, path: str):
    """
    모든 경로에서 기본 index.html을 반환하여 SPA 동작 보장.
    """
    file_path = f"build/web/{path}"
    if not os.path.exists(file_path) or os.path.isdir(file_path):
        return FileResponse("build/web/index.html")
    return FileResponse(file_path)

@app.post("/register")
async def register_user(user: User):
    if not user.password:
        raise HTTPException(status_code=400, detail="Password is required.")
    # 사용자 이름이나 이메일 중복 확인
    existing_user = await users_collection.find_one(
        {"$or": [{"username": user.username}, {"email": user.email}]}
    )
    if existing_user:
        raise HTTPException(status_code=400, detail="Username or email already exists")

    # 비밀번호 해시화
    hashed_password = pwd_context.hash(user.password)
    user_in_db = User(
        username=user.username, email=user.email, password=hashed_password
    )
    # 데이터 저장
    
    await users_collection.insert_one(user_in_db.dict())
    return {"message": "User created successfully"}

@app.post("/login")
async def login_user(user: UserLogin):
    # 사용자 이름으로 사용자 검색
    existing_user = await users_collection.find_one({"username": user.username})
    
    if not existing_user:
        raise HTTPException(status_code=400, detail="Invalid username")
    
    # 비밀번호 비교
    if not pwd_context.verify(user.password, existing_user["password"]):
        raise HTTPException(status_code=400, detail="Invalid password")
    
    # 로그인 성공
    return {"message": "Login successful"}

@app.post("/read_user")
async def read_user(name: UserName):
    if not name.username:
        raise HTTPException(status_code=400, detail="Password is required.")
    existing_user = await users_collection.find_one(
        {"$or": [{"username": name.username}, {"username": name.username}]}
    )
    print(existing_user)
    if not existing_user:
        raise HTTPException(status_code=400, detail="Username or email already exists")
    return {"message": f"{existing_user}"}

from fastapi import FastAPI, HTTPException, Depends
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from starlette.requests import Request

from pathlib import Path
import os

from .schemas import *
from .models import hash_password, verify_password
from .database import db, users_collection, files_collection

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 필요 시 허용할 도메인 설정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Directory to store uploaded files
UPLOAD_DIR = Path("/home/Download")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


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
    hashed_password = hash_password(user.password)
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
    if not verify_password(user.password, existing_user["password"]):
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

@app.post("/upload")
async def upload_files(files: List[FileModel] = File(...)):
    uploaded_file_ids = []

    for file in files:
        file_path = UPLOAD_DIR / file.filename
        file_extension = file.filename.split(".")[-1]  # Extract file extension

        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        file_data = {
            "filename": file.filename,
            "path": str(file_path),
            "extension": file_extension,
            "uploaded_at": datetime.utcnow(),
        }
        result = files_collection.insert_one(file_data)
        uploaded_file_ids.append(str(result.inserted_id))

    return {"message": "Files uploaded successfully", "file_ids": uploaded_file_ids}

@app.get("/files")
async def list_files():
    files = list(files_collection.find({}, {"_id": 1, "filename": 1, "path": 1, "extension": 1, "uploaded_at": 1}))
    return [{"id": str(file["_id"]), "name": file["filename"], "extension": file["extension"], "uploaded_at": file["uploaded_at"]} for file in files]

@app.get("/download/{file_id}")
async def download_file(file_id: str):
    file_data = files_collection.find_one({"_id": ObjectId(file_id)})

    if not file_data:
        return JSONResponse(status_code=404, content={"message": "File not found"})

    file_path = file_data["path"]
    if not os.path.exists(file_path):
        return JSONResponse(status_code=404, content={"message": "File not found on server"})

    return FileResponse(file_path, media_type="application/octet-stream", filename=file_data["filename"])
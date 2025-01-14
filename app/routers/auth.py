from fastapi import APIRouter, HTTPException, status
from app.schemas import UserCreate, UserLogin
from app.models import hash_password, verify_password
from app.db.database import users_collection

auth_router = APIRouter()

# 회원가입 라우트
@auth_router.post("/signup", status_code=status.HTTP_201_CREATED)
async def signup(user: UserCreate):
    # 사용자 중복 확인
    existing_user = await users_collection.find_one({"username": user.username})
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")

    # 사용자 저장
    hashed_password = hash_password(user.password)
    new_user = {"username": user.username, "email": user.email, "password": hashed_password}
    await users_collection.insert_one(new_user)
    return {"message": "User created successfully"}

# 로그인 라우트
@auth_router.post("/login")
async def login(user: UserLogin):
    existing_user = await users_collection.find_one({"username": user.username})
    if not existing_user or not verify_password(user.password, existing_user["password"]):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    return {"message": "Login successful"}

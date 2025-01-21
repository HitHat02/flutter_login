from motor.motor_asyncio import AsyncIOMotorClient

MONGO_DETAILS = "mongodb://13.210.228.91:27017"

client = AsyncIOMotorClient(MONGO_DETAILS)
db = client["test_db"]
users_collection = db["users"]
files_collection = db["files"]

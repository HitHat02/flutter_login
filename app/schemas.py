from pydantic import BaseModel

class User(BaseModel):
    username: str
    email: str
    password: str
    
class UserName(BaseModel):
    username: str
    
class UserLogin(BaseModel):
    username: str
    password: str


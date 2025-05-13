# core/config.py
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "Demo"

    DATABASE_URL: str = "sqlite:///database.db"
    # JWT 配置
    # 部署时最好使重新生成一个密钥
    # 生成密钥命令：openssl rand -hex 32
    SECRET_KEY: str = (
        "1c645c96c2ba8ab716a7672f7314c4351d02accf92e3c6658588732003a40fdf"
    )

    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    ACCESS_TOKEN_EXPIRE_DAYS: int = 30
    # # 是否开启权限验证
    # close_verify_user_permissions = True


settings = Settings()


TORTOISE_ORM = {
    "connections": {"default": "sqlite://db/database.db"},
    "apps": {
        "models": {
            "models": ["models.models","models.trajectory_point"],
            "default_connection": "default",
        },
    },
    "use_tz": True,
    "timezone": "Asia/Shanghai",
}

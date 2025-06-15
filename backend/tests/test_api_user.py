import unittest
import requests


class TestCreateUser(unittest.TestCase):
    BASE_URL = "http://127.0.0.1:8000/api/"

    def test_create_admin(self):
        # 创建一个管理员用户的请求数据
        admin_user = {
            "name": "admin",
            "email": "test@example.com",
            "phone_number": "1234567890",
            "password": "123456",
            "permissions": "admin",
        }
        # 向用户API发送POST请求以创建管理员用户
        # 使用 json 参数发送JSON格式数据
        response = requests.post(
            url="http://127.0.0.1:8000/api/users/",
            json=admin_user,
            headers={"Content-Type": "application/json", "accept": "application/json"},
            timeout=5,
        )

        # 检查请求是否成功
        self.assertEqual(
            response.status_code, 201
        )  # 检查响应状态码是否为201（成功创建）
        self.assertEqual(response.json()["name"], admin_user["name"])
        self.assertEqual(response.json()["email"], admin_user["email"])
        self.assertEqual(response.json()["phone_number"], admin_user["phone_number"])

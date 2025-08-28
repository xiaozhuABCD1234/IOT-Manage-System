import random
import string

def random_string(length=10):
    """生成随机字符串"""
    return ''.join(random.choices(string.ascii_letters, k=length))

def random_email():
    """生成随机邮箱"""
    return f"{random_string(20)}@example.com"
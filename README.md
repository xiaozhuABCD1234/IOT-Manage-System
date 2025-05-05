# IOT-Management-System

## 启动

```bash
cd ./frontend
npm install
node run build
cd ../backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
fastapi run main.py --port 8000 --host 0.0.0.0
```

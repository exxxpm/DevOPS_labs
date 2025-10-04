from flask import Flask
app = Flask(__name__)

@app.get("/")
def root():
    return "Hello from app on :8181 (lab_1)"

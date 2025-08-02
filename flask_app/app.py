from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Flask!"

@app.route("/hello")
def hello():
    return "Welcome to the /hello endpoint"

@app.route("/status")
def status():
    return jsonify({"status": "OK", "env": "dev"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

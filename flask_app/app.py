from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify(message="Hello from Flask!"), 200

@app.route("/hello")
def hello():
    return jsonify(message="Welcome to the /hello endpoint"), 200

@app.route("/status")
def status():
    return jsonify(status="OK", env="dev"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

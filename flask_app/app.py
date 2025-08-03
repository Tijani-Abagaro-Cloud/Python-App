from flask import Flask, jsonify, make_response

app = Flask(__name__)

@app.route("/hello")
def hello():
    response = make_response(jsonify(message="Welcome to the /hello endpoint"), 200)
    response.headers["Content-Type"] = "application/json"
    return response

# Keep other routes as needed
@app.route("/")
def home():
    return jsonify(message="Hello from Flask!"), 200

@app.route("/status")
def status():
    return jsonify(status="OK", env="dev"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

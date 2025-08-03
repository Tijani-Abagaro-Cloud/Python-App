from flask import Flask, jsonify, Response

app = Flask(__name__)

@app.route("/")
def home():
    return Response("Hello from Flask!", status=200, mimetype="text/plain")

@app.route("/hello")
def hello():
    return Response("Welcome to the /hello endpoint", status=200, mimetype="text/plain")

@app.route("/status")
def status():
    return jsonify({"status": "OK", "env": "dev"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

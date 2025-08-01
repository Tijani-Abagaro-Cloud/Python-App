from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/", methods=["GET"])
def root():
    return "Hello from Flask Root!"

@app.route("/hello", methods=["GET"])
def hello():
    return "Welcome to the /hello endpoint!"

@app.route("/<path:proxy_path>", methods=["GET", "POST", "PUT", "DELETE"])
def catch_all(proxy_path):
    return jsonify({
        "message": f"Unhandled path: /{proxy_path}",
        "method": request.method,
        "headers": dict(request.headers),
        "query": request.args
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

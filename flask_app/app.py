from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Flask!"

@app.route("/<path:path>", methods=["GET", "POST", "PUT", "DELETE"])
def catch_all(path):
    return f"Catch-all path: {path}", 200


@app.route("/hello")
def hello():
    return "Welcome to the /hello endpoint"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

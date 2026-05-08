"""Skybyte greeting service."""

import os
import signal
import time

from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest
from prometheus_client import CONTENT_TYPE_LATEST

app = Flask(__name__)

VERSION = "1.0.0"
API_TOKEN = os.environ.get("API_TOKEN", "")

shutting_down = False

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ["method", "path"],
)


def handle_sigterm(signum, frame):
    global shutting_down
    shutting_down = True


signal.signal(signal.SIGTERM, handle_sigterm)


@app.before_request
def before_request():
    request.start_time = time.time()


@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time

    REQUEST_COUNT.labels(
        method=request.method,
        path=request.path,
        status=response.status_code,
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        path=request.path,
    ).observe(request_latency)

    return response


@app.route("/")
def hello():
    return jsonify(
        {
            "message": "Hello, Candidate",
            "version": VERSION,
        }
    )


@app.route("/health")
def health():
    return "ok", 200


@app.route("/ready")
def ready():
    if shutting_down:
        return "shutting down", 503

    return "ready", 200


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": CONTENT_TYPE_LATEST,
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

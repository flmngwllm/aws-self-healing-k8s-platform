from fastapi import FastAPI
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import PlainTextResponse
from fastapi import HTTPException

app = FastAPI()

REQUEST_COUNT = Counter("request_count", "Total number of requests")

@app.get("/")
def read_root():
    REQUEST_COUNT.inc()
    return {"message": "Welcome to the app!"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/metrics")
def metrics():
    return PlainTextResponse(generate_latest().decode("utf-8"), media_type=CONTENT_TYPE_LATEST)
@app.get("/fail")
def fail():
    REQUEST_COUNT.inc()
    raise HTTPException(status_code=500, detail="This endpoint always fails")

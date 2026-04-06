from fastapi import FastAPI
from pydantic import BaseModel
from .awsutils import send_sns_alert, save_alert_to_dynamodb, get_incidents_from_dynamodb

app = FastAPI()

class Alert(BaseModel):
    id: str
    severity: str
    message: str

@app.get("/")
def root():
    return {"message": "Remediation service is now running!"}

@app.get("/incidents")
def get_incidents():
    print({"message": "List of incidents."})
    incidents = get_incidents_from_dynamodb()
    return {"incidents": incidents}

@app.post("/alert")
async def receive_alert(alert: Alert):
    print(f"Received alert: {alert.id} with severity {alert.severity} and message: {alert.message}")
    save_alert_to_dynamodb(alert.id, alert.severity, alert.message)
    send_sns_alert(alert.id, alert.severity, alert.message)
    return {"status": "alert received"}
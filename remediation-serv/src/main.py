from fastapi import FastAPI
from pydantic import BaseModel
from .awsutils import send_sns_alert, save_alert_to_dynamodb, get_incidents_from_dynamodb
from fastapi import Request
from .k8_utils import restart_deployment

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
async def receive_alert(request: Request):

    payload = await request.json()
  
    if "alerts" in payload:
        for alert in payload["alerts"]:
            alert_id = alert.get("labels", {}).get("alertname", "unknown-alert")
            severity = alert.get("labels", {}).get("severity", "unknown")
            message = (
                alert.get("annotations", {}).get("description") or 
                alert.get("annotations", {}).get("summary") or "No message provided"
            )

            print(f"Received alert: {alert_id} with severity {severity} and message: {message}")

            remediation_action = None

            if alert_id == "SelfHealAppDown":
                restart_deployment("self-heal-app-deployment")
                remediation_action = "Restarted deployment: self-heal-app-deployment"

            save_alert_to_dynamodb(alert_id, severity, message, remediation_action)
            send_sns_alert(alert_id, severity, message)
        return {"status": "alerts received"}

    alert = Alert(**payload)
    print(f"Received alert: {alert.id} with severity {alert.severity} and message: {alert.message}")

    remediation_action = None

    if alert.id == "SelfHealAppDown":
        restart_deployment("self-heal-app-deployment")
        print("Restarted deployment: self-heal-app-deployment")
        remediation_action = "Restarted deployment: self-heal-app-deployment"

    save_alert_to_dynamodb(alert.id, alert.severity, alert.message, remediation_action)
    send_sns_alert(alert.id, alert.severity, alert.message)

    return {"status": "alert received"}
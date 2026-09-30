import base64
import json
import os
import textwrap
from typing import Optional

import functions_framework
import requests

# ==== Config via env vars ====
# US: https://api.opsgenie.com    EU: https://api.eu.opsgenie.com
OPSGENIE_API_BASE = os.environ.get("OPSGENIE_API_URL")
OPSGENIE_API_KEY = os.environ["OPSGENIE_API_KEY"]  # stored in Secret Manager
# OPSGENIE_TEAM = os.environ.get("OPSGENIE_TEAM")    # optional (exact team name in Opsgenie)

# Map SCC severity to Opsgenie priority
SEVERITY_TO_PRIORITY = {
    "CRITICAL": "P1",
    "HIGH": "P2",
}

VALID_SEVERITIES = set(SEVERITY_TO_PRIORITY.keys())


def _opsgenie_payload_from_finding(finding: dict) -> Optional[dict]:
    """Return an Opsgenie create-alert payload or None if the finding should be skipped."""
    if not finding:
        return None

    # The message can be either a raw finding or SCC NotificationMessage with "finding" field.
    f = finding

    # Finding class appears as "findingClass" in SCC JSON. (We also try snake_case just in case.)
    fclass = f.get("findingClass") or f.get("finding_class") or ""
    severity = f.get("severity", "")
    state = f.get("state", "")

    # Only THREAT + ACTIVE + severity HIGH/CRITICAL
    if fclass != "THREAT" or state != "ACTIVE" or severity not in VALID_SEVERITIES:
        return None

    alias = f.get("name")  # unique id for de-duplication in Opsgenie
    category = f.get("category", "Unspecified")
    event_time = f.get("eventTime") or f.get("event_time")
    resource_name = f.get("resourceName") or (f.get("resource") or {}).get("name")
    external_uri = f.get("externalUri") or f.get("external_uri")

    message = f"{severity} THREAT: {category}"
    description_lines = [
        f"SCC finding: {alias}",
        f"Category: {category}",
        f"Severity: {severity}",
        f"State: {state}",
        f"Event time: {event_time}",
        f"Resource: {resource_name}",
    ]
    if external_uri:
        description_lines.append(f"Reference: {external_uri}")

    payload = {
        "message": message[:130],  # Opsgenie message limit
        "alias": alias,
        "description": textwrap.dedent("\n".join(description_lines)).strip(),
        "priority": SEVERITY_TO_PRIORITY[severity],
        "source": "GCP Security Command Center",
        "tags": ["SCC", "THREAT", severity, category],
        # Put rich data under 'details' so it shows up in the alert:
        "details": {
            "scc.finding.name": alias,
            "scc.finding.category": category,
            "scc.finding.severity": severity,
            "scc.finding.state": state,
            "scc.finding.event_time": event_time or "",
            "scc.finding.resource": resource_name or "",
            "scc.finding.external_uri": external_uri or "",
            "scc.finding.finding_class": fclass,
        },
    }

    # if OPSGENIE_TEAM:
    #     # Send to a specific team (by name)
    #     payload["responders"] = [{"type": "team", "name": OPSGENIE_TEAM}]

    return payload


def _create_opsgenie_alert(payload: dict) -> str:
    url = f"{OPSGENIE_API_BASE}/v2/alerts"
    headers = {
        "Authorization": f"GenieKey {OPSGENIE_API_KEY}",
        "Content-Type": "application/json",
    }
    resp = requests.post(url, json=payload, headers=headers, timeout=15)
    # Opsgenie returns 202 Accepted for create; raise_for_status ignores 202 (it only raises on 4xx/5xx).
    resp.raise_for_status()
    return f"Opsgenie responded with {resp.status_code}"


@functions_framework.cloud_event
def scc_to_opsgenie(cloud_event):
    """
    CloudEvent handler for Pub/Sub push from SCC NotificationConfig.
    Expects the SCC NotificationMessage data in Pub/Sub 'message.data' (base64 JSON).
    """
    envelope = cloud_event.data or {}
    msg = envelope.get("message", {})
    data_b64 = msg.get("data", "")
    if not data_b64:
        return "No data; skipping"

    try:
        body = json.loads(base64.b64decode(data_b64).decode("utf-8"))
    except Exception:
        return "Bad payload; skipping"

    # SCC publishes either { finding: {...} } or just a finding-shaped object.
    finding = body.get("finding") or body
    payload = _opsgenie_payload_from_finding(finding)
    if not payload:
        return "Finding didn't match THREAT/HIGH|CRITICAL/ACTIVE; skipped"

    return _create_opsgenie_alert(payload)

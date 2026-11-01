from pydantic import Field, field_validator

from dotenv import load_dotenv
import os

import mysql.connector
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Literal

from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct


# ============================================================
# Configuration
# ============================================================

load_dotenv()

COLLECTION_NAME = "complaints"
MATCH_THRESHOLD = 0.50


# ============================================================
# FastAPI application
# ============================================================

app = FastAPI(title="ResolveIQ API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# AI + Vector Database
# ============================================================

model = SentenceTransformer("all-MiniLM-L6-v2")

qdrant = QdrantClient(
    path="./qdrant_storage"
)


# ============================================================
# Request Models
# ============================================================

class ComplaintRequest(BaseModel):
    subject: str = Field(min_length=5, max_length=200)
    description: str = Field(min_length=10, max_length=5000)
    product_id: int = Field(gt=0)
    category_id: int = Field(gt=0)
    priority_id: int = Field(gt=0)

    @field_validator("subject", "description")
    @classmethod
    def validate_text(cls, value):
        value = value.strip()
        if not value:
            raise ValueError("Text cannot be empty")
        return value
class MatchStatusUpdate(BaseModel):
    match_status: Literal["Accepted", "Rejected"]


# ============================================================
# MySQL Connection
# ============================================================

def get_mysql_connection():
    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )


# ============================================================
# Health Check
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "ResolveIQ API"
    }


# ============================================================
# Create Complaint + AI Matching
# ============================================================

@app.post("/complaints")
def create_complaint(request: ComplaintRequest):

    conn = get_mysql_connection()
    cursor = conn.cursor()

    try:

        # 1. Insert complaint into MySQL

        cursor.execute(
            """
            INSERT INTO COMPLAINT
            (
                customer_id,
                product_id,
                category_id,
                priority_id,
                status_id,
                subject,
                description
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                1,
                request.product_id,
                request.category_id,
                request.priority_id,
                1,
                request.subject,
                request.description
            )
        )

        complaint_id = cursor.lastrowid

        conn.commit()

        # 2. Generate embedding

        text = f"{request.subject}. {request.description}"

        vector = model.encode(text).tolist()

        # 3. Search Qdrant for similar complaints

        results = qdrant.query_points(
            collection_name=COLLECTION_NAME,
            query=vector,
            limit=3
        ).points

        matches = []

        # 4. Save useful matches to MySQL

        for result in results:

            matched_id = result.payload["complaint_id"]
            similarity = float(result.score)

            if similarity >= MATCH_THRESHOLD:

                # Check for duplicate match

                cursor.execute(
                    """
                    SELECT match_id
                    FROM COMPLAINT_MATCH
                    WHERE complaint_id = %s
                      AND matched_complaint_id = %s
                    """,
                    (
                        complaint_id,
                        matched_id
                    )
                )

                existing = cursor.fetchone()

                if existing is None:

                    cursor.execute(
                        """
                        INSERT INTO COMPLAINT_MATCH
                        (
                            complaint_id,
                            matched_complaint_id,
                            similarity_score,
                            match_status
                        )
                        VALUES (%s, %s, %s, 'Suggested')
                        """,
                        (
                            complaint_id,
                            matched_id,
                            similarity
                        )
                    )

                    match_id = cursor.lastrowid

                    matches.append(
                        {
                            "match_id": match_id,
                            "complaint_id": matched_id,
                            "subject": result.payload["subject"],
                            "description": result.payload["description"],
                            "similarity": round(similarity, 4),
                            "match_status": "Suggested"
                        }
                    )

        # 5. Add new complaint to Qdrant

        qdrant.upsert(
            collection_name=COLLECTION_NAME,
            points=[
                PointStruct(
                    id=complaint_id,
                    vector=vector,
                    payload={
                        "complaint_id": complaint_id,
                        "subject": request.subject,
                        "description": request.description
                    }
                )
            ]
        )

        # 6. Commit MySQL changes

        conn.commit()

        return {
            "success": True,
            "complaint_id": complaint_id,
            "matches": matches
        }

    finally:
        cursor.close()
        conn.close()


# ============================================================
# Get Active Complaints Assigned to an Agent
# ============================================================

@app.get("/agents/{agent_id}/complaints")
def get_agent_complaints(agent_id: int):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        cursor.execute(
            """
            SELECT
                c.complaint_id,
                c.subject,
                c.description,
                c.created_at,
                p.priority_name,
                cs.status_name,
                cu.customer_name,
                ca.assignment_status

            FROM COMPLAINT_ASSIGNMENT ca

            JOIN COMPLAINT c
                ON ca.complaint_id = c.complaint_id

            JOIN CUSTOMER cu
                ON c.customer_id = cu.customer_id

            JOIN PRIORITY p
                ON c.priority_id = p.priority_id

            JOIN COMPLAINT_STATUS cs
                ON c.status_id = cs.status_id

            WHERE ca.agent_id = %s
              AND ca.assignment_status = 'Active'

            ORDER BY
                p.severity_level DESC,
                c.created_at DESC
            """,
            (agent_id,)
        )

        complaints = cursor.fetchall()

        return {
            "success": True,
            "agent_id": agent_id,
            "complaints": complaints
        }

    finally:
        cursor.close()
        conn.close()


# ============================================================
# Get AI Matches for a Complaint
# ============================================================

@app.get("/complaints/{complaint_id}/matches")
def get_complaint_matches(complaint_id: int):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        cursor.execute(
            """
            SELECT
                cm.match_id,
                cm.matched_complaint_id AS complaint_id,
                mc.subject,
                mc.description,
                cm.similarity_score AS similarity,
                cm.match_status

            FROM COMPLAINT_MATCH cm

            JOIN COMPLAINT mc
                ON cm.matched_complaint_id = mc.complaint_id

            WHERE cm.complaint_id = %s

            ORDER BY cm.similarity_score DESC
            """,
            (complaint_id,)
        )

        matches = cursor.fetchall()

        for match in matches:
            match["similarity"] = float(match["similarity"])

        return {
            "success": True,
            "complaint_id": complaint_id,
            "matches": matches
        }

    finally:
        cursor.close()
        conn.close()


# ============================================================
# Accept / Reject an AI Match
# ============================================================

@app.patch("/matches/{match_id}/status")
def update_match_status(
    match_id: int,
    request: MatchStatusUpdate
):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        # Check whether the match exists

        cursor.execute(
            """
            SELECT match_id, match_status
            FROM COMPLAINT_MATCH
            WHERE match_id = %s
            """,
            (match_id,)
        )

        match = cursor.fetchone()

        if match is None:
            raise HTTPException(
                status_code=404,
                detail="AI match not found"
            )

        # Update the match status

        cursor.execute(
            """
            UPDATE COMPLAINT_MATCH
            SET match_status = %s
            WHERE match_id = %s
            """,
            (
                request.match_status,
                match_id
            )
        )

        conn.commit()

        return {
            "success": True,
            "message": "AI match status updated successfully",
            "match_id": match_id,
            "match_status": request.match_status
        }

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
        conn.close()


# ============================================================
# Get Support Agents
# ============================================================

@app.get("/agents")
def get_agents():

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        cursor.execute(
            """
            SELECT
                sa.agent_id,
                sa.agent_name,
                sd.department_name
            FROM SUPPORT_AGENT sa
            JOIN SUPPORT_DEPARTMENT sd
                ON sa.department_id = sd.department_id
            ORDER BY sa.agent_id
            """
        )

        agents = cursor.fetchall()

        return {
            "success": True,
            "agents": agents
        }

    finally:
        cursor.close()
        conn.close()



# ============================================================
# CUSTOMER COMPLAINT TRACKING
# ============================================================

class AgentUpdateRequest(BaseModel):
    agent_id: int = Field(gt=0)
    update_type: Literal[
        "Suggestion",
        "Progress Update",
        "Resolution"
    ]
    update_message: str = Field(min_length=1, max_length=2000)
    status_name: Literal[
        "Open",
        "In Progress",
        "Resolved",
        "Closed"
    ] | None = None

    @field_validator("update_message")
    @classmethod
    def validate_message(cls, value):
        value = value.strip()
        if not value:
            raise ValueError("Update message cannot be empty")
        return value
@app.get("/customers")
def get_customers():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT customer_id, customer_name
            FROM CUSTOMER
            ORDER BY customer_name
        """)
        return {"success": True, "customers": cursor.fetchall()}
    finally:
        cursor.close()
        conn.close()


@app.get("/customers/{customer_id}/complaints")
def get_customer_complaints(customer_id: int):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT
                c.complaint_id,
                c.subject,
                c.description,
                c.created_at,
                cs.status_name,
                p.priority_name,
                sa.agent_id,
                sa.agent_name,
                sd.department_name,
                ca.assignment_status
            FROM COMPLAINT c
            JOIN COMPLAINT_STATUS cs
                ON cs.status_id = c.status_id
            JOIN PRIORITY p
                ON p.priority_id = c.priority_id
            LEFT JOIN COMPLAINT_ASSIGNMENT ca
                ON ca.complaint_id = c.complaint_id
                AND ca.assignment_status = 'Active'
            LEFT JOIN SUPPORT_AGENT sa
                ON sa.agent_id = ca.agent_id
            LEFT JOIN SUPPORT_DEPARTMENT sd
                ON sd.department_id = sa.department_id
            WHERE c.customer_id = %s
            ORDER BY c.created_at DESC, c.complaint_id DESC
        """, (customer_id,))
        return {"success": True, "complaints": cursor.fetchall()}
    finally:
        cursor.close()
        conn.close()


@app.get("/complaints/{complaint_id}/updates")
def get_complaint_updates(complaint_id: int):
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT
                u.update_id,
                u.complaint_id,
                u.update_type,
                u.update_message,
                u.created_at,
                sa.agent_id,
                sa.agent_name,
                sd.department_name
            FROM COMPLAINT_AGENT_UPDATE u
            JOIN SUPPORT_AGENT sa
                ON sa.agent_id = u.agent_id
            JOIN SUPPORT_DEPARTMENT sd
                ON sd.department_id = sa.department_id
            WHERE u.complaint_id = %s
            ORDER BY u.created_at DESC, u.update_id DESC
        """, (complaint_id,))
        return {"success": True, "updates": cursor.fetchall()}
    finally:
        cursor.close()
        conn.close()


@app.post("/complaints/{complaint_id}/updates")
def create_complaint_update(
    complaint_id: int,
    request: AgentUpdateRequest
):
    allowed_types = ("Suggestion", "Progress Update", "Resolution")
    allowed_statuses = ("Open", "In Progress", "Resolved", "Closed")

    message = request.update_message.strip()

    if request.update_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Invalid update type"
        )

    if not message or len(message) > 2000:
        raise HTTPException(
            status_code=400,
            detail="Message must contain 1 to 2000 characters"
        )

    if request.status_name is not None and request.status_name not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail="Invalid complaint status"
        )

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT assignment_id
            FROM COMPLAINT_ASSIGNMENT
            WHERE complaint_id = %s
              AND agent_id = %s
              AND assignment_status = 'Active'
            LIMIT 1
        """, (complaint_id, request.agent_id))

        if cursor.fetchone() is None:
            raise HTTPException(
                status_code=403,
                detail="This agent is not actively assigned to this complaint"
            )

        cursor.execute("""
            INSERT INTO COMPLAINT_AGENT_UPDATE
                (complaint_id, agent_id, update_type, update_message)
            VALUES (%s, %s, %s, %s)
        """, (
            complaint_id,
            request.agent_id,
            request.update_type,
            message
        ))

        update_id = cursor.lastrowid

        if request.status_name:
            cursor.execute("""
                SELECT status_id
                FROM COMPLAINT_STATUS
                WHERE status_name = %s
            """, (request.status_name,))

            status = cursor.fetchone()

            if status is None:
                raise HTTPException(
                    status_code=400,
                    detail="Complaint status was not found"
                )

            if request.status_name in ("Resolved", "Closed"):
                cursor.execute("""
                    UPDATE COMPLAINT
                    SET status_id = %s,
                        resolved_at = CURRENT_TIMESTAMP
                    WHERE complaint_id = %s
                """, (status["status_id"], complaint_id))
            else:
                cursor.execute("""
                    UPDATE COMPLAINT
                    SET status_id = %s,
                        resolved_at = NULL
                    WHERE complaint_id = %s
                """, (status["status_id"], complaint_id))

        conn.commit()

        return {
            "success": True,
            "update_id": update_id,
            "message": "Customer update posted successfully"
        }

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
        conn.close()

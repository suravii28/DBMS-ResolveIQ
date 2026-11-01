from dotenv import load_dotenv
import os
import mysql.connector

from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient

load_dotenv()

# -------------------------
# New complaint
# -------------------------

new_complaint = (
    "The payment was unsuccessful, but the amount "
    "has been deducted from my bank account."
)

# -------------------------
# Connect to MySQL
# -------------------------

conn = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE")
)

cursor = conn.cursor()

# -------------------------
# Load model + Qdrant
# -------------------------

model = SentenceTransformer("all-MiniLM-L6-v2")

client = QdrantClient(path="./qdrant_storage")

# -------------------------
# Generate embedding
# -------------------------

query_vector = model.encode(new_complaint).tolist()

# -------------------------
# Search Qdrant
# -------------------------

results = client.query_points(
    collection_name="complaints",
    query=query_vector,
    limit=3
).points

print("\nNew complaint:")
print(new_complaint)

print("\nMost similar historical complaints:")

for result in results:

    matched_id = result.payload["complaint_id"]
    similarity = result.score

    print("\n-------------------------")
    print("Complaint ID:", matched_id)
    print("Subject:", result.payload["subject"])
    print("Similarity:", round(similarity, 4))

    # Store only strong matches
    if similarity >= 0.50:

        cursor.execute("""
            SELECT match_id
            FROM COMPLAINT_MATCH
            WHERE complaint_id = %s
              AND matched_complaint_id = %s
        """, (0, matched_id))

        existing = cursor.fetchone()

        if existing is None:
            print("Would store this match.")

conn.commit()

cursor.close()
conn.close()

from dotenv import load_dotenv
import os
import mysql.connector

from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

load_dotenv()

# -------------------------
# Connect to MySQL
# -------------------------

conn = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE")
)

cursor = conn.cursor(dictionary=True)

cursor.execute("""
    SELECT complaint_id, subject, description
    FROM COMPLAINT
    ORDER BY complaint_id
""")

complaints = cursor.fetchall()

cursor.close()
conn.close()

# -------------------------
# Load embedding model
# -------------------------

model = SentenceTransformer("all-MiniLM-L6-v2")

# -------------------------
# Create local Qdrant
# -------------------------

client = QdrantClient(path="./qdrant_storage")

collection_name = "complaints"

# Create collection if it doesn't exist
if not client.collection_exists(collection_name):
    client.create_collection(
        collection_name=collection_name,
        vectors_config=VectorParams(
            size=384,
            distance=Distance.COSINE
        )
    )

# -------------------------
# Generate and store vectors
# -------------------------

points = []

for complaint in complaints:

    text = f"{complaint['subject']}. {complaint['description']}"

    vector = model.encode(text).tolist()

    points.append(
        PointStruct(
            id=complaint["complaint_id"],
            vector=vector,
            payload={
                "complaint_id": complaint["complaint_id"],
                "subject": complaint["subject"],
                "description": complaint["description"]
            }
        )
    )

client.upsert(
    collection_name=collection_name,
    points=points
)

print(f"Stored {len(points)} complaint vectors in Qdrant.")

print("\nCollection information:")
print(client.get_collection(collection_name))

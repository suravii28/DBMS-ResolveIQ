from mysql.connector import connect
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct
import os

load_dotenv()

COLLECTION_NAME = "complaints"

# Connect to MySQL
conn = connect(
    host=os.getenv("MYSQL_HOST"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE")
)

cursor = conn.cursor(dictionary=True)

# Load embedding model
model = SentenceTransformer("all-MiniLM-L6-v2")

# Connect to local Qdrant
qdrant = QdrantClient(path="./qdrant_storage")

# Fetch complaints missing from Qdrant
points, _ = qdrant.scroll(
    collection_name=COLLECTION_NAME,
    limit=1000,
    with_payload=True,
    with_vectors=False
)

stored_ids = {
    point.payload["complaint_id"]
    for point in points
}

cursor.execute("""
    SELECT complaint_id, subject, description
    FROM COMPLAINT
    ORDER BY complaint_id
""")

complaints = cursor.fetchall()

missing = [
    complaint for complaint in complaints
    if complaint["complaint_id"] not in stored_ids
]

print("Missing complaints:", len(missing))

for complaint in missing:
    text = f"{complaint['subject']}. {complaint['description']}"
    vector = model.encode(text).tolist()

    qdrant.upsert(
        collection_name=COLLECTION_NAME,
        points=[
            PointStruct(
                id=complaint["complaint_id"],
                vector=vector,
                payload={
                    "complaint_id": complaint["complaint_id"],
                    "subject": complaint["subject"],
                    "description": complaint["description"]
                }
            )
        ]
    )

    print("Indexed complaint:", complaint["complaint_id"])

print("Final Qdrant count:",
      qdrant.count(COLLECTION_NAME, exact=True).count)

cursor.close()
conn.close()
qdrant.close()

print("Qdrant synchronization completed.")

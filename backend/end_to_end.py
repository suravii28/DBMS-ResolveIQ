from dotenv import load_dotenv
import os
import mysql.connector

from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient

load_dotenv()

# =========================================================
# 1. New complaint details
# =========================================================

customer_id = 1
product_id = 3
category_id = 2
priority_id = 3
status_id = 1

subject = "Payment unsuccessful but amount deducted"
description = (
    "The payment was unsuccessful, but the amount "
    "has been deducted from my bank account."
)

# =========================================================
# 2. Connect to MySQL
# =========================================================

conn = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE")
)

cursor = conn.cursor()

# =========================================================
# 3. Insert the new complaint
# =========================================================

cursor.execute("""
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
""", (
    customer_id,
    product_id,
    category_id,
    priority_id,
    status_id,
    subject,
    description
))

new_complaint_id = cursor.lastrowid

conn.commit()

print(f"\nNew complaint created with ID: {new_complaint_id}")

# =========================================================
# 4. Generate embedding
# =========================================================

model = SentenceTransformer("all-MiniLM-L6-v2")

text = f"{subject}. {description}"

query_vector = model.encode(text).tolist()

# =========================================================
# 5. Search Qdrant
# =========================================================

client = QdrantClient(path="./qdrant_storage")

results = client.query_points(
    collection_name="complaints",
    query=query_vector,
    limit=3
).points

print("\nSimilar historical complaints:")

# =========================================================
# 6. Store strong matches in COMPLAINT_MATCH
# =========================================================

for result in results:

    matched_id = result.payload["complaint_id"]
    similarity = result.score

    print(
        f"Complaint {matched_id} "
        f"| similarity = {similarity:.4f}"
    )

    # Don't match the complaint with itself
    if matched_id == new_complaint_id:
        continue

    # Store only strong matches
    if similarity >= 0.50:

        cursor.execute("""
            SELECT match_id
            FROM COMPLAINT_MATCH
            WHERE complaint_id = %s
              AND matched_complaint_id = %s
        """, (
            new_complaint_id,
            matched_id
        ))

        existing = cursor.fetchone()

        if existing is None:

            cursor.execute("""
                INSERT INTO COMPLAINT_MATCH
                (
                    complaint_id,
                    matched_complaint_id,
                    similarity_score,
                    match_status
                )
                VALUES (%s, %s, %s, 'Suggested')
            """, (
                new_complaint_id,
                matched_id,
                similarity
            ))

            print("  → Match stored as Suggested")

conn.commit()

cursor.close()
conn.close()

print("\nEnd-to-end matching completed successfully.")

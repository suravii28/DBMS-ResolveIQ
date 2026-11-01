from dotenv import load_dotenv
import os
import mysql.connector
from sentence_transformers import SentenceTransformer

load_dotenv()

# Connect to MySQL
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

# Load embedding model
model = SentenceTransformer("all-MiniLM-L6-v2")

# Generate embeddings
for complaint in complaints:
    text = f"{complaint['subject']}. {complaint['description']}"

    vector = model.encode(text)

    print(f"\nComplaint {complaint['complaint_id']}")
    print(f"Text: {text}")
    print(f"Vector dimensions: {len(vector)}")
    print(f"First 5 values: {vector[:5]}")

cursor.close()
conn.close()

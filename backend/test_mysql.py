from dotenv import load_dotenv
import os
import mysql.connector

load_dotenv()

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

for complaint in complaints:
    print(f"\nComplaint {complaint['complaint_id']}")
    print(f"Subject: {complaint['subject']}")
    print(f"Description: {complaint['description']}")

cursor.close()
conn.close()

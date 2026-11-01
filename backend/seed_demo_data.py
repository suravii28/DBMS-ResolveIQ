import os
import mysql.connector
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct

load_dotenv()

COLLECTION = "complaints"

CUSTOMERS = [
    ("Aarav Mehta", "9876501001"),
    ("Diya Sharma", "9876501002"),
    ("Vivaan Patel", "9876501003"),
    ("Ananya Reddy", "9876501004"),
    ("Ishaan Gupta", "9876501005"),
    ("Saanvi Nair", "9876501006"),
    ("Aditya Rao", "9876501007"),
    ("Myra Kapoor", "9876501008"),
    ("Reyansh Joshi", "9876501009"),
    ("Aadhya Iyer", "9876501010"),
    ("Krishna Menon", "9876501011"),
    ("Pari Desai", "9876501012"),
    ("Arjun Kulkarni", "9876501013"),
    ("Kiara Malhotra", "9876501014"),
    ("Rohan Verma", "9876501015"),
]

# subject, description, product_id, category_id, priority_id, agent_id
COMPLAINTS = [
    ("Mobile app freezes after OTP verification",
     "The banking application freezes immediately after I enter the OTP during login.",
     1, 1, 3, 3),

    ("Unable to update registered mobile number",
     "I cannot update my registered phone number through the mobile banking application.",
     1, 5, 2, 7),

    ("Unexpected annual card fee",
     "An annual maintenance fee was charged even though my credit card was advertised as free.",
     2, 2, 3, 4),

    ("Duplicate debit for online purchase",
     "My account was debited twice for a single online purchase made using the payment gateway.",
     3, 2, 4, 8),

    ("Refund not received after cancellation",
     "My order was cancelled several days ago but the refund has not appeared in my account.",
     4, 4, 3, 6),

    ("Card transaction repeatedly declined",
     "My credit card transactions are being declined at multiple merchants despite sufficient balance.",
     2, 3, 3, 9),

    ("Banking app shows incorrect account balance",
     "The available balance displayed in the mobile banking application does not match my actual account balance.",
     1, 1, 3, 7),

    ("Payment gateway timeout during checkout",
     "The checkout page times out whenever I try to complete a payment through the online gateway.",
     3, 1, 2, 3),

    ("Delivery package marked delivered but missing",
     "The delivery tracking page says my package was delivered, but I have not received it.",
     4, 4, 4, 10),

    ("Unable to reset banking password",
     "The password reset link is not working and I cannot access my online banking account.",
     1, 5, 3, 7),

    ("Incorrect foreign transaction charge",
     "My credit card statement contains an unexpected foreign transaction fee for a domestic purchase.",
     2, 2, 2, 4),

    ("Payment deducted multiple times",
     "The payment gateway processed the same transaction multiple times and deducted the amount repeatedly.",
     3, 2, 4, 8),

    ("Mobile application crashes while transferring money",
     "The mobile banking application closes unexpectedly whenever I try to transfer money.",
     1, 1, 3, 3),

    ("Replacement credit card not delivered",
     "I requested a replacement credit card, but the card has not arrived within the promised delivery period.",
     2, 4, 2, 10),

    ("Order delivered with damaged packaging",
     "My home delivery order arrived with severely damaged packaging and some items were missing.",
     4, 4, 3, 6),

    ("Incorrect transaction history",
     "The mobile banking application displays transactions that do not match my actual account activity.",
     1, 1, 3, 3),

    ("Online payment stuck in processing",
     "My online payment has remained in processing status for several hours and the amount has been deducted.",
     3, 2, 3, 8),

    ("Credit card limit not updated",
     "My credit card limit has not been updated even after the previous outstanding balance was paid.",
     2, 3, 2, 9),

    ("Delivery agent did not attempt delivery",
     "The tracking system reports a failed delivery attempt, but nobody contacted me or visited my address.",
     4, 4, 2, 10),

    ("Cannot access transaction statement",
     "The mobile banking application displays an error whenever I try to download my account statement.",
     1, 5, 2, 7),
]


def main():
    conn = mysql.connector.connect(
        host=os.getenv("MYSQL_HOST"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )

    cursor = conn.cursor(dictionary=True)
    qdrant = None
    inserted_ids = []

    try:
        # Prevent accidental duplicate execution.
        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM USER_ACCOUNT
            WHERE username LIKE 'demo_customer_%'
        """)

        if cursor.fetchone()["total"] > 0:
            raise RuntimeError(
                "Demo customers already exist. Stopping to prevent duplicates."
            )

        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM SUPPORT_AGENT
        """)

        if cursor.fetchone()["total"] < 10:
            raise RuntimeError("Expected at least 10 support agents.")

        cursor.execute("""
            SELECT agent_id, department_id
            FROM SUPPORT_AGENT
        """)

        agents = {
            row["agent_id"]: row["department_id"]
            for row in cursor.fetchall()
        }

        for _, _, _, category_id, _, agent_id in COMPLAINTS:
            expected_department = {
                1: 1,  # Technical Support
                2: 2,  # Billing
                3: 3,  # Product Support
                4: 4,  # Delivery & Logistics
                5: 1,  # Account-related technical support
            }[category_id]

            if agents.get(agent_id) != expected_department:
                raise RuntimeError(
                    f"Agent {agent_id} does not match category {category_id}."
                )

        model = SentenceTransformer("all-MiniLM-L6-v2")
        qdrant = QdrantClient(path="./qdrant_storage")

        # Create customer accounts and customer profiles.
        customer_ids = []

        for index, (name, phone) in enumerate(CUSTOMERS, start=1):
            username = f"demo_customer_{index:02d}"
            email = f"{username}@resolveiq.demo"

            cursor.execute("""
                INSERT INTO USER_ACCOUNT
                (role_id, username, password_hash, email, account_status)
                VALUES (1, %s, SHA2(UUID(), 256), %s, 'Active')
            """, (username, email))

            user_id = cursor.lastrowid

            cursor.execute("""
                INSERT INTO CUSTOMER
                (user_id, customer_name, phone)
                VALUES (%s, %s, %s)
            """, (user_id, name, phone))

            customer_ids.append(cursor.lastrowid)

        print("Created 15 customer accounts.")

        # Create complaints and assignments.
        complaint_records = []

        for index, item in enumerate(COMPLAINTS):
            subject, description, product_id, category_id, priority_id, agent_id = item

            customer_id = customer_ids[index % len(customer_ids)]

            cursor.execute("""
                INSERT INTO COMPLAINT
                (customer_id, product_id, category_id, priority_id,
                 status_id, subject, description)
                VALUES (%s, %s, %s, %s, 2, %s, %s)
            """, (
                customer_id,
                product_id,
                category_id,
                priority_id,
                subject,
                description
            ))

            complaint_id = cursor.lastrowid
            inserted_ids.append(complaint_id)

            cursor.execute("""
                INSERT INTO COMPLAINT_ASSIGNMENT
                (complaint_id, agent_id, assignment_status)
                VALUES (%s, %s, 'Active')
            """, (complaint_id, agent_id))

            complaint_records.append({
                "complaint_id": complaint_id,
                "subject": subject,
                "description": description
            })

        print("Created 20 complaints and their assignments.")

        # Generate embeddings.
        vectors = model.encode([
            f"{record['subject']}. {record['description']}"
            for record in complaint_records
        ]).tolist()

        # Index all new complaints in Qdrant.
        qdrant.upsert(
            collection_name=COLLECTION,
            points=[
                PointStruct(
                    id=record["complaint_id"],
                    vector=vector,
                    payload=record
                )
                for record, vector in zip(complaint_records, vectors)
            ]
        )

        print("Indexed 20 new complaints in Qdrant.")

        # Generate similarity matches for each new complaint.
        match_count = 0

        for record, vector in zip(complaint_records, vectors):
            results = qdrant.query_points(
                collection_name=COLLECTION,
                query=vector,
                limit=4,
                with_payload=True
            ).points

            for result in results:
                matched_id = result.payload.get("complaint_id")

                if matched_id is None:
                    continue

                if matched_id == record["complaint_id"]:
                    continue

                if result.score < 0.50:
                    continue

                cursor.execute("""
                    INSERT IGNORE INTO COMPLAINT_MATCH
                    (complaint_id, matched_complaint_id,
                     similarity_score, match_status)
                    VALUES (%s, %s, %s, 'Suggested')
                """, (
                    record["complaint_id"],
                    matched_id,
                    round(result.score, 4)
                ))

                match_count += cursor.rowcount

        # Commit only after the database and vector operations succeed.
        conn.commit()

        print("\nDEMO DATA CREATION SUCCESSFUL")
        print("New customers:", len(customer_ids))
        print("New complaints:", len(inserted_ids))
        print("New assignments:", len(inserted_ids))
        print("New AI matches:", match_count)
        print(
            "Total Qdrant points:",
            qdrant.count(COLLECTION, exact=True).count
        )

    except Exception:
        conn.rollback()

        # Remove new Qdrant points if SQL insertion fails.
        if qdrant is not None and inserted_ids:
            qdrant.delete(
                collection_name=COLLECTION,
                points_selector=inserted_ids
            )

        raise

    finally:
        cursor.close()
        conn.close()

        if qdrant is not None:
            qdrant.close()


if __name__ == "__main__":
    main()

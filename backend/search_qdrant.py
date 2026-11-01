from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient

# Load embedding model
model = SentenceTransformer("all-MiniLM-L6-v2")

# Connect to local Qdrant
client = QdrantClient(path="./qdrant_storage")

# New complaint
new_complaint = (
    "My payment didn't go through but the money was "
    "taken from my account."
)

# Convert new complaint into a vector
query_vector = model.encode(new_complaint).tolist()

# Search Qdrant
results = client.query_points(
    collection_name="complaints",
    query=query_vector,
    limit=3
).points

print("\nNew complaint:")
print(new_complaint)

print("\nMost similar historical complaints:")

for result in results:
    print("\n-------------------------")
    print("Complaint ID:", result.payload["complaint_id"])
    print("Subject:", result.payload["subject"])
    print("Similarity score:", result.score)

# ResolveIQ – Customer Complaint Matching & Resolution System

ResolveIQ is an AI-powered customer complaint management system developed as a DBMS Experiential Learning Project. It combines relational database management with vector-based semantic search to identify similar historical complaints and assist support agents in finding relevant resolutions.

The system allows customers to submit complaints through a web interface, while AI-powered semantic matching retrieves related complaints using text embeddings. Support agents can view assigned complaints, review AI-generated suggestions, and accept or reject matches.

## Key Features

- **Customer Complaint Submission:** Submit complaints with product, category, priority, and description.
- **AI-Powered Complaint Matching:** Identify semantically similar historical complaints using vector embeddings.
- **Vector Search:** Retrieve relevant complaints using Qdrant and cosine similarity.
- **Agent Dashboard:** View assigned complaints and their details.
- **Match Review:** Accept or reject AI-generated complaint matches.
- **Relational Data Management:** Store customers, agents, complaints, assignments, resolutions, and feedback in MySQL.

## Technology Stack

- Frontend: Next.js, React, TypeScript
- Backend: Python, FastAPI
- Relational Database: MySQL
- Vector Database: Qdrant
- Embedding Model: all-MiniLM-L6-v2
- Similarity Metric: Cosine Similarity

## Project Objective

The primary objective of ResolveIQ is to improve customer-support workflows by using historical complaint data and semantic search to help support agents identify similar cases and make informed resolution decisions.

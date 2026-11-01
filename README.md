# ResolveIQ – AI-Powered Customer Complaint Matching and Resolution System

ResolveIQ is a full-stack customer complaint management system that uses **AI-powered semantic similarity matching** to identify previously reported complaints and suggest relevant historical resolutions. It helps support agents handle recurring customer issues more efficiently by reducing repetitive investigation and improving complaint resolution workflows.

The system combines a relational database with vector search to manage structured complaint information and discover semantically similar complaints.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Proposed Solution](#3-proposed-solution)
4. [Key Features](#4-key-features)
5. [Technology Stack](#5-technology-stack)
6. [System Architecture](#6-system-architecture)
7. [Database Design](#7-database-design)
8. [AI and Semantic Matching](#8-ai-and-semantic-matching)
9. [Application Modules](#9-application-modules)
10. [API Endpoints](#10-api-endpoints)
11. [Project Structure](#11-project-structure)
12. [Installation and Setup](#12-installation-and-setup)
13. [Running the Application](#13-running-the-application)
14. [Database Setup](#14-database-setup)
15. [Future Enhancements](#15-future-enhancements)
16. [Team Members](#16-team-members)

---

## 1. Project Overview

Customer support teams frequently receive complaints about problems that have already been reported and resolved. Manually identifying similar complaints and searching for their previous solutions can consume considerable time and effort.

ResolveIQ addresses this problem by combining traditional database management with AI-based semantic search.

When a customer submits a complaint, the system processes its description, generates a numerical embedding, and searches for semantically similar historical complaints using a vector database. Relevant matches are presented to support agents, who can review the suggestions and use previous resolution information to assist with the current complaint.

The application also provides complaint tracking, agent assignment, status management, feedback, and resolution workflows.

## 2. Problem Statement

Traditional complaint management systems generally store complaints as individual records and rely on manual searches or basic keyword matching to identify recurring issues.

This creates several challenges:

- Repeated complaints require support agents to investigate similar problems again.
- Keyword-based searches may fail to identify complaints with different wording but similar meanings.
- Previous resolutions can be difficult to discover efficiently.
- Manual complaint handling increases response time and support workload.
- Customers may have limited visibility into the progress of their complaints.

ResolveIQ aims to address these challenges through structured complaint management and semantic similarity-based complaint retrieval.

## 3. Proposed Solution

ResolveIQ introduces an AI-assisted complaint management workflow.

1. Customers submit complaints through the web application.
2. Complaint information is stored in the MySQL relational database.
3. The complaint description is converted into an embedding using a sentence-transformer model.
4. The embedding is stored and searched in Qdrant, a vector database.
5. Similar historical complaints are retrieved based on semantic similarity.
6. Matching suggestions are stored and made available to support agents.
7. Agents can accept or reject suggestions and use relevant historical resolutions.
8. Customers can track complaint status and view progress updates.

This approach combines relational data management with vector-based semantic retrieval.

## 4. Key Features

### Customer Module

- Submit new complaints.
- Provide complaint subjects and descriptions.
- View previously submitted complaints.
- Track complaint status.
- View complaint progress updates.

### Support Agent Module

- View assigned complaints.
- Review complaint details.
- Access AI-generated similar complaint suggestions.
- Accept or reject suggested complaint matches.
- Review historical complaint resolutions.
- Update complaint progress.
- Manage complaint resolution workflows.

### AI-Powered Complaint Matching

- Generate semantic embeddings from complaint descriptions.
- Retrieve similar historical complaints using vector similarity.
- Display similarity scores.
- Store matching results for further review.

### Complaint Management

- Manage complaint categories and priorities.
- Maintain complaint status information.
- Assign complaints to support agents.
- Record resolution details.
- Collect feedback on suggested matches.

## 5. Technology Stack

| Component                       | Technology                               |
| ------------------------------- | ---------------------------------------- |
| Frontend                        | Next.js                                  |
| Programming Language – Frontend | TypeScript                               |
| Backend                         | Python                                   |
| Backend Framework               | FastAPI                                  |
| Relational Database             | MySQL                                    |
| Vector Database                 | Qdrant                                   |
| Embedding Model                 | Sentence Transformers – all-MiniLM-L6-v2 |
| Vector Dimension                | 384                                      |
| Similarity Metric               | Cosine Similarity                        |
| API Communication               | REST API                                 |
| Development Environment         | Visual Studio Code / Terminal            |

## 6. System Architecture

ResolveIQ follows a full-stack architecture consisting of a frontend, backend, relational database, and vector database.

### Architecture Components

**1. Frontend – Next.js**

Provides the user interface for customers and support agents. It communicates with the backend through REST API requests.

**2. Backend – FastAPI**

Handles application logic, complaint submission, agent operations, complaint matching, status updates, and database communication.

**3. Relational Database – MySQL**

Stores structured application data, including users, customers, support agents, complaints, assignments, categories, priorities, statuses, matches, feedback, and resolutions.

**4. Vector Database – Qdrant**

Stores complaint embeddings and enables semantic similarity searches against previously submitted complaints.

**5. Embedding Model – all-MiniLM-L6-v2**

Converts complaint descriptions into 384-dimensional numerical vectors that can be compared using cosine similarity.

### Complaint Processing Workflow

```text
Customer
   |
   v
Next.js Frontend
   |
   v
FastAPI Backend
   |
   +----------------------+
   |                      |
   v                      v
MySQL Database       Embedding Model
   |                      |
   |                      v
   |                 Complaint Vector
   |                      |
   |                      v
   |                 Qdrant Database
   |                      |
   |                      v
   |              Similar Complaint Search
   |                      |
   +----------+-----------+
              |
              v
      Matching Suggestions
              |
              v
       Support Agent
              |
              v
      Complaint Resolution
              |
              v
        Customer Tracking
```

## 7. Database Design

ResolveIQ uses a hybrid database approach involving MySQL and Qdrant.

### MySQL Relational Database

The relational database is named `resolveiq_db`.

The database contains tables for structured complaint management and application operations.

| Table                  | Purpose                                       |
| ---------------------- | --------------------------------------------- |
| ROLE                   | Stores application roles                      |
| USER_ACCOUNT           | Stores user account information               |
| CUSTOMER               | Stores customer details                       |
| SUPPORT_DEPARTMENT     | Stores support department information         |
| SUPPORT_AGENT          | Stores support agent details                  |
| PRODUCT                | Stores product information                    |
| COMPLAINT_CATEGORY     | Stores complaint categories                   |
| PRIORITY               | Stores complaint priority levels              |
| COMPLAINT_STATUS       | Stores complaint status values                |
| COMPLAINT              | Stores customer complaint information         |
| COMPLAINT_ASSIGNMENT   | Maintains complaint-to-agent assignments      |
| RESOLUTION             | Stores reusable resolution information        |
| COMPLAINT_RESOLUTION   | Records complaint resolution details          |
| COMPLAINT_MATCH        | Stores similar complaint matching results     |
| COMPLAINT_FEEDBACK     | Stores agent feedback on matching suggestions |
| COMPLAINT_AGENT_UPDATE | Stores complaint progress updates             |

### Database Concepts Implemented

The project demonstrates practical database management concepts, including:

- Primary keys and foreign keys.
- One-to-many and many-to-many relationships where applicable.
- Unique and check constraints.
- Database indexing.
- Views.
- Triggers.
- Stored procedures.
- Stored functions.
- Transactions and data integrity.

### View

`complaint_details` is used to retrieve complaint information along with related details.

### Trigger

`set_resolved_time` automatically records the resolution timestamp when a complaint transitions to the resolved status.

### Stored Procedure

`GetComplaintCountByStatus` retrieves the number of complaints associated with a specified status.

Example:

```sql
CALL GetComplaintCountByStatus('Resolved');
```

### Stored Function

`GetCustomerComplaintCount` returns the total number of complaints submitted by a specified customer.

Example:

```sql
SELECT GetCustomerComplaintCount(1);
```

### Vector Database – Qdrant

Qdrant stores complaint embeddings separately from the structured MySQL records. It supports similarity searches that identify historical complaints with related meanings.

## 8. AI and Semantic Matching

ResolveIQ uses semantic search to identify complaints that describe similar problems even when they contain different words or sentence structures.

### Embedding Generation

The project uses the `all-MiniLM-L6-v2` sentence-transformer model.

Each complaint description is converted into a 384-dimensional vector representation.

### Similarity Search

The generated vectors are stored in Qdrant, where cosine similarity is used to retrieve related complaints.

### Matching Workflow

1. A complaint is submitted by a customer.
2. The backend generates its embedding.
3. The embedding is searched against existing complaint vectors.
4. Similar complaints are retrieved with similarity scores.
5. Matching information is stored in MySQL.
6. Support agents review the suggested matches.

This enables the system to reuse relevant historical complaint information and resolutions.

## 9. Application Modules

The application is divided into the following major modules:

| Module                | Description                                                     |
| --------------------- | --------------------------------------------------------------- |
| Customer Management   | Handles customer complaint submissions and tracking             |
| Agent Management      | Provides agent complaint dashboards and workflows               |
| Complaint Management  | Handles complaint records, categories, priorities, and statuses |
| Assignment Management | Associates complaints with support agents                       |
| Semantic Matching     | Retrieves similar complaints using vector search                |
| Resolution Management | Stores and tracks complaint resolutions                         |
| Feedback Management   | Records feedback on suggested matches                           |
| Progress Tracking     | Maintains complaint progress updates                            |

## 10. API Endpoints

The FastAPI backend exposes REST endpoints for frontend communication.

| Method | Endpoint                              | Description                                  |
| ------ | ------------------------------------- | -------------------------------------------- |
| GET    | `/health`                             | Checks backend health                        |
| POST   | `/complaints`                         | Creates a new complaint                      |
| GET    | `/agents`                             | Retrieves support agents                     |
| GET    | `/agents/{agent_id}/complaints`       | Retrieves complaints assigned to an agent    |
| GET    | `/complaints/{complaint_id}/matches`  | Retrieves similar complaint matches          |
| PATCH  | `/matches/{match_id}/status`          | Updates a suggested match status             |
| GET    | `/customers`                          | Retrieves customers                          |
| GET    | `/customers/{customer_id}/complaints` | Retrieves complaints submitted by a customer |
| GET    | `/complaints/{complaint_id}/updates`  | Retrieves complaint progress updates         |
| POST   | `/complaints/{complaint_id}/updates`  | Adds a complaint progress update             |

### API Documentation

FastAPI provides interactive API documentation through Swagger UI.

After starting the backend, visit:

`http://localhost:8000/docs`

## 11. Project Structure

```text
DBMS-ResolveIQ/
│
├── README.md
├── .gitignore
│
├── backend/
│   ├── api.py
│   ├── end_to_end.py
│   ├── generate_embeddings.py
│   ├── match_and_store.py
│   ├── requirements.txt
│   ├── resolveiq_customer_tracking.sql
│   ├── search_qdrant.py
│   ├── seed_demo_data.py
│   ├── setup_qdrant.py
│   ├── sync_qdrant.py
│   └── test_mysql.py
│
└── frontend/
    ├── app/
    │   ├── favicon.ico
    │   ├── globals.css
    │   ├── layout.tsx
    │   └── page.tsx
    │
    ├── public/
    ├── package.json
    ├── package-lock.json
    ├── next.config.ts
    ├── eslint.config.mjs
    └── tsconfig.json
```

## 12. Installation and Setup

### Prerequisites

Install the following software before running the project:

- Python 3.10 or later.
- Node.js and npm.
- MySQL Server.
- Git.
- A compatible Python environment for the sentence-transformer model.

Qdrant is configured for local use by the backend.

### Clone the Repository

```bash
git clone https://github.com/suravii28/DBMS-ResolveIQ.git

cd DBMS-ResolveIQ
```

### Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

Create a Python virtual environment:

```bash
python3 -m venv venv
```

Activate the virtual environment on macOS/Linux:

```bash
source venv/bin/activate
```

On Windows:

```bash
venv\Scripts\activate
```

Install the required dependencies:

```bash
pip install -r requirements.txt
```

### Environment Configuration

Create a `.env` file inside the `backend` directory.

Add the database and application configuration required by `api.py` and the backend scripts.

For example, database configuration may contain:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=resolveiq_db
```

**Important:** These are example variable names. Check the configuration names used in the backend source code and use those exact names in your `.env` file. Never commit real credentials to GitHub.

### Frontend Setup

Open another Terminal window and navigate to the frontend directory:

```bash
cd frontend
```

Install frontend dependencies:

```bash
npm install
```

## 13. Running the Application

### Step 1: Start MySQL

On macOS with Homebrew:

```bash
brew services start mysql
```

Make sure the `resolveiq_db` database has been created and populated before starting the application.

### Step 2: Start the Backend

In the backend directory:

```bash
cd backend
source venv/bin/activate
```

Start the FastAPI development server:

```bash
python -m uvicorn api:app --reload --port 8000
```

Backend URL:

`http://localhost:8000`

API documentation:

`http://localhost:8000/docs`

### Step 3: Start the Frontend

Open another Terminal window:

```bash
cd frontend
npm run dev
```

Frontend URL:

`http://localhost:3000`

### Step 4: Access ResolveIQ

Open the following URL in your browser:

`http://localhost:3000`

The application provides customer and support agent workflows through the web interface.

## 14. Database Setup

The backend repository includes the SQL file:

`backend/resolveiq_customer_tracking.sql`

The database used by the application is:

`resolveiq_db`

To access MySQL from Terminal:

```bash
mysql -u root -p
```

Select the database:

```sql
USE resolveiq_db;
```

Display the available tables:

```sql
SHOW TABLES;
```

Inspect the complaint details view:

```sql
SELECT * FROM complaint_details;
```

Inspect database triggers:

```sql
SHOW TRIGGERS;
```

Check available views:

```sql
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

The database must be initialized with the required schema and seed data before the application can perform its complete workflows.

## 15. Future Enhancements

Possible future improvements include:

- Implement secure authentication and password verification.
- Add role-based API authorization.
- Introduce more advanced complaint classification.
- Improve semantic matching with domain-specific embedding models.
- Add automated complaint priority prediction.
- Introduce analytics dashboards for complaint trends.
- Add email and notification integration.
- Deploy the application using cloud-hosted database and vector services.
- Add automated testing and continuous integration.

## 16. Team Members

**Project:** ResolveIQ – AI-Powered Customer Complaint Matching and Resolution System

**Project Type:** DBMS Experiential Learning – Level 3

| Team Member | Student ID    |
| ----------- | ------------- |
| Suravi      | PES1UG24AM295 |
| Sriviswaja  | PES1UG24AM288 |

---

*ResolveIQ demonstrates the integration of relational database management, vector databases, semantic search, and full-stack web application development to address a real-world customer support problem.*

-- Fix: complaint_details view hid unassigned complaints
-- Author: Sriviswaja M (PES1UG24AM288)
--
-- Problem: the original view used INNER JOIN on COMPLAINT_ASSIGNMENT and
-- SUPPORT_AGENT, so complaints with no agent assigned were silently dropped
-- (view showed 6 rows while COMPLAINT had 10).
--
-- Fix: LEFT JOIN on the two optional relationships (assignment, agent).
-- Customer, priority and status stay INNER JOIN because those FKs are NOT NULL.

CREATE OR REPLACE VIEW complaint_details AS
SELECT c.complaint_id,
       cu.customer_name,
       c.subject,
       p.priority_name,
       cs.status_name,
       sa.agent_name,
       ca.assignment_status
FROM COMPLAINT c
JOIN CUSTOMER cu                  ON c.customer_id  = cu.customer_id
JOIN PRIORITY p                   ON c.priority_id  = p.priority_id
JOIN COMPLAINT_STATUS cs          ON c.status_id    = cs.status_id
LEFT JOIN COMPLAINT_ASSIGNMENT ca ON c.complaint_id = ca.complaint_id
LEFT JOIN SUPPORT_AGENT sa        ON ca.agent_id    = sa.agent_id;

-- Verify:
-- SELECT COUNT(*) FROM COMPLAINT;          -- 10
-- SELECT COUNT(*) FROM complaint_details;  -- 10 (was 6)

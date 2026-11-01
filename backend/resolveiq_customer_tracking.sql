CREATE TABLE IF NOT EXISTS COMPLAINT_AGENT_UPDATE (
    update_id INT NOT NULL AUTO_INCREMENT,
    complaint_id INT NOT NULL,
    agent_id INT NOT NULL,
    update_type VARCHAR(30) NOT NULL,
    update_message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (update_id),
    KEY idx_agent_update_complaint (complaint_id, created_at),
    KEY idx_agent_update_agent (agent_id),
    CONSTRAINT fk_agent_update_complaint FOREIGN KEY (complaint_id)
        REFERENCES COMPLAINT(complaint_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_agent_update_agent FOREIGN KEY (agent_id)
        REFERENCES SUPPORT_AGENT(agent_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_agent_update_type CHECK (
        update_type IN ('Suggestion', 'Progress Update', 'Resolution')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MySQL dump 10.13  Distrib 9.7.1, for macos26.4 (arm64)
--
-- Host: localhost    Database: resolveiq_db
-- ------------------------------------------------------
-- Server version	9.7.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `COMPLAINT`
--

DROP TABLE IF EXISTS `COMPLAINT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT` (
  `complaint_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `product_id` int DEFAULT NULL,
  `category_id` int NOT NULL,
  `priority_id` int NOT NULL,
  `status_id` int NOT NULL,
  `subject` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`complaint_id`),
  KEY `fk_complaint_product` (`product_id`),
  KEY `idx_complaint_customer` (`customer_id`),
  KEY `idx_complaint_category` (`category_id`),
  KEY `idx_complaint_priority` (`priority_id`),
  KEY `idx_complaint_status` (`status_id`),
  KEY `idx_complaint_created` (`created_at`),
  CONSTRAINT `fk_complaint_category` FOREIGN KEY (`category_id`) REFERENCES `COMPLAINT_CATEGORY` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_complaint_customer` FOREIGN KEY (`customer_id`) REFERENCES `CUSTOMER` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_complaint_priority` FOREIGN KEY (`priority_id`) REFERENCES `PRIORITY` (`priority_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_complaint_product` FOREIGN KEY (`product_id`) REFERENCES `PRODUCT` (`product_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_complaint_status` FOREIGN KEY (`status_id`) REFERENCES `COMPLAINT_STATUS` (`status_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_resolution_date` CHECK (((`resolved_at` is null) or (`resolved_at` >= `created_at`)))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT`
--

LOCK TABLES `COMPLAINT` WRITE;
/*!40000 ALTER TABLE `COMPLAINT` DISABLE KEYS */;
INSERT INTO `COMPLAINT` VALUES (1,1,1,1,3,3,'Mobile app crashes during login','The mobile banking app crashes whenever I try to log in using my registered account.','2026-10-06 18:23:37','2026-10-06 18:31:07'),(2,2,2,2,4,1,'Incorrect credit card charge','I was charged an amount that does not match my recent credit card transaction.','2026-10-06 18:23:37',NULL),(3,3,3,2,3,3,'Payment failed but amount was deducted','The payment gateway showed a failed transaction, but the amount was deducted from my account.','2026-10-06 18:23:37','2026-10-06 18:31:34'),(4,1,4,4,2,1,'Delivery is delayed','My order was supposed to arrive three days ago but the delivery has still not arrived.','2026-10-06 18:23:37',NULL),(5,2,1,5,3,3,'Unable to access account','I am unable to access my account even after resetting my password.','2026-10-06 18:23:37','2026-10-06 18:24:58'),(6,3,2,3,2,3,'Credit card not working','My credit card is being declined even though there is sufficient available balance.','2026-10-06 18:23:37','2026-10-06 18:24:58'),(7,1,3,2,3,1,'Payment unsuccessful but amount deducted','The payment was unsuccessful, but the amount has been deducted from my bank account.','2026-10-06 19:00:32',NULL),(8,1,3,2,3,1,'Payment unsuccessful but amount deducted','The payment was unsuccessful, but the amount has been deducted from my bank account.','2026-10-06 19:16:23',NULL),(9,1,1,1,2,1,'Payment failed','Payment failed, amount deducted','2026-10-07 14:14:24',NULL),(10,1,1,1,2,1,'product damage','i want a refund, been given a damaged product.','2026-10-22 03:23:58',NULL);
/*!40000 ALTER TABLE `COMPLAINT` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `set_resolved_time` BEFORE UPDATE ON `complaint` FOR EACH ROW BEGIN
    IF NEW.status_id = 3
       AND OLD.status_id <> 3
       AND NEW.resolved_at IS NULL THEN
        SET NEW.resolved_at = CURRENT_TIMESTAMP;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `COMPLAINT_AGENT_UPDATE`
--

DROP TABLE IF EXISTS `COMPLAINT_AGENT_UPDATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_AGENT_UPDATE` (
  `update_id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `agent_id` int NOT NULL,
  `update_type` varchar(30) NOT NULL,
  `update_message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`update_id`),
  KEY `idx_agent_update_complaint` (`complaint_id`,`created_at`),
  KEY `idx_agent_update_agent` (`agent_id`),
  CONSTRAINT `fk_agent_update_agent` FOREIGN KEY (`agent_id`) REFERENCES `SUPPORT_AGENT` (`agent_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_agent_update_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `COMPLAINT` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_agent_update_type` CHECK ((`update_type` in (_utf8mb4'Suggestion',_utf8mb4'Progress Update',_utf8mb4'Resolution')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_AGENT_UPDATE`
--

LOCK TABLES `COMPLAINT_AGENT_UPDATE` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_AGENT_UPDATE` DISABLE KEYS */;
/*!40000 ALTER TABLE `COMPLAINT_AGENT_UPDATE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPLAINT_ASSIGNMENT`
--

DROP TABLE IF EXISTS `COMPLAINT_ASSIGNMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_ASSIGNMENT` (
  `assignment_id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `agent_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `unassigned_at` timestamp NULL DEFAULT NULL,
  `assignment_status` varchar(30) DEFAULT 'Active',
  PRIMARY KEY (`assignment_id`),
  KEY `idx_assignment_complaint` (`complaint_id`),
  KEY `idx_assignment_agent` (`agent_id`),
  CONSTRAINT `fk_assignment_agent` FOREIGN KEY (`agent_id`) REFERENCES `SUPPORT_AGENT` (`agent_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_assignment_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `COMPLAINT` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_assignment_status` CHECK ((`assignment_status` in (_utf8mb4'Active',_utf8mb4'Completed',_utf8mb4'Transferred'))),
  CONSTRAINT `chk_unassigned_date` CHECK (((`unassigned_at` is null) or (`unassigned_at` >= `assigned_at`)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_ASSIGNMENT`
--

LOCK TABLES `COMPLAINT_ASSIGNMENT` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_ASSIGNMENT` DISABLE KEYS */;
INSERT INTO `COMPLAINT_ASSIGNMENT` VALUES (1,1,1,'2026-10-06 18:24:03','2026-10-06 18:31:07','Completed'),(2,2,2,'2026-10-06 18:24:03',NULL,'Active'),(3,3,2,'2026-10-06 18:24:03',NULL,'Active'),(4,4,1,'2026-10-06 18:24:03',NULL,'Active'),(5,5,1,'2026-10-06 18:24:03',NULL,'Completed'),(6,6,2,'2026-10-06 18:24:03',NULL,'Completed');
/*!40000 ALTER TABLE `COMPLAINT_ASSIGNMENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPLAINT_CATEGORY`
--

DROP TABLE IF EXISTS `COMPLAINT_CATEGORY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_CATEGORY` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_category_name` (`category_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_CATEGORY`
--

LOCK TABLES `COMPLAINT_CATEGORY` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_CATEGORY` DISABLE KEYS */;
INSERT INTO `COMPLAINT_CATEGORY` VALUES (1,'Technical Issue','Problems related to applications, systems, or technical functionality'),(2,'Billing Issue','Incorrect charges, invoices, or payment-related problems'),(3,'Product Issue','Problems with a product or its functionality'),(4,'Delivery Issue','Problems involving delivery, shipment, or delays'),(5,'Account Issue','Problems related to customer accounts or access');
/*!40000 ALTER TABLE `COMPLAINT_CATEGORY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `complaint_details`
--

DROP TABLE IF EXISTS `complaint_details`;
/*!50001 DROP VIEW IF EXISTS `complaint_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `complaint_details` AS SELECT 
 1 AS `complaint_id`,
 1 AS `customer_name`,
 1 AS `subject`,
 1 AS `priority_name`,
 1 AS `status_name`,
 1 AS `agent_name`,
 1 AS `assignment_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `COMPLAINT_FEEDBACK`
--

DROP TABLE IF EXISTS `COMPLAINT_FEEDBACK`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_FEEDBACK` (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `match_id` int NOT NULL,
  `agent_id` int NOT NULL,
  `rating` int NOT NULL,
  `comments` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `idx_feedback_match` (`match_id`),
  KEY `idx_feedback_agent` (`agent_id`),
  CONSTRAINT `fk_feedback_agent` FOREIGN KEY (`agent_id`) REFERENCES `SUPPORT_AGENT` (`agent_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_feedback_match` FOREIGN KEY (`match_id`) REFERENCES `COMPLAINT_MATCH` (`match_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_feedback_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_FEEDBACK`
--

LOCK TABLES `COMPLAINT_FEEDBACK` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_FEEDBACK` DISABLE KEYS */;
INSERT INTO `COMPLAINT_FEEDBACK` VALUES (1,1,1,4,'The suggested complaint is somewhat relevant and useful.','2026-10-06 18:26:42'),(2,2,2,5,'Very similar complaint and the previous resolution was helpful.','2026-10-06 18:26:42'),(3,3,2,4,'The complaint has similar symptoms and may help with resolution.','2026-10-06 18:26:42'),(4,4,2,5,'Highly relevant historical complaint.','2026-10-06 18:26:42');
/*!40000 ALTER TABLE `COMPLAINT_FEEDBACK` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPLAINT_MATCH`
--

DROP TABLE IF EXISTS `COMPLAINT_MATCH`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_MATCH` (
  `match_id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `matched_complaint_id` int NOT NULL,
  `similarity_score` decimal(5,4) NOT NULL,
  `matched_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `match_status` varchar(30) DEFAULT 'Suggested',
  PRIMARY KEY (`match_id`),
  UNIQUE KEY `uq_complaint_match` (`complaint_id`,`matched_complaint_id`),
  KEY `idx_match_complaint` (`complaint_id`),
  KEY `idx_match_matched` (`matched_complaint_id`),
  KEY `idx_match_score` (`similarity_score`),
  CONSTRAINT `fk_match_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `COMPLAINT` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_match_matched_complaint` FOREIGN KEY (`matched_complaint_id`) REFERENCES `COMPLAINT` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_match_status` CHECK ((`match_status` in (_utf8mb4'Suggested',_utf8mb4'Accepted',_utf8mb4'Rejected'))),
  CONSTRAINT `chk_similarity_score` CHECK (((`similarity_score` >= 0) and (`similarity_score` <= 1)))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_MATCH`
--

LOCK TABLES `COMPLAINT_MATCH` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_MATCH` DISABLE KEYS */;
INSERT INTO `COMPLAINT_MATCH` VALUES (1,1,5,0.7215,'2026-10-06 18:25:14','Suggested'),(2,2,3,0.8842,'2026-10-06 18:25:14','Accepted'),(3,2,6,0.7931,'2026-10-06 18:25:14','Suggested'),(4,3,2,0.8842,'2026-10-06 18:25:14','Accepted'),(5,7,3,0.8930,'2026-10-06 19:00:36','Suggested'),(6,7,2,0.5070,'2026-10-06 19:00:36','Suggested'),(7,8,3,0.8930,'2026-10-06 19:16:23','Suggested'),(8,8,2,0.5070,'2026-10-06 19:16:23','Suggested'),(9,9,8,0.8666,'2026-10-07 14:14:24','Suggested'),(10,9,3,0.8544,'2026-10-07 14:14:24','Suggested');
/*!40000 ALTER TABLE `COMPLAINT_MATCH` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPLAINT_RESOLUTION`
--

DROP TABLE IF EXISTS `COMPLAINT_RESOLUTION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_RESOLUTION` (
  `complaint_resolution_id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `resolution_id` int NOT NULL,
  `agent_id` int NOT NULL,
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `outcome` varchar(50) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`complaint_resolution_id`),
  KEY `fk_cr_resolution` (`resolution_id`),
  KEY `idx_resolution_complaint` (`complaint_id`),
  KEY `idx_resolution_agent` (`agent_id`),
  CONSTRAINT `fk_cr_agent` FOREIGN KEY (`agent_id`) REFERENCES `SUPPORT_AGENT` (`agent_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cr_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `COMPLAINT` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cr_resolution` FOREIGN KEY (`resolution_id`) REFERENCES `RESOLUTION` (`resolution_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_resolution_outcome` CHECK (((`outcome` is null) or (`outcome` in (_utf8mb4'Successful',_utf8mb4'Partially Successful',_utf8mb4'Unsuccessful'))))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_RESOLUTION`
--

LOCK TABLES `COMPLAINT_RESOLUTION` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_RESOLUTION` DISABLE KEYS */;
INSERT INTO `COMPLAINT_RESOLUTION` VALUES (1,5,1,1,'2026-10-06 18:24:50','Successful','Customer was able to access the account after credentials were reset.'),(2,6,2,2,'2026-10-06 18:24:50','Successful','Replacement card process was initiated after verifying the customer account.');
/*!40000 ALTER TABLE `COMPLAINT_RESOLUTION` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPLAINT_STATUS`
--

DROP TABLE IF EXISTS `COMPLAINT_STATUS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COMPLAINT_STATUS` (
  `status_id` int NOT NULL AUTO_INCREMENT,
  `status_name` varchar(50) NOT NULL,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `uq_status_name` (`status_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPLAINT_STATUS`
--

LOCK TABLES `COMPLAINT_STATUS` WRITE;
/*!40000 ALTER TABLE `COMPLAINT_STATUS` DISABLE KEYS */;
INSERT INTO `COMPLAINT_STATUS` VALUES (4,'Closed'),(2,'In Progress'),(1,'Open'),(5,'Rejected'),(3,'Resolved');
/*!40000 ALTER TABLE `COMPLAINT_STATUS` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CUSTOMER`
--

DROP TABLE IF EXISTS `CUSTOMER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CUSTOMER` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `registration_date` date DEFAULT (curdate()),
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `uq_customer_user` (`user_id`),
  CONSTRAINT `fk_customer_user` FOREIGN KEY (`user_id`) REFERENCES `USER_ACCOUNT` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CUSTOMER`
--

LOCK TABLES `CUSTOMER` WRITE;
/*!40000 ALTER TABLE `CUSTOMER` DISABLE KEYS */;
INSERT INTO `CUSTOMER` VALUES (1,1,'Rahul Sharma','9876543210','2026-10-06'),(2,2,'Priya Nair','9876543211','2026-10-06'),(3,3,'Arjun Mehta','9876543212','2026-10-06');
/*!40000 ALTER TABLE `CUSTOMER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PRIORITY`
--

DROP TABLE IF EXISTS `PRIORITY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PRIORITY` (
  `priority_id` int NOT NULL AUTO_INCREMENT,
  `priority_name` varchar(30) NOT NULL,
  `severity_level` int NOT NULL,
  PRIMARY KEY (`priority_id`),
  UNIQUE KEY `uq_priority_name` (`priority_name`),
  UNIQUE KEY `uq_severity_level` (`severity_level`),
  CONSTRAINT `chk_severity_level` CHECK ((`severity_level` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PRIORITY`
--

LOCK TABLES `PRIORITY` WRITE;
/*!40000 ALTER TABLE `PRIORITY` DISABLE KEYS */;
INSERT INTO `PRIORITY` VALUES (1,'Low',1),(2,'Medium',2),(3,'High',3),(4,'Critical',5);
/*!40000 ALTER TABLE `PRIORITY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PRODUCT`
--

DROP TABLE IF EXISTS `PRODUCT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PRODUCT` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `product_name` varchar(150) NOT NULL,
  `product_type` varchar(100) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uq_product_name` (`product_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PRODUCT`
--

LOCK TABLES `PRODUCT` WRITE;
/*!40000 ALTER TABLE `PRODUCT` DISABLE KEYS */;
INSERT INTO `PRODUCT` VALUES (1,'Mobile Banking App','Software','Mobile application for banking and account services'),(2,'Credit Card','Financial Product','Credit card and related payment services'),(3,'Online Payment Gateway','Payment Service','Online payment processing service'),(4,'Home Delivery Service','Logistics','Product delivery and shipment service');
/*!40000 ALTER TABLE `PRODUCT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RESOLUTION`
--

DROP TABLE IF EXISTS `RESOLUTION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RESOLUTION` (
  `resolution_id` int NOT NULL AUTO_INCREMENT,
  `resolution_title` varchar(200) NOT NULL,
  `resolution_description` text NOT NULL,
  `resolution_type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`resolution_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RESOLUTION`
--

LOCK TABLES `RESOLUTION` WRITE;
/*!40000 ALTER TABLE `RESOLUTION` DISABLE KEYS */;
INSERT INTO `RESOLUTION` VALUES (1,'Account Access Reset','Customer account credentials were reset and access was restored successfully.','Account Support'),(2,'Credit Card Replacement','A replacement credit card was issued after verifying the customer account.','Card Support'),(3,'Payment Reversal','The failed payment was investigated and the deducted amount was reversed to the customer.','Payment Support'),(4,'Technical Troubleshooting','Application configuration and login issues were diagnosed and resolved.','Technical Support');
/*!40000 ALTER TABLE `RESOLUTION` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ROLE`
--

DROP TABLE IF EXISTS `ROLE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ROLE` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ROLE`
--

LOCK TABLES `ROLE` WRITE;
/*!40000 ALTER TABLE `ROLE` DISABLE KEYS */;
INSERT INTO `ROLE` VALUES (3,'Admin'),(1,'Customer'),(2,'Support Agent');
/*!40000 ALTER TABLE `ROLE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SUPPORT_AGENT`
--

DROP TABLE IF EXISTS `SUPPORT_AGENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SUPPORT_AGENT` (
  `agent_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `department_id` int NOT NULL,
  `agent_name` varchar(100) NOT NULL,
  `hire_date` date DEFAULT NULL,
  PRIMARY KEY (`agent_id`),
  UNIQUE KEY `uq_agent_user` (`user_id`),
  KEY `fk_agent_department` (`department_id`),
  CONSTRAINT `fk_agent_department` FOREIGN KEY (`department_id`) REFERENCES `SUPPORT_DEPARTMENT` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_agent_user` FOREIGN KEY (`user_id`) REFERENCES `USER_ACCOUNT` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SUPPORT_AGENT`
--

LOCK TABLES `SUPPORT_AGENT` WRITE;
/*!40000 ALTER TABLE `SUPPORT_AGENT` DISABLE KEYS */;
INSERT INTO `SUPPORT_AGENT` VALUES (1,4,1,'Ananya Rao','2025-06-15'),(2,5,2,'Rohan Kapoor','2025-07-01');
/*!40000 ALTER TABLE `SUPPORT_AGENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SUPPORT_DEPARTMENT`
--

DROP TABLE IF EXISTS `SUPPORT_DEPARTMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SUPPORT_DEPARTMENT` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `department_name` varchar(100) NOT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `uq_department_name` (`department_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SUPPORT_DEPARTMENT`
--

LOCK TABLES `SUPPORT_DEPARTMENT` WRITE;
/*!40000 ALTER TABLE `SUPPORT_DEPARTMENT` DISABLE KEYS */;
INSERT INTO `SUPPORT_DEPARTMENT` VALUES (2,'Billing'),(4,'Delivery & Logistics'),(3,'Product Support'),(1,'Technical Support');
/*!40000 ALTER TABLE `SUPPORT_DEPARTMENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `USER_ACCOUNT`
--

DROP TABLE IF EXISTS `USER_ACCOUNT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `USER_ACCOUNT` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(150) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `account_status` varchar(20) DEFAULT 'Active',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_username` (`username`),
  UNIQUE KEY `uq_user_email` (`email`),
  KEY `fk_user_role` (`role_id`),
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `ROLE` (`role_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_account_status` CHECK ((`account_status` in (_utf8mb4'Active',_utf8mb4'Inactive',_utf8mb4'Suspended')))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `USER_ACCOUNT`
--

LOCK TABLES `USER_ACCOUNT` WRITE;
/*!40000 ALTER TABLE `USER_ACCOUNT` DISABLE KEYS */;
INSERT INTO `USER_ACCOUNT` VALUES (1,1,'rahul_customer','hash_customer_1','rahul@example.com','2026-10-06 18:21:45','Active'),(2,1,'priya_customer','hash_customer_2','priya@example.com','2026-10-06 18:21:45','Active'),(3,1,'arjun_customer','hash_customer_3','arjun@example.com','2026-10-06 18:21:45','Active'),(4,2,'ananya_agent','hash_agent_1','ananya@resolveiq.com','2026-10-06 18:21:45','Active'),(5,2,'rohan_agent','hash_agent_2','rohan@resolveiq.com','2026-10-06 18:21:45','Active'),(6,3,'admin_user','hash_admin_1','admin@resolveiq.com','2026-10-06 18:21:45','Active');
/*!40000 ALTER TABLE `USER_ACCOUNT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'resolveiq_db'
--

--
-- Final view structure for view `complaint_details`
--

/*!50001 DROP VIEW IF EXISTS `complaint_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `complaint_details` AS select `c`.`complaint_id` AS `complaint_id`,`cu`.`customer_name` AS `customer_name`,`c`.`subject` AS `subject`,`p`.`priority_name` AS `priority_name`,`cs`.`status_name` AS `status_name`,`sa`.`agent_name` AS `agent_name`,`ca`.`assignment_status` AS `assignment_status` from (((((`complaint` `c` join `customer` `cu` on((`c`.`customer_id` = `cu`.`customer_id`))) join `priority` `p` on((`c`.`priority_id` = `p`.`priority_id`))) join `complaint_status` `cs` on((`c`.`status_id` = `cs`.`status_id`))) left join `complaint_assignment` `ca` on((`c`.`complaint_id` = `ca`.`complaint_id`))) left join `support_agent` `sa` on((`ca`.`agent_id` = `sa`.`agent_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-01 21:35:01

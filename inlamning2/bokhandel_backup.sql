-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: bokhandel
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Table structure for table `beställningar`
--

DROP TABLE IF EXISTS `beställningar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beställningar` (
  `Ordernummer` int NOT NULL AUTO_INCREMENT,
  `Epost` varchar(100) DEFAULT NULL,
  `Datum` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Totalbelopp` int NOT NULL,
  PRIMARY KEY (`Ordernummer`),
  KEY `Epost` (`Epost`),
  CONSTRAINT `beställningar_ibfk_1` FOREIGN KEY (`Epost`) REFERENCES `kunder` (`Epost`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `beställningar`
--

LOCK TABLES `beställningar` WRITE;
/*!40000 ALTER TABLE `beställningar` DISABLE KEYS */;
INSERT INTO `beställningar` VALUES (1,'intebengtlängre@email.com','2025-04-03 12:24:09',2293),(3,'eriksfetamejl@email.com','2025-04-03 12:24:09',1568);
/*!40000 ALTER TABLE `beställningar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `böcker`
--

DROP TABLE IF EXISTS `böcker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `böcker` (
  `ISBN` int NOT NULL AUTO_INCREMENT,
  `Titel` varchar(100) NOT NULL,
  `Författare` varchar(100) NOT NULL,
  `Pris` int NOT NULL,
  `Lagerstatus` varchar(100) NOT NULL DEFAULT 'Finns i lager',
  `Lagersaldo` int NOT NULL,
  PRIMARY KEY (`ISBN`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `böcker`
--

LOCK TABLES `böcker` WRITE;
/*!40000 ALTER TABLE `böcker` DISABLE KEYS */;
INSERT INTO `böcker` VALUES (1,'Kaosmakarna','Giuliano Da Empoli',478,'Finns ej i lager',0),(2,'Mangia: Pasta och annat gott','Oliver Ingrosso',127,'Finns i lager',2),(3,'Killer Queen','Denise Rudberg',252,'Finns i lager',3),(4,'Historian om SQL Kevve','Kevin Kosner',784,'Finns ej i lager',0);
/*!40000 ALTER TABLE `böcker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kunder`
--

DROP TABLE IF EXISTS `kunder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kunder` (
  `Epost` varchar(100) NOT NULL,
  `Namn` varchar(100) NOT NULL,
  `Telefon` varchar(100) NOT NULL,
  `Adress` varchar(100) NOT NULL,
  PRIMARY KEY (`Epost`),
  UNIQUE KEY `Epost` (`Epost`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kunder`
--

LOCK TABLES `kunder` WRITE;
/*!40000 ALTER TABLE `kunder` DISABLE KEYS */;
INSERT INTO `kunder` VALUES ('coolviolagaming@email.com','Viola Milan','076-925 12 85','Kraftvägen 6'),('eriksfetamejl@email.com','Erik Johansson','070-293 37 95','Hemlös'),('intebengtlängre@email.com','Bengt Svensson','072-662 39 75','Flugsvampsgatan 12C');
/*!40000 ALTER TABLE `kunder` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `LoggaNyKund` AFTER INSERT ON `kunder` FOR EACH ROW BEGIN
    INSERT INTO Kundlogg (Händelse, Epost, KundNamn)
    VALUES (CONCAT('Ny kund registrerad med Epost: ', NEW.Epost), NEW.Epost, NEW.Namn);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `kundlogg`
--

DROP TABLE IF EXISTS `kundlogg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kundlogg` (
  `LoggID` int NOT NULL AUTO_INCREMENT,
  `Händelse` varchar(100) NOT NULL,
  `Epost` varchar(100) NOT NULL,
  `KundNamn` varchar(100) NOT NULL,
  `Tidpunkt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`LoggID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kundlogg`
--

LOCK TABLES `kundlogg` WRITE;
/*!40000 ALTER TABLE `kundlogg` DISABLE KEYS */;
INSERT INTO `kundlogg` VALUES (1,'Ny kund registrerad med Epost: bengt.kingkong@email.com','bengt.kingkong@email.com','Bengt Svensson','2025-04-03 12:24:09'),(2,'Ny kund registrerad med Epost: mannendetegiovanni@email.com','mannendetegiovanni@email.com','Giovanni Karlsson','2025-04-03 12:24:09'),(3,'Ny kund registrerad med Epost: coolviolagaming@email.com','coolviolagaming@email.com','Viola Milan','2025-04-03 12:24:09'),(4,'Ny kund registrerad med Epost: eriksfetamejl@email.com','eriksfetamejl@email.com','Erik Johansson','2025-04-03 12:24:09'),(5,'Kund uppdaterade Epost från: \"bengt.kingkong@email.com\" till \"intebengtlängre@email.com\"','intebengtlängre@email.com','Bengt Svensson','2025-04-03 12:24:09'),(6,'mannendetegiovanni@email.com avregistrerades som kund','mannendetegiovanni@email.com','Giovanni Karlsson','2025-04-03 12:24:09');
/*!40000 ALTER TABLE `kundlogg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderrader`
--

DROP TABLE IF EXISTS `orderrader`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderrader` (
  `OrderradID` int NOT NULL AUTO_INCREMENT,
  `Ordernummer` int NOT NULL,
  `ISBN` int NOT NULL,
  `Antal` int NOT NULL,
  `Titel` varchar(100) NOT NULL,
  PRIMARY KEY (`OrderradID`),
  KEY `Ordernummer` (`Ordernummer`),
  KEY `ISBN` (`ISBN`),
  CONSTRAINT `orderrader_ibfk_1` FOREIGN KEY (`Ordernummer`) REFERENCES `beställningar` (`Ordernummer`),
  CONSTRAINT `orderrader_ibfk_2` FOREIGN KEY (`ISBN`) REFERENCES `böcker` (`ISBN`),
  CONSTRAINT `orderrader_chk_1` CHECK ((`Antal` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderrader`
--

LOCK TABLES `orderrader` WRITE;
/*!40000 ALTER TABLE `orderrader` DISABLE KEYS */;
INSERT INTO `orderrader` VALUES (1,1,1,4,'Kaosmakarna'),(2,1,2,3,'Mangia: Pasta och annat gott'),(4,3,4,2,'Historian om SQL Kevve');
/*!40000 ALTER TABLE `orderrader` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `UppdateraLagerPåBeställning` AFTER INSERT ON `orderrader` FOR EACH ROW BEGIN
    UPDATE Böcker
    SET Lagersaldo = Lagersaldo - NEW.Antal
    WHERE ISBN = NEW.ISBN;
    -- Uppdaterar lagerstatusen beroende på lagersaldot
    SET @lagersaldo = (SELECT Lagersaldo FROM Böcker WHERE ISBN = NEW.ISBN);
    IF @lagersaldo = 0 THEN 
		UPDATE Böcker SET Lagerstatus = "Finns ej i lager" WHERE ISBN = NEW.ISBN;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-03 14:24:49

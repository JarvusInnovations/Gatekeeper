/*!40103 SET TIME_ZONE='+00:00' */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE `endpoints` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Class` enum('Gatekeeper\\Endpoints\\Endpoint') NOT NULL,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CreatorID` int(11) DEFAULT NULL,
  `Title` varchar(255) NOT NULL,
  `Handle` varchar(255) NOT NULL,
  `Path` varchar(255) NOT NULL,
  `InternalEndpoint` varchar(255) NOT NULL,
  `AdminName` varchar(255) DEFAULT NULL,
  `AdminEmail` varchar(255) DEFAULT NULL,
  `Public` tinyint(1) NOT NULL DEFAULT '0',
  `Description` text,
  `DeprecationDate` timestamp NULL DEFAULT NULL,
  `GlobalRateCount` int(10) unsigned DEFAULT NULL,
  `GlobalRatePeriod` int(10) unsigned DEFAULT NULL,
  `UserRateCount` int(10) unsigned DEFAULT NULL,
  `UserRatePeriod` int(10) unsigned DEFAULT NULL,
  `GlobalBandwidthCount` int(10) unsigned DEFAULT NULL,
  `GlobalBandwidthPeriod` int(10) unsigned DEFAULT NULL,
  `KeyRequired` tinyint(1) NOT NULL DEFAULT '0',
  `KeySelfRegistration` tinyint(1) NOT NULL DEFAULT '0',
  `CachingEnabled` tinyint(1) NOT NULL DEFAULT '1',
  `AlertOnError` tinyint(1) NOT NULL DEFAULT '1',
  `AlertNearMaxRequests` decimal(3,2) DEFAULT NULL,
  `PingFrequency` int(10) unsigned DEFAULT NULL,
  `PingURI` varchar(255) DEFAULT NULL,
  `PingTestPattern` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Handle` (`Handle`),
  UNIQUE KEY `Path` (`Path`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `endpoints` VALUES (1,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'TODOs v1','todos-v1','todos/v1','https://jsonplaceholder.typicode.com/todos',NULL,NULL,1,NULL,NULL,10,60,1,1,NULL,NULL,0,0,1,0,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (2,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Cacheable','test-cacheable','test/cacheable','http://localhost/test-api/cachable',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (3,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Cookies','test-cookies','test/cookies','http://localhost/test-api/cookies',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (4,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Slow','test-slow','test/slow','http://localhost/test-api/slow',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (5,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Status','test-status','test/status','http://localhost/test-api/status',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (6,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Client IP','test-client','test/client','http://localhost/test-api/client',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);
INSERT INTO `endpoints` VALUES (7,'Gatekeeper\\Endpoints\\Endpoint','2019-01-02 03:04:05',1,'Test: Headers','test-headers','test/headers','http://localhost/test-api/headers',NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,1,1,NULL,NULL,NULL,NULL);

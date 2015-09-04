--
-- Table structure for table `analysis_log`
--

CREATE TABLE IF NOT EXISTS `analysis_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `species` char(255) DEFAULT NULL,
  `algorithm` char(255) DEFAULT NULL,
  `environment` char(255) DEFAULT NULL,
  `runtime` int(11) DEFAULT NULL,
  `level` char(255) DEFAULT NULL,
  `message` text,
  `datetime` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `species` (`species`,`algorithm`,`environment`,`runtime`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `analysis_progress`
--

CREATE TABLE IF NOT EXISTS `analysis_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `species` char(255) DEFAULT NULL,
  `algorithm` char(255) DEFAULT NULL,
  `environment` char(255) DEFAULT NULL,
  `runtime` int(11) DEFAULT NULL,
  `mark` int(11) DEFAULT NULL,
  `elapsed_time` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `species` (`species`,`algorithm`,`environment`,`runtime`,`mark`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13401 ;

-- --------------------------------------------------------

--
-- Table structure for table `analysis_result`
--

CREATE TABLE IF NOT EXISTS `analysis_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `species` char(255) DEFAULT NULL,
  `algorithm` char(255) DEFAULT NULL,
  `environment` char(255) DEFAULT NULL,
  `threshold_method` char(255) DEFAULT NULL,
  `threshold_value` float DEFAULT NULL,
  `runtime` int(11) DEFAULT NULL,
  `acc` float DEFAULT NULL,
  `err` float DEFAULT NULL,
  `fpr` float DEFAULT NULL,
  `fall` float DEFAULT NULL,
  `tpr` float DEFAULT NULL,
  `rec` float DEFAULT NULL,
  `sens` float DEFAULT NULL,
  `fnr` float DEFAULT NULL,
  `miss` float DEFAULT NULL,
  `tnr` float DEFAULT NULL,
  `spec` float DEFAULT NULL,
  `npv` float DEFAULT NULL,
  `pcmiss` float DEFAULT NULL,
  `rpp` float DEFAULT NULL,
  `rnp` float DEFAULT NULL,
  `rch` float DEFAULT NULL,
  `sar` float DEFAULT NULL,
  `auc` float DEFAULT NULL,
  `rmse` float DEFAULT NULL,
  `kappa` float DEFAULT NULL,
  `tss` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `species` (`species`,`algorithm`,`environment`,`threshold_method`,`runtime`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=120601 ;

--
-- Table structure for table `threshold`
--

CREATE TABLE IF NOT EXISTS `threshold` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `species` char(255) NOT NULL,
  `algorithm` char(255) NOT NULL,
  `threshold_method` char(255) NOT NULL,
  `standard` char(255) NOT NULL,
  `relative_id` int(11) NOT NULL,
  `runtime` int(11) NOT NULL,
  `threshold_value` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `species` (`species`),
  KEY `algorithm` (`algorithm`),
  KEY `threshold_method` (`threshold_method`),
  KEY `standard` (`standard`),
  KEY `relative_id` (`relative_id`),
  KEY `runtime` (`runtime`),
  KEY `threshold_value` (`threshold_value`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=135 ;

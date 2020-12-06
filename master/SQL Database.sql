-- Master

-- mydb.code definition

CREATE TABLE `code` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE DEFINER=`root`@`%` TRIGGER OnTransaccionSync
AFTER INSERT
ON code FOR EACH ROW
BEGIN 
	SET @record = CONCAT(new.id, ',',new.code);
	IF new.code > 400 and new.code < 600 THEN 
		INSERT INTO mydb.SyncTable (`data`, table_name)
		VALUES (@record, "code");
	END IF;
END;

-- mydb.SyncTable definition

CREATE TABLE `SyncTable` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `data` varchar(100) NOT NULL,
  `table_name` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE DEFINER=`root`@`%` TRIGGER OnSyncCreateRecord
AFTER INSERT
ON SyncTable FOR EACH ROW
BEGIN 
	SET @indexColumn = REPLACE( -- remove the delimiters after doing the following:
	  SUBSTRING( -- pick the string
	    SUBSTRING_INDEX(new.data, ',', 0 + 1), -- from the string up to index+1 counts of the delimiter
	    LENGTH(
	      SUBSTRING_INDEX(new.data, ',', 0) -- keeping only everything after index counts of the delimiter
	    ) + 1
	  ),
	  ',',
	  ''
	);

	SET @codeColumn = REPLACE( -- remove the delimiters after doing the following:
	  SUBSTRING( -- pick the string
	    SUBSTRING_INDEX(new.data, ',', 1 + 1), -- from the string up to index+1 counts of the delimiter
	    LENGTH(
	      SUBSTRING_INDEX(new.data, ',', 1) -- keeping only everything after index counts of the delimiter
	    ) + 1
	  ),
	  ',',
	  ''
	);

	INSERT INTO mydb.code (ID, code)
	SELECT * FROM (SELECT @indexColumn, @codeColumn) AS tmp
	WHERE NOT EXISTS (
	    SELECT ID FROM mydb.code WHERE id=@indexColumn
	);
END
CREATE TABLE IF NOT EXISTS Tebex_Data 
(
	id INTEGER(11) AUTO_INCREMENT PRIMARY KEY,
	identifier VARCHAR(50),
	playerName VARCHAR(50),
	dateReceiveNext INTEGER(64),
	acceptedPerkID INTEGER(11),
	rankPackage VARCHAR(50)
);
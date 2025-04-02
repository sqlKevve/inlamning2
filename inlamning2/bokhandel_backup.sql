-- Kevin Kosner YH24

CREATE DATABASE Bokhandel;
USE Bokhandel;

-- Skapar alla tabeller, varav Böcker, Kunder, Beställningar och Orderrader skapas

CREATE TABLE Böcker (
	ISBN INT AUTO_INCREMENT PRIMARY KEY,			-- Denna blir PK då ISBN alltid är ett unikt nummer av internationell standard
	Titel VARCHAR(100) NOT NULL,
    Författare VARCHAR(100) NOT NULL,		
    Pris INT NOT NULL,
    Lagerstatus VARCHAR(100) NOT NULL DEFAULT "Finns i lager",
    Lagersaldo INT NOT NULL
);

CREATE TABLE Kunder (
	Epost VARCHAR(100) UNIQUE PRIMARY KEY,			-- Eftersom eposten måste vara unik så fungerar det perfekt som identifierare i en sån här liten databas
	Namn VARCHAR(100) NOT NULL,				
    Telefon VARCHAR(100) NOT NULL,
    Adress VARCHAR(100) NOT NULL
);

CREATE TABLE Kundlogg (
	LoggID INT AUTO_INCREMENT PRIMARY KEY,
    Händelse VARCHAR(100) NOT NULL,
    Epost VARCHAR(100) NOT NULL,
    KundNamn VARCHAR(100) NOT NULL,
    Tidpunkt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Beställningar (
    Ordernummer INT AUTO_INCREMENT PRIMARY KEY,		-- Väljer att göra ordernummer till PK då den alltid är unik
    Epost VARCHAR(100), 							-- Den här är inte NOT NULL eftersom det krävs att referensen ska brytas om en kund ska ändra epost
    Datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Totalbelopp INT NOT NULL,
    FOREIGN KEY (Epost) REFERENCES Kunder(Epost)	-- Ansluter en länk till kunden i beställningen via en FK
);

CREATE TABLE Orderrader (
	OrderradID INT AUTO_INCREMENT PRIMARY KEY,		-- Skapar en orderradID och gör den till PK för att kunna identifiera orderraderna
	Ordernummer INT NOT NULL,
    ISBN INT NOT NULL,
    FOREIGN KEY (Ordernummer) REFERENCES Beställningar(Ordernummer),	-- Länk till Beställningar tabellen
    FOREIGN KEY (ISBN) REFERENCES Böcker(ISBN),							-- Och här ansluts ännu en länk fast till Böcker tabellen
	Antal INT NOT NULL CHECK (Antal > 0),			-- Kikar hur många böcker det är som ska listas
    Titel VARCHAR(100) NOT NULL
);

-- Funktion som ändrar en kunds epost
DELIMITER $$
CREATE PROCEDURE UppdateraKundEpost (
	IN in_GamlaEpost VARCHAR(100),
	IN in_NyaEpost VARCHAR(100)
)
BEGIN
	DECLARE v_KundNamn VARCHAR(100);
    
	SELECT Namn INTO v_KundNamn FROM Kunder WHERE Epost = in_GamlaEpost;
    
	START TRANSACTION;

    -- Temporärt frigör referensen (detta eftersom det inte går att ändra parent eller child när de är länkade)
    UPDATE Beställningar SET Epost = NULL WHERE Epost = in_GamlaEpost;

    UPDATE Kunder SET Epost = in_NyaEpost WHERE Epost = in_GamlaEpost;

    -- Sätter tillbaka referensen
    UPDATE Beställningar SET Epost = in_NyaEpost WHERE Epost IS NULL;
    
    -- Loggar i Kundloggen att kunden har uppdaterat sin Epost
	INSERT INTO Kundlogg (Händelse, Epost, KundNamn)
    VALUES (CONCAT('Kund uppdaterade Epost från: "', in_GamlaEpost, '" till "', in_NyaEpost, '"'), in_NyaEpost, v_KundNamn);

	COMMIT;
END$$
DELIMITER ;

-- Funktion som tar bort en specifik kund
DELIMITER $$
CREATE PROCEDURE TaBortKund (
	IN in_Epost VARCHAR(100)
)
BEGIN
	DECLARE v_Ordernummer INT;
    DECLARE v_KundNamn VARCHAR(100);
    
    -- Hämtar ordernummer och kundnamn för loggning och rensning i orderrader
    SELECT Ordernummer INTO v_Ordernummer FROM Beställningar WHERE Epost = in_Epost;
    SELECT Namn INTO v_KundNamn FROM Kunder WHERE Epost = in_Epost;
    
	START TRANSACTION;
    DELETE FROM Orderrader WHERE Ordernummer = v_Ordernummer;
    DELETE FROM Beställningar WHERE Epost = in_Epost;
    DELETE FROM Kunder WHERE Epost = in_Epost;
    
    -- Loggar i Kundlogg att kunden tas bort
    INSERT INTO Kundlogg (Händelse, Epost, KundNamn)
    VALUES (CONCAT(in_Epost, ' avregistrerades som kund'), in_Epost, v_KundNamn);
    COMMIT;
END$$
DELIMITER ;

-- Funktion som loggar ny kund
DELIMITER $$
CREATE TRIGGER LoggaNyKund
AFTER INSERT ON Kunder
FOR EACH ROW
BEGIN
    INSERT INTO Kundlogg (Händelse, Epost, KundNamn)
    VALUES (CONCAT('Ny kund registrerad med Epost: ', NEW.Epost), NEW.Epost, NEW.Namn);
END$$
DELIMITER ;


-- Funktion som förenklar och automatiserar en beställning genom att bara knappa in epost, ISBN och mängd böcker som önskas beställas 
DELIMITER $$
CREATE PROCEDURE Beställ (
    IN in_Epost VARCHAR(100), 
    IN in_ISBN INT, 
    IN in_Kvantitet INT,
    IN in_Ordernummer INT
)
BEGIN
    DECLARE v_pris INT;
    DECLARE v_totalPris INT;
    DECLARE v_titel VARCHAR(100);
    DECLARE v_nuvarandeTotalbelopp INT;
    
    -- Hämta pris på bok/böckerna
    SELECT Pris INTO v_pris FROM Böcker WHERE ISBN = in_ISBN;
    SET v_totalPris = v_pris * in_Kvantitet;
    
    -- Hämta titel på bok/böckerna
    SELECT Titel INTO v_titel FROM Böcker WHERE ISBN = in_ISBN;
    
    START TRANSACTION;
    
    -- Lägger till i Beställningar om det är en ny beställning
	IF in_Ordernummer IS NULL THEN
		INSERT INTO Beställningar (Epost, Totalbelopp) 
		VALUES (in_Epost, v_totalPris);
	-- Uppdaterar totalbeloppet på beställningen om det läggs till i en beställning
	ELSEIF in_Ordernummer IS NOT NULL THEN
		SELECT Totalbelopp INTO v_nuvarandeTotalbelopp FROM Beställningar WHERE Ordernummer = in_Ordernummer;
		UPDATE Beställningar SET Totalbelopp = v_nuvarandeTotalbelopp + v_totalPris WHERE Ordernummer = in_Ordernummer;
    END IF;
    
    -- Lägger till i Orderrader med det nya ordernummret om ett ordernummer ej angavs
    IF in_Ordernummer IS NULL THEN
		INSERT INTO Orderrader (Ordernummer, ISBN, Antal, Titel) 
		VALUES (LAST_INSERT_ID(), in_ISBN, in_Kvantitet, v_titel);
	-- Lägger till i Orderrader ifall en beställning ska läggas in i samma ordernummer, alltså fler böcker i en beställning
	ELSEIF in_Ordernummer IS NOT NULL THEN
		INSERT INTO Orderrader (Ordernummer, ISBN, Antal, Titel)
        VALUES (in_Ordernummer, in_ISBN, in_Kvantitet, v_titel);
    END IF;
    
    COMMIT;
END$$
DELIMITER ;

-- Funktion som förenklar att lägga till fler böcker i lagersaldo som redan finns i databasen (lade till eftersom det känns som en relevant funktion)
DELIMITER $$
CREATE PROCEDURE LäggTillLagersaldo (
	IN in_ISBN INT,
    IN in_Kvantitet INT
)
BEGIN
	UPDATE Böcker
    SET Lagersaldo = Lagersaldo + in_Kvantitet
    WHERE ISBN = in_ISBN;
    SET @lagersaldo = (SELECT Lagersaldo FROM Böcker WHERE ISBN = in_ISBN);
    IF @lagersaldo > 0 THEN 
		UPDATE Böcker SET Lagerstatus = "Finns i lager" WHERE ISBN = in_ISBN;
	END IF;
END $$
DELIMITER ;

-- Funktion som visar alla beställningar (via NULL) eller alla beställningar för en specifik kund (via epost)
DELIMITER $$
CREATE PROCEDURE VisaBeställningar (
	IN in_Epost VARCHAR(100)
)
BEGIN
	-- Gör en inner join funktion här för att visa all relevant data
    SELECT
        Beställningar.Ordernummer,
        Kunder.Epost,
        Beställningar.Datum,
        Böcker.ISBN,
        Böcker.Titel,
        Böcker.Författare,
        Böcker.Pris,
        Orderrader.Antal,
        Beställningar.Totalbelopp,
        Kunder.Adress AS Leveransadress
    FROM Orderrader
    INNER JOIN Beställningar ON Orderrader.Ordernummer = Beställningar.Ordernummer
    INNER JOIN Kunder ON Beställningar.Epost = Kunder.Epost
    INNER JOIN Böcker ON Orderrader.ISBN = Böcker.ISBN
    WHERE (in_Epost IS NULL OR Kunder.Epost = in_Epost); -- kikar om eposten är null eller har en epost
END$$
DELIMITER ;

-- Funktion som visar alla böcker och sorteras efter pris
DELIMITER $$
CREATE PROCEDURE VisaBöcker (
)
BEGIN
    SELECT Titel, Författare, Pris, Lagerstatus, Lagersaldo FROM Böcker ORDER BY Pris ASC;
END$$
DELIMITER ;

-- Funktion som visar en specifik beställning på ordernummer
DELIMITER $$
CREATE PROCEDURE VisaOrdernummer (
	IN in_Ordernummer INT
)
BEGIN
	-- Gör en inner join funktion här för att visa all relevant data precis som innan
    SELECT
        Beställningar.Ordernummer,
        Kunder.Epost,
        Beställningar.Datum,
        Böcker.ISBN,
        Böcker.Titel,
        Böcker.Författare,
        Böcker.Pris,
        Orderrader.Antal,
        Beställningar.Totalbelopp,
        Kunder.Adress AS Leveransadress
    FROM Orderrader
    INNER JOIN Beställningar ON Orderrader.Ordernummer = Beställningar.Ordernummer
    INNER JOIN Kunder ON Beställningar.Epost = Kunder.Epost
    INNER JOIN Böcker ON Orderrader.ISBN = Böcker.ISBN
    WHERE (Beställningar.Ordernummer = in_Ordernummer);
END$$
DELIMITER ;

-- Funktion som visar alla kunder som har gjort en beställning
DELIMITER $$
CREATE PROCEDURE VisaKunderMedBeställningar()
BEGIN
    SELECT DISTINCT
        Kunder.Epost, 
        Kunder.Namn, 
        Kunder.Telefon
    FROM Kunder
    INNER JOIN Beställningar ON Kunder.Epost = Beställningar.Epost;
END $$
DELIMITER ;

-- Funktion som visar antalet beställninger per kund
DELIMITER $$
CREATE PROCEDURE VisaAntalBeställningarPerKund()
BEGIN
    SELECT 
        Kunder.Epost, 
        Kunder.Namn, 
        COUNT(Beställningar.Ordernummer) AS AntalBeställningar
    FROM Kunder
    LEFT JOIN Beställningar ON Kunder.Epost = Beställningar.Epost
    GROUP BY Kunder.Epost, Kunder.Namn;
END $$
DELIMITER ;

-- Funktion som visar kunder med fler än två beställningar, vem kunde anat?
DELIMITER $$
CREATE PROCEDURE VisaKunderMedFlerÄnTvåBeställningar()
BEGIN
    SELECT 
        Kunder.Epost, 
        Kunder.Namn, 
        COUNT(Beställningar.Ordernummer) AS AntalBeställningar
    FROM Kunder
    INNER JOIN Beställningar ON Kunder.Epost = Beställningar.Epost
    GROUP BY Kunder.Epost, Kunder.Namn
    HAVING COUNT(Beställningar.Ordernummer) > 2; -- Exakt samma som förra funktionen, utöver att den kräver 2+ beställningar
END $$
DELIMITER ;

-- Trigger som minskar kvantiteten i lagret på böcker när en beställning läggs
DELIMITER $$
CREATE TRIGGER UppdateraLagerPåBeställning
AFTER INSERT ON Orderrader
FOR EACH ROW
BEGIN
    UPDATE Böcker
    SET Lagersaldo = Lagersaldo - NEW.Antal
    WHERE ISBN = NEW.ISBN;
    -- Uppdaterar lagerstatusen beroende på lagersaldot
    SET @lagersaldo = (SELECT Lagersaldo FROM Böcker WHERE ISBN = NEW.ISBN);
    IF @lagersaldo = 0 THEN 
		UPDATE Böcker SET Lagerstatus = "Finns ej i lager" WHERE ISBN = NEW.ISBN;
	END IF;
END$$
DELIMITER ;

-- Infogar testdata för Böcker
INSERT INTO Böcker ( Titel, Författare, Pris, Lagersaldo ) VALUES
	("Kaosmakarna", "Giuliano Da Empoli", 478, 4),
    ("Mangia: Pasta och annat gott", "Oliver Ingrosso", 127, 5),
    ("Killer Queen", "Denise Rudberg", 252, 3),
    ("Historian om SQL Kevve", "Kevin Kosner", 784, 1);

-- Infogar testdata för Kunder
INSERT INTO Kunder ( Namn, Epost, Telefon, Adress ) VALUES
	("Bengt Svensson", "bengt.kingkong@email.com", "072-662 39 75", "Flugsvampsgatan 12C"),
    ("Giovanni Karlsson", "mannendetegiovanni@email.com", "073-810 32 30", "Södra Kvarngatan 28"),
    ("Viola Milan", "coolviolagaming@email.com", "076-925 12 85", "Kraftvägen 6"),
    ("Erik Johansson", "eriksfetamejl@email.com", "070-293 37 95", "Hemlös");
    

CALL Beställ ("bengt.kingkong@email.com", 1, 4, NULL); -- Nybeställning för bengt

CALL Beställ ("bengt.kingkong@email.com", 2, 3, 1); -- Bengt beställer ytterliggare böcker i samma ordernummer

CALL Beställ ("mannendetegiovanni@email.com", 4, 1, NULL);

CALL Beställ ("eriksfetamejl@email.com", 4, 2, NULL);	

CALL VisaBeställningar ("bengt.kingkong@email.com");	-- Visar alla beställningar för Bengt

CALL UppdateraKundEpost ("bengt.kingkong@email.com", "intebengtlängre@email.com");		-- Uppdaterar eposten för Bengt

CALL VisaBeställningar (NULL);		-- Visar alla beställningar

CALL VisaOrdernummer (1); 			-- Visar beställningen med ordernummer 1

CALL LäggTillLagersaldo (4, 2); 	-- Lägger till 2 exemplar av Historian om SQL Kevve

CALL TaBortKund ("mannendetegiovanni@email.com"); -- Tar bort kunden Giovanni

CALL VisaKunderMedBeställningar ();		-- Visar alla kunder med beställningarna

CALL VisaAntalBeställningarPerKund ();	-- Visar antalet beställningar per kund

-- Visar all data (demonstrerar hur värdena har ändrats)
SELECT * FROM KundLogg;
SELECT * FROM Böcker;
SELECT * FROM Kunder;
SELECT * FROM Beställningar;
SELECT * FROM Orderrader;

-- BACKUP: mysqldump -u root -p Bokhandel > bokhandel_backup.sql
-- LADDA IN BACKUP: mysql -u root -p Bokhandel < bokhandel_backup.sql
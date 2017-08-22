-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Final Project
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;   -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TDrugKits' )								IS NOT NULL DROP TABLE TDrugKits
IF OBJECT_ID( 'TPatientVisits' )						IS NOT NULL DROP TABLE TPatientVisits
IF OBJECT_ID( 'TWithdrawReasons' )						IS NOT NULL DROP TABLE TWithdrawReasons
IF OBJECT_ID( 'TVisitTypes' )							IS NOT NULL DROP TABLE TVisitTypes
IF OBJECT_ID( 'TPatients' )								IS NOT NULL DROP TABLE TPatients
IF OBJECT_ID( 'TGenders' )								IS NOT NULL DROP TABLE TGenders
IF OBJECT_ID( 'TRandomCodes' )							IS NOT NULL DROP TABLE TRandomCodes
IF OBJECT_ID( 'TSites' )								IS NOT NULL DROP TABLE TSites
IF OBJECT_ID( 'TStudies' )								IS NOT NULL DROP TABLE TStudies
IF OBJECT_ID( 'VStudyPatients' )						IS NOT NULL DROP VIEW VStudyPatients
IF OBJECT_ID( 'VRandomizedPatients' )					IS NOT NULL DROP VIEW VRandomizedPatients
IF OBJECT_ID( 'VNextAvailableRandomCodeStudy12345' )	IS NOT NULL DROP VIEW VNextAvailableRandomCodeStudy12345
IF OBJECT_ID( 'VNextAvailableRandomCodeStudy54321' )	IS NOT NULL DROP VIEW VNextAvailableRandomCodeStudy54321
IF OBJECT_ID( 'VAvailableDrugKitsStudy12345' )			IS NOT NULL DROP VIEW VAvailableDrugKitsStudy12345
IF OBJECT_ID( 'VAvailableDrugKitsStudy54321' )			IS NOT NULL DROP VIEW VAvailableDrugKitsStudy54321
IF OBJECT_ID( 'VWithdrawnPatients' )					IS NOT NULL DROP VIEW VWithdrawnPatients
IF OBJECT_ID( 'VHighestPatientID' )						IS NOT NULL DROP VIEW VHighestPatientID
IF OBJECT_ID( 'VHighestVisitID' )						IS NOT NULL DROP VIEW VHighestVisitID
IF OBJECT_ID( 'VPatientStudies' )						IS NOT NULL DROP VIEW VPatientStudies
IF OBJECT_ID( 'uspScreenPatient' )						IS NOT NULL DROP PROCEDURE uspScreenPatient
IF OBJECT_ID( 'uspRandomizePatient' )					IS NOT NULL DROP PROCEDURE uspRandomizePatient
IF OBJECT_ID( 'uspWithdrawPatient' )					IS NOT NULL DROP PROCEDURE uspWithdrawPatient

-- --------------------------------------------------------------------------------
-- Step 2 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TStudies
(
	 intStudyID				INTEGER				NOT NULL
	,strStudyDesc			VARCHAR(50)			NOT NULL
	,CONSTRAINT TStudies_PK PRIMARY KEY ( intStudyID )
)

CREATE TABLE TSites
(
	 intSiteID				INTEGER				NOT NULL
	,intStudyID				INTEGER				NOT NULL
	,strName				VARCHAR(50)			NOT NULL
	,strAddress				VARCHAR(100)		NOT NULL
	,strCity				VARCHAR(50)			NOT NULL
	,strState				VARCHAR(50)			NOT NULL
	,strZip					VARCHAR(50)			NOT NULL
	,strPhone				VARCHAR(50)			NOT NULL
	,CONSTRAINT TSites_PK PRIMARY KEY ( intSiteID )
)

CREATE TABLE TGenders
(
	 intGenderID			INTEGER				NOT NULL
	,strGender				VARCHAR(50)			NOT NULL
	,CONSTRAINT TGenders_PK PRIMARY KEY( intGenderID )
)

CREATE TABLE TPatients
(
	 intPatientID			INTEGER				NOT NULL
	,intSiteID				INTEGER				NOT NULL
	,dtmDOB					DATETIME			NOT NULL
	,intGenderID			INTEGER				NOT NULL
	,intWeight				INTEGER				NOT NULL
	,intRandomCodeID		INTEGER
	,CONSTRAINT TPatients_PK PRIMARY KEY ( intPatientID )
)

CREATE TABLE TRandomCodes
(
	 intRandomCodeID		INTEGER				NOT NULL
	,intStudyID				INTEGER				NOT NULL
	,strTreatment			VARCHAR(50)			NOT NULL
	,blnAvailable			CHAR				NOT NULL
	,CONSTRAINT TRandomCodes_PK PRIMARY KEY ( intRandomCodeID )
)

CREATE TABLE TVisitTypes
(
	 intVisitTypeID			INTEGER				NOT NULL
	,strVisitDesc			VARCHAR(50)			NOT NULL
	,CONSTRAINT TVisitTypes_PK PRIMARY KEY ( intVisitTypeID )
)

CREATE TABLE TPatientVisits
(
	 intVisitID				INTEGER				NOT NULL
	,intPatientID			INTEGER				NOT NULL
	,dtmVisit				DATETIME			NOT NULL
	,intVisitTypeID			INTEGER				NOT NULL
	,intWithdrawReasonID	INTEGER		
	,CONSTRAINT TPatientVisits_PK PRIMARY KEY ( intVisitID )
)

CREATE TABLE TWithdrawReasons
(
	 intWithdrawReasonID	INTEGER				NOT NULL
	,strWithdrawDesc		VARCHAR(50)			NOT NULL
	,CONSTRAINT TWithdrawReasons_PK PRIMARY KEY ( intWithdrawReasonID )
)

CREATE TABLE TDrugKits
(
	 intDrugKitID			INTEGER				NOT NULL
	,intSiteID				INTEGER				NOT NULL
	,strTreatment			VARCHAR(50)			NOT NULL
	,intVisitID				INTEGER				
	,CONSTRAINT TDrugKits_PK PRIMARY KEY ( intDrugKitID )
)

-- --------------------------------------------------------------------------------
-- Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child							Parent						Column(s)
--		-----							------						---------
-- 1	TSites							TStudies					intStudyID
-- 2	TPatients						TSites						intSiteID
-- 3	TPatients						TGenders					intGenderID
-- 4    TPatients						TRandomCodes				intRandomCodeID
-- 5	TRandomCodes					TStudies					intStudyID
-- 6	TPatientVisits					TPatients					intPatientID
-- 7	TPatientVisits					TVisitTypes 				intVisitTypeID
-- 8	TPatientVisits					TWithdrawReasons			intWithdrawReasonID
-- 9	TDrugKits						TSites						intSiteID
-- 10	TDrugKits						TPatientVisits				intVisitID

-- 1
ALTER TABLE TSites ADD CONSTRAINT TSites_TStudies_FK
FOREIGN KEY ( intStudyID ) REFERENCES TStudies ( intStudyID )

-- 2
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TSites_FK
FOREIGN KEY ( intSiteID ) REFERENCES TSites ( intSiteID )

-- 3
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TGenders_FK
FOREIGN KEY ( intGenderID ) REFERENCES TGenders ( intGenderID )

-- 4
ALTER TABLE TPatients ADD CONSTRAINT TPatients_TRandomCodes_FK
FOREIGN KEY ( intRandomCodeID ) REFERENCES TRandomCodes ( intRandomCodeID )

-- 5
ALTER TABLE TRandomCodes ADD CONSTRAINT TRandomCodes_TStudies_FK
FOREIGN KEY ( intStudyID ) REFERENCES TStudies ( intStudyID )

-- 6
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TPatients_FK
FOREIGN KEY ( intPatientID ) REFERENCES TPatients ( intPatientID )

-- 7
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TVisitTypes_FK
FOREIGN KEY ( intVisitTypeID ) REFERENCES TVisitTypes ( intVisitTypeID )

-- 8
ALTER TABLE TPatientVisits ADD CONSTRAINT TPatientVisits_TWithdrawReasons_FK
FOREIGN KEY ( intWithdrawReasonID ) REFERENCES TWithdrawReasons ( intWithdrawReasonID )

-- 9
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TSites_FK
FOREIGN KEY ( intSiteID ) REFERENCES TSites ( intSiteID )

-- 10
ALTER TABLE TDrugKits ADD CONSTRAINT TDrugKits_TPatientVisits_FK
FOREIGN KEY ( intVisitID ) REFERENCES TPatientVisits ( intVisitID )

-- --------------------------------------------------------------------------------
-- Add Inserts
-- --------------------------------------------------------------------------------
INSERT INTO TStudies ( intStudyID, strStudyDesc )
VALUES   ( 12345, 'Study 1' )
		,( 54321, 'Study 2' )

INSERT INTO TGenders ( intGenderID, strGender )
VALUES	 ( 1, 'M' )
		,( 2, 'F' )

INSERT INTO TVisitTypes( intVisitTypeID, strVisitDesc )
VALUES	 ( 1, 'Screening' )
		,( 2, 'Randomization' )
		,( 3, 'Withdrawal' )

INSERT INTO TSites( intSiteID, intStudyID, strName, strAddress, strCity, strState, strZip, strPhone )
VALUES	 ( 101,  12345, 'Dr. Stan Heinrich', '123 E. Main St', 'Atlanta', 'GA', '25869', '1234567890' )
		,( 111,  12345, 'Mercy Hospital', '3456 Elmhurst Rd.', 'Secaucus', 'NJ', '32659', '5013629564' )
		,( 121,  12345, 'St. Elizabeth Hospital', '976 Jackson Way', 'Ft. Thomas', 'KY', '41258', '3026521478' )
		,( 131,  12345, 'Dr. Jim Smith', '32454 Morris Rd.', 'Hamilton', 'OH', '45013', '3256847596' )
		,( 141,  12345, 'Dr. Dan Jones', '1865 Jelico Hwy.', 'Knoxville', 'TN', '34568', '2145798241' )
		,( 501,  54321, 'Dr. Robert Adler', '9087 W. Maple Ave.', 'Cedar Rapids', 'IA', '42365', '6149652574' )
		,( 511,  54321, 'Dr. Tim Schmitz', '4539 Helena Run', 'Johnson City', 'TN', '34785', '5066987462' )
		,( 521,  54321, 'Dr. Lawrence Snell', '9201 NW. Washington Blvd.', 'Bristol', 'VA', '20163', '3876510249' )
		,( 531,  54321, 'Cedar Sinai Medical Center', '40321 Hollywood Blvd.', 'Portland', 'OR', '50236', '5439510246' )
		,( 541,	 54321, 'Vally View Hospital', '398 Hampton Rd.', 'Seattle', 'WA', '41203', '7243780036' )

INSERT INTO TRandomCodes( intRandomCodeID, intStudyID, strTreatment, blnAvailable )
VALUES   ( 1000, 12345, 'A', 'T' )
		,( 1001, 12345, 'P', 'T' )
		,( 1002, 12345, 'A', 'T' )
		,( 1003, 12345, 'P', 'T' )
		,( 1004, 12345, 'P', 'T' )
		,( 1005, 12345, 'A', 'T' )
		,( 1006, 12345, 'A', 'T' )
		,( 1007, 12345, 'P', 'T' )
		,( 1008, 12345, 'A', 'T' )
		,( 1009, 12345, 'P', 'T' )
		,( 1010, 12345, 'P', 'T' )
		,( 1011, 12345, 'A', 'T' )
		,( 1012, 12345, 'P', 'T' )
		,( 1013, 12345, 'A', 'T' )
		,( 1014, 12345, 'A', 'T' )
		,( 1015, 12345, 'A', 'T' )
		,( 1016, 12345, 'P', 'T' )
		,( 1017, 12345, 'P', 'T' )
		,( 1018, 12345, 'A', 'T' )
		,( 1019, 12345, 'P', 'T' )
		,( 5000, 54321, 'A', 'T' )
		,( 5001, 54321, 'A', 'T' )
		,( 5002, 54321, 'A', 'T' )
		,( 5003, 54321, 'A', 'T' )
		,( 5004, 54321, 'A', 'T' )
		,( 5005, 54321, 'A', 'T' )
		,( 5006, 54321, 'A', 'T' )
		,( 5007, 54321, 'A', 'T' )
		,( 5008, 54321, 'A', 'T' )
		,( 5009, 54321, 'A', 'T' )
		,( 5010, 54321, 'P', 'T' )
		,( 5011, 54321, 'P', 'T' )
		,( 5012, 54321, 'P', 'T' )
		,( 5013, 54321, 'P', 'T' )
		,( 5014, 54321, 'P', 'T' )
		,( 5015, 54321, 'P', 'T' )
		,( 5016, 54321, 'P', 'T' )
		,( 5017, 54321, 'P', 'T' )
		,( 5018, 54321, 'P', 'T' )
		,( 5019, 54321, 'P', 'T' )

INSERT INTO TWithdrawReasons( intWithdrawReasonID, strWithdrawDesc )
VALUES   ( 1, 'Patient withdrew consent' )
		,( 2, 'Adverse event' )
		,( 3, 'Health issue-related to study' )
		,( 4, 'Health issue-unrelated to study' )
		,( 5, 'Personal reason' )
		,( 6, 'Completed the study' )

INSERT INTO TDrugKits( intDrugKitID, intSiteID, strTreatment, intVisitID )
VALUES   ( 10000, 101, 'A', NULL )
		,( 10001, 101, 'A', NULL )
		,( 10002, 101, 'A', NULL )
		,( 10003, 101, 'A', NULL )
		,( 10004, 101, 'P', NULL )
		,( 10005, 101, 'P', NULL )
		,( 10006, 101, 'P', NULL )
		,( 10007, 101, 'P', NULL )
		,( 10008, 111, 'A', NULL )
		,( 10009, 111, 'A', NULL )
		,( 10010, 111, 'A', NULL )
		,( 10011, 111, 'A', NULL )
		,( 10012, 111, 'P', NULL )
		,( 10013, 111, 'P', NULL )
		,( 10014, 111, 'P', NULL )
		,( 10015, 111, 'P', NULL )
		,( 10016, 121, 'A', NULL )
		,( 10017, 121, 'A', NULL )
		,( 10018, 121, 'A', NULL )
		,( 10019, 121, 'A', NULL )
		,( 10020, 121, 'P', NULL )
		,( 10021, 121, 'P', NULL )
		,( 10022, 121, 'P', NULL )
		,( 10023, 121, 'P', NULL )
		,( 10024, 131, 'A', NULL )
		,( 10025, 131, 'A', NULL )
		,( 10026, 131, 'A', NULL )
		,( 10027, 131, 'A', NULL )
		,( 10028, 131, 'P', NULL )
		,( 10029, 131, 'P', NULL )
		,( 10030, 131, 'P', NULL )
		,( 10031, 131, 'P', NULL )
		,( 10032, 141, 'A', NULL )
		,( 10033, 141, 'A', NULL )
		,( 10034, 141, 'A', NULL )
		,( 10035, 141, 'A', NULL )
		,( 10036, 141, 'P', NULL )
		,( 10037, 141, 'P', NULL )
		,( 10038, 141, 'P', NULL )
		,( 10039, 141, 'P', NULL )
		,( 10040, 501, 'A', NULL )
		,( 10041, 501, 'A', NULL )
		,( 10042, 501, 'A', NULL )
		,( 10043, 501, 'A', NULL )
		,( 10044, 501, 'P', NULL )
		,( 10045, 501, 'P', NULL )
		,( 10046, 501, 'P', NULL )
		,( 10047, 501, 'P', NULL )
		,( 10048, 511, 'A', NULL )
		,( 10049, 511, 'A', NULL )
		,( 10050, 511, 'A', NULL )
		,( 10051, 511, 'A', NULL )
		,( 10052, 511, 'P', NULL )
		,( 10053, 511, 'P', NULL )
		,( 10054, 511, 'P', NULL )
		,( 10055, 511, 'P', NULL )
		,( 10056, 521, 'A', NULL )
		,( 10057, 521, 'A', NULL )
		,( 10058, 521, 'A', NULL )
		,( 10059, 521, 'A', NULL )
		,( 10060, 521, 'P', NULL )
		,( 10061, 521, 'P', NULL )
		,( 10062, 521, 'P', NULL )
		,( 10063, 521, 'P', NULL )
		,( 10064, 531, 'A', NULL )
		,( 10065, 531, 'A', NULL )
		,( 10066, 531, 'A', NULL )
		,( 10067, 531, 'A', NULL )
		,( 10068, 531, 'P', NULL )
		,( 10069, 531, 'P', NULL )
		,( 10070, 531, 'P', NULL )
		,( 10071, 531, 'P', NULL )
		,( 10072, 541, 'A', NULL )
		,( 10073, 541, 'A', NULL )
		,( 10074, 541, 'A', NULL )
		,( 10075, 541, 'A', NULL )
		,( 10076, 541, 'P', NULL )
		,( 10077, 541, 'P', NULL )
		,( 10078, 541, 'P', NULL )
		,( 10079, 541, 'P', NULL )

-- --------------------------------------------------------------------------------
-- Step #3 - Create the view that will show all patients at all sites for both
--           studies.
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VStudyPatients
AS
	SELECT * FROM TPatients

-- --------------------------------------------------------------------------------
-- Step #4 - Create the view that will show all randomized patients, their site, 
--           and their treatment for both studies.
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VRandomizedPatients
AS
	SELECT 
		 TP.intPatientID
		,TS.intSiteID
		,TS.strName
		,TRC.intRandomCodeID
		,TRC.strTreatment
	FROM
		TPatients AS TP
			JOIN TSites AS TS
			ON( TP.intSiteID = TS.intSiteID )

			JOIN TRandomCodes AS TRC
			ON( TP.intRandomCodeID = TRC.intRandomCodeID )
	WHERE
		TP.intRandomCodeID IS NOT NULL

-- --------------------------------------------------------------------------------
-- Step #5 - Create the view that will show the next available random codes (MIN)
--           for both studies.
-- --------------------------------------------------------------------------------
GO

-- Next available random code for study 12345
CREATE VIEW VNextAvailableRandomCodeStudy12345
AS
	SELECT 
		 MIN(intRandomCodeID) AS intNextAvailable
		,intStudyID
	FROM
		TRandomCodes
	WHERE
			blnAvailable = 'T'
		AND intStudyID = 12345
	GROUP BY
		 intStudyID

GO

-- Next available random code for study 54321
CREATE VIEW VNextAvailableRandomCodeStudy54321
AS
	SELECT
		 MIN(intRandomCodeID) as intNextAvailable
		,intStudyID
		,strTreatment	
	FROM
		TRandomCodes
	WHERE
			blnAvailable = 'T'
		AND intStudyID = 54321
	GROUP BY
		 intStudyID
		,strTreatment

-- --------------------------------------------------------------------------------
-- Step #6 - Create the view that will show all available drug kits at all sites
--           for both studies.
-- --------------------------------------------------------------------------------	
GO

-- All available drug kits in study 12345
CREATE VIEW VAvailableDrugKitsStudy12345
AS
	SELECT
		 intDrugKitID
		,intSiteID
		,strTreatment
	FROM
		TDrugKits
	WHERE
			intSiteID LIKE '1%'
		AND intVisitID IS NULL	

GO

-- All available drug kits in study 54321
CREATE VIEW VAvailableDrugKitsStudy54321
AS
	SELECT
		 intDrugKitID
		,intSiteID
		,strTreatment
	FROM
		TDrugKits
	WHERE
			intSiteID LIKE '5%'
		AND intVisitID IS NULL	
		
-- --------------------------------------------------------------------------------
-- Step #7 - Create the view that will show all withdrawn patients, their site,
--           withdrawal date, and withdrawal reason.
-- --------------------------------------------------------------------------------	
GO

CREATE VIEW VWithdrawnPatients
AS
	SELECT
		 TP.intPatientID
		,TS.intSiteID
		,TS.strName
		,TPV.intVisitID
		,TPV.dtmVisit
		,TWD.intWithdrawReasonID
		,TWD.strWithdrawDesc
	FROM
		TPatients AS TP
			JOIN TSites AS TS
			ON ( TP.intSiteID = TS.intSiteID )

			JOIN TPatientVisits AS TPV
				JOIN TWithdrawReasons AS TWD
				ON ( TPV.intWithdrawReasonID = TWD.intWithdrawReasonID )

			ON( TP.intPatientID = TPV.intPatientID )
	WHERE 
		TPV.intVisitTypeID = 3

-- --------------------------------------------------------------------------------
-- Step #8 - Create other views as needed.
-- --------------------------------------------------------------------------------	
GO

CREATE VIEW VHighestVisitID
AS
	SELECT
		MAX(intVisitID) AS intHighestVisitID
	FROM
		TPatientVisits

GO

CREATE VIEW VPatientStudies
AS
	SELECT
		 TP.intPatientID
		,TS.intStudyID
	FROM
		TPatients AS TP
			JOIN TSites AS TS
			ON( TP.intSiteID = TS.intSiteID )
GO	

-- --------------------------------------------------------------------------------
-- Step #9 - Create the stored procedure that will screen a patient for both 
--           studies.
-- --------------------------------------------------------------------------------	
GO

CREATE PROCEDURE uspScreenPatient
	 @intSiteID			AS INTEGER
	,@dtmDateOfBirth	AS DATETIME
	,@intGenderID		AS INTEGER
	,@intWeight			AS INTEGER
	,@dtmVisit			AS DATETIME
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intPatientID		   AS INTEGER
DECLARE @intDefaultPatientID   AS INTEGER
DECLARE @intHighestVisitID	   AS INTEGER
DECLARE @intVisitID			   AS INTEGER 
DECLARE @intVisitTypeID		   AS INTEGER

-- Get highest visit ID in TPatientVisits
BEGIN
	DECLARE VisitCursor CURSOR LOCAL FOR
	SELECT
		intHighestVisitID
	FROM 
		VHighestVisitID

		OPEN
			VisitCursor
		FETCH FROM
			VisitCursor
		INTO
			@intHighestVisitID
END

-- Set Patient ID
BEGIN TRANSACTION

	-- Set new Patient ID to highest current Patient ID + 1
	SELECT 
		@intPatientID = MAX(intPatientID) + 1
	FROM
		TPatients
	WHERE
		intSiteID = @intSiteID

	-- Seed Patient IDs - set the ID for the first patient at each site.
	SELECT
		@intDefaultPatientID =		
			CASE @intSiteID
				WHEN 101 THEN 101001
				WHEN 111 THEN 111001
				WHEN 121 THEN 121001
				WHEN 131 THEN 131001
				WHEN 141 THEN 141001
				WHEN 501 THEN 501001
				WHEN 511 THEN 511001
				WHEN 521 THEN 521001
				WHEN 531 THEN 531001
				WHEN 541 THEN 541001
			END

	-- Default to default patient ID for site if table is empty (the first patient for a site)
	SELECT @intPatientID = COALESCE( @intPatientID, @intDefaultPatientID )

	-- Set new visit ID - highest current ID + 1
	SELECT @intVisitID   = @intHighestVisitID + 1

	-- If TPatientVisits table is empty, set first visit ID to 1
	SELECT @intVisitID   = COALESCE( @intVisitID, 1 )

	-- Insert patient into TPatients
	INSERT INTO TPatients( intPatientID, intSiteID, dtmDOB, intGenderID, intWeight )
	VALUES( @intPatientID, @intSiteID, @dtmDateOfBirth, @intGenderID, @intWeight )

	-- Insert screening visit for patient
	INSERT INTO TPatientVisits( intVisitID, intPatientID, dtmVisit, intVisitTypeID )
	VALUES( @intVisitID, @intPatientID, @dtmVisit, 1 )

COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Step #10 - Create the stored procedure that will randomize a patient for both
--			  studies.
-- --------------------------------------------------------------------------------	
GO

CREATE PROCEDURE uspRandomizePatient
	 @intPatientID		AS INTEGER
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intRandomCodeID			AS INTEGER
DECLARE @intStudyID					AS INTEGER
DECLARE @intHighestVisitID			AS INTEGER
DECLARE @intSiteID					AS INTEGER
DECLARE @intDrugKitID				AS INTEGER
DECLARE @intVisitID					AS INTEGER
DECLARE @dtmVisit					AS DATETIME
DECLARE @strTreatment				AS VARCHAR(50)
DECLARE @intActiveCount				AS INTEGER
DECLARE @intPlaceboCount			AS INTEGER

-- Get study ID associated with patient
BEGIN
	DECLARE StudyCursor CURSOR LOCAL FOR
		SELECT 
			intStudyID
		FROM 
			VPatientStudies
		WHERE intPatientID = @intPatientID

		OPEN 
			StudyCursor
		FETCH FROM 
			StudyCursor
		INTO
			@intStudyID
END

-- Get site associated with patient.
BEGIN
	DECLARE SiteCursor CURSOR LOCAL FOR
		SELECT
			intSiteID
		FROM
			VStudyPatients
		WHERE
			intPatientID = @intPatientID

		OPEN
			SiteCursor
		FETCH FROM
			SiteCursor
		INTO
			@intSiteID
END

-- If study 12345, assign a random code and treatment using a random pick list.
IF( @intStudyID = 12345 ) 
	BEGIN
	
			DECLARE RandomCursorStudy1 CURSOR LOCAL FOR
			SELECT
				 intNextAvailable
			FROM 
				VNextAvailableRandomCodeStudy12345
			WHERE 
				intStudyID = 12345

			OPEN
				RandomCursorStudy1
			FETCH FROM
				RandomCursorStudy1
			INTO
				@intRandomCodeID

			-- Get the treatment associated with the assigned random code.
			DECLARE TreatmentCursor CURSOR LOCAL FOR
			SELECT
				strTreatment
			FROM
				TRandomCodes
			WHERE
				intRandomCodeID = @intRandomCodeID

			OPEN
				TreatmentCursor
			FETCH FROM
				TreatmentCursor
			INTO
				@strTreatment

			-- Get next available drug kit for assigned treatment.
			DECLARE DrugKitCursorStudy12345 CURSOR LOCAL FOR
			SELECT 
				intDrugKitID
			FROM
				VAvailableDrugKitsStudy12345
			WHERE
					intSiteID	 = @intSiteID
				AND strTreatment = @strTreatment

			OPEN
				DrugKitCursorStudy12345
			FETCH FROM
				DrugKitCursorStudy12345
			INTO
				@intDrugKitID
	END
ELSE
	-- If study 54321, assign a random code and treatment using a random generator, but ensuring that one treatment
	-- does not outnumber the other by more than 2.
	BEGIN
	
		-- Determine current number of patients receiving 'active' treatment.
		SELECT @intActiveCount = (SELECT
									COUNT(*)
								  FROM
										VRandomizedPatients
								  WHERE 
										intSiteID LIKE '5%'
									AND	strTreatment = 'A')

		-- Determine current number of patients receiving 'placebo' treatment.						
		SELECT @intPlaceboCount = (SELECT
									COUNT(*)
								   FROM
										VRandomizedPatients
								   WHERE 
										 intSiteID LIKE '5%'
									 AND strTreatment = 'P')
								 
		-- If patients receiving 'active' treatment outnumber patients receiving 'placebo' treatment
		-- by 2, assign the patient to the 'placebo' group.
		IF( (@intActiveCount - @intPlaceboCount) > 1) 
			SELECT @strTreatment =  'P'

		-- If patients receiving 'placebo' treatment outnumber patients receiving 'active' treatment
		-- by 2, assign the patient to the 'active' group.
		ELSE IF( (@intPlaceboCount - @intActiveCount) > 1) 
			SELECT @strTreatment = 'A'

		-- Otherwise, assign the patient to a treatment using a random generator.
		ELSE
			BEGIN
				SELECT @strTreatment = 
					CASE
						WHEN RAND() > 0.5 THEN 'A'
						ELSE
							'P'
					END
			END
	
		-- Get the next available random code for study 54321.
		DECLARE RandomCursorStudy2 CURSOR LOCAL FOR
		SELECT
			intNextAvailable
		FROM 
			VNextAvailableRandomCodeStudy54321
		WHERE 
				intStudyID = 54321
			AND strTreatment = @strTreatment

		OPEN
			RandomCursorStudy2
		FETCH FROM
			RandomCursorStudy2
		INTO
			@intRandomCodeID

		-- Get next available drug kit for assigned treatment.
		DECLARE DrugKitCursorStudy54321 CURSOR LOCAL FOR
		SELECT TOP 1
			intDrugKitID
		FROM
			VAvailableDrugKitsStudy54321
		WHERE
				intSiteID	 = @intSiteID
			AND strTreatment = @strTreatment

		OPEN
			DrugKitCursorStudy54321
		FETCH FROM
			DrugKitCursorStudy54321
		INTO
			@intDrugKitID
		END

-- Get the highest visit ID in TPatientVisits.
BEGIN
	DECLARE VisitCursor CURSOR LOCAL FOR
		SELECT
			intHighestVisitID
		FROM 
			VHighestVisitID

		OPEN
			VisitCursor
		FETCH FROM
			VisitCursor
		INTO
			@intHighestVisitID
END

BEGIN TRANSACTION

	-- Set visit ID (next highest visit ID in TPatientVisits).
	SELECT @intVisitID   = @intHighestVisitID + 1

	-- Assign random code to patient.
	UPDATE 
		TPatients
	SET 
		intRandomCodeID = @intRandomCodeID 
	WHERE
		intPatientID = @intPatientID

	-- Make assigned random code unavailable to other patients.
	UPDATE
		TRandomCodes
	SET
		blnAvailable = 'F'
	WHERE
		intRandomCodeID = @intRandomCodeID

	-- Insert randomization visit for patient.
	INSERT INTO TPatientVisits( intVisitID, intPatientID, dtmVisit, intVisitTypeID )
	VALUES( @intVisitID, @intPatientID, GETDATE(), 2 )

	-- Make assigned drug kit unavailable to other patients.
	UPDATE
		TDrugKits
	SET
		intVisitID = @intVisitID
	WHERE
		intDrugKitID = @intDrugKitID
	
COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Step #11 - Create the stored procedure that will withdraw a patient for both
--			  studies.
-- --------------------------------------------------------------------------------	
GO

CREATE PROCEDURE uspWithdrawPatient
	 @intPatientID			AS INTEGER
	,@dtmVisit				AS DATETIME
	,@intWithdrawReasonID	AS INTEGER
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intVisitID					AS INTEGER
DECLARE @intHighestVisitID			AS INTEGER
DECLARE @dtmLastVisitDate			AS DATETIME

-- Get the highest visit ID in TPatientVisits.
BEGIN
	DECLARE VisitCursor CURSOR LOCAL FOR
		SELECT
			intHighestVisitID
		FROM 
			VHighestVisitID

		OPEN
			VisitCursor
		FETCH FROM
			VisitCursor
		INTO
			@intHighestVisitID
END

-- Get the previous visit date for the patient.
BEGIN
	DECLARE PriorVisitDateCursor CURSOR LOCAL FOR
		SELECT TOP 1
			dtmVisit
		FROM
			TPatientVisits
		WHERE
			intPatientID = @intPatientID 
		ORDER BY
			dtmVisit DESC

		OPEN
			PriorVisitDateCursor
		FETCH FROM
			PriorVisitDateCursor
		INTO
			@dtmLastVisitDate
END

BEGIN TRANSACTION

	-- If current visit date is valid (more recent than the last visit date)...
	IF( @dtmVisit > @dtmLastVisitDate )
		BEGIN
			-- Set visit ID (next highest visit ID in TPatientVisits).
			SELECT @intVisitID   = @intHighestVisitID + 1

			-- Insert withdrawal visit for patient.
			INSERT INTO TPatientVisits( intVisitID, intPatientID, dtmVisit, intVisitTypeID, intWithdrawReasonID )
			VALUES ( @intVisitID, @intPatientID, @dtmVisit, 3, @intWithdrawReasonID )
		END
COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Screening - screen 8 patients for each study.
-- --------------------------------------------------------------------------------	
GO
uspScreenPatient 101, '12/25/1975', 2, 115, '01/02/2017'
GO
uspScreenPatient 101, '04/05/1970', 1, 160, '01/02/2017'
GO
uspScreenPatient 111, '06/06/1995', 2, 120, '01/02/2017'
GO
uspScreenPatient 111, '02/02/1992', 1, 220, '01/02/2017'
GO
uspScreenPatient 121, '10/26/1970', 2, 198, '01/02/2017'
GO
uspScreenPatient 121, '11/28/1994', 1, 220, '01/02/2017'
GO
uspScreenPatient 131, '09/16/1978', 1, 200, '01/02/2017'
GO
uspScreenPatient 141, '05/24/1967', 2, 140, '01/02/2017'
GO
uspScreenPatient 501, '08/14/1956', 2, 175, '01/05/2017'
GO
uspScreenPatient 501, '01/22/1943', 1, 170, '01/05/2017'
GO
uspScreenPatient 511, '03/01/1970', 2, 144, '01/05/2017'
GO
uspScreenPatient 511, '07/31/1968', 1, 205, '01/05/2017'
GO
uspScreenPatient 521, '12/15/1974', 2, 122, '01/05/2017'
GO
uspScreenPatient 521, '11/01/1959', 1, 166, '01/05/2017'
GO
uspScreenPatient 531, '04/22/1980', 2, 171, '01/05/2017'
GO
uspScreenPatient 541, '06/06/1945', 1, 218, '01/05/2017'

-- --------------------------------------------------------------------------------
-- Randomization - randomize 5 patients for each study.
-- --------------------------------------------------------------------------------	
GO
uspRandomizePatient 101001
GO
uspRandomizePatient 111002
GO
uspRandomizePatient 121002
GO
uspRandomizePatient 131001
GO
uspRandomizePatient 141001
GO
uspRandomizePatient 501001
GO
uspRandomizePatient 511002
GO
uspRandomizePatient 521002
GO
uspRandomizePatient 531001
GO
uspRandomizePatient 541001

-- --------------------------------------------------------------------------------
-- Withdrawal - withdraw 4 patients from each study (2 randomized and 2 not
--              randomized.
-- --------------------------------------------------------------------------------	
GO
uspWithdrawPatient 111002, '09/02/2017', 6
GO
uspWithdrawPatient 131001, '08/29/2017', 3
GO
uspWithdrawPatient 101002, '01/04/2017', 1
GO
uspWithdrawPatient 111001, '01/03/2017', 5
GO
uspWithdrawPatient 501001, '09/05/2017', 6
GO
uspWithdrawPatient 541001, '08/31/2017', 5
GO
uspWithdrawPatient 501002, '01/06/2017', 1
GO
uspWithdrawPatient 521001, '01/07/2017', 4
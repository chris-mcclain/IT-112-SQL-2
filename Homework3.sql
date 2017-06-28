-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Homework 3 - Stored Procedures
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Procedures and Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'uspAdd2Numbers' )					IS NOT NULL DROP PROCEDURE uspAdd2Numbers
IF OBJECT_ID( 'uspMultiply2Numbers' )				IS NOT NULL DROP PROCEDURE uspMultiply2Numbers
IF OBJECT_ID( 'uspDivide2Numbers' )					IS NOT NULL DROP PROCEDURE uspDivide2Numbers
IF OBJECT_ID( 'uspCallAnotherStoredProcedure' )		IS NOT NULL DROP PROCEDURE uspCallAnotherStoredProcedure

IF OBJECT_ID( 'TTeamPlayers' )						IS NOT NULL DROP TABLE TTeamPlayers
IF OBJECT_ID( 'TPlayers' )							IS NOT NULL DROP TABLE TPlayers
IF OBJECT_ID( 'TTeams' )							IS NOT NULL DROP TABLE TTeams
IF OBJECT_ID( 'TCoaches' )							IS NOT NULL DROP TABLE TCoaches

IF OBJECT_ID( 'uspAddCoach' )						IS NOT NULL DROP PROCEDURE uspAddCoach
IF OBJECT_ID( 'uspAddTeam' )						IS NOT NULL DROP PROCEDURE uspAddTeam
IF OBJECT_ID( 'uspAddPlayer' )						IS NOT NULL DROP PROCEDURE uspAddPlayer
IF OBJECT_ID( 'uspAddTeamCoachAndPlayer' )			IS NOT NULL DROP PROCEDURE uspAddTeamCoachAndPlayer

-- --------------------------------------------------------------------------------
-- Step #1.1 - uspAdd2Numbers
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAdd2Numbers
	 @intValue1 AS INTEGER
	,@intValue2 AS INTEGER
AS
SET NOCOUNT ON

DECLARE @intResult AS INTEGER = 0

--Do calculation
SELECT @intResult = @intValue1 + @intValue2

--Display results
SELECT @intResult AS intResult

GO

uspAdd2Numbers 5, 10

-- --------------------------------------------------------------------------------
-- Step #1.2 - uspMultiply2Numbers
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspMultiply2Numbers
	 @intValue1 AS INTEGER
	,@intValue2 AS INTEGER
AS
SET NOCOUNT ON

DECLARE @intResult AS INTEGER = 0

--Do calculation
SELECT @intResult = @intValue1 * @intValue2

--Display results
SELECT @intResult AS intResult

GO

uspMultiply2Numbers 5, 10

-- --------------------------------------------------------------------------------
-- Step #1.3 - uspDivide2Numbers and uspCallAnotherStoreProcedure
-- --------------------------------------------------------------------------------

-- ************************************************************************************************
-- +25% Extra Credit for figuring out how to get the correct answer for 5.0/10.0
-- Defining scale for the DECIMAL datatype prevents rounding errors.
-- To get the correct answer for this problem, I defined the scale as 2, allowing
-- 2 decimal places for the calcuation.  If scale is not defined, SQL Server defaults to a scale of
-- 0 and the answer, 0.5, is rounded to 1.
--                                  Reference: 
-- http://stackoverflow.com/questions/16641834/sql-stored-procedure-division-rounding-with-decimals
-- *************************************************************************************************

GO

CREATE PROCEDURE uspDivide2Numbers
	 @decValue1				AS DECIMAL(8, 2)
	,@decValue2				AS DECIMAL (8, 2)
	,@decResult				AS DECIMAL (8, 2) OUTPUT
AS
SET NOCOUNT ON    --Report only errors

--Do calculations
SELECT @decResult = @decValue1 / @decValue2

GO

CREATE PROCEDURE uspCallAnotherStoredProcedure
AS
SET NOCOUNT ON   --Report only errors

DECLARE @decResult AS DECIMAL (8, 2)

--Call another stored procedure that returns a value
EXECUTE uspDivide2Numbers 5.0, 10.0, @decResult OUTPUT

--Display Results
SELECT @decResult AS decResult

GO

uspCallAnotherStoredProcedure

-- --------------------------------------------------------------------------------
-- Step #2.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TCoaches
(
	 intCoachID				INTEGER						NOT NULL
	,strFirstName			VARCHAR(50)					NOT NULL
	,strLastName			VARCHAR(50)					NOT NULL
	,strPhoneNumber			VARCHAR(50)					NOT NULL
	,CONSTRAINT TCoaches_PK PRIMARY KEY ( intCoachID )
)

CREATE TABLE TTeams
(
	 intTeamID				INTEGER						NOT NULL
	,strTeam				VARCHAR(50)					NOT NULL
	,strMascot				VARCHAR(50)					NOT NULL
	,intCoachID				INTEGER						NOT NULL
	,CONSTRAINT TTeams_PK PRIMARY KEY ( intTeamID )
)

CREATE TABLE TPlayers
(
	 intPlayerID			INTEGER						NOT NULL
	,strFirstName			VARCHAR(50)					NOT NULL
	,strLastName			VARCHAR(50)					NOT NULL
	,strPhoneNumber			VARCHAR(50)					NOT NULL
	,CONSTRAINT TPlayers_PK PRIMARY KEY ( intPlayerID )
)

CREATE TABLE TTeamPlayers
(
	 intTeamID				INTEGER						NOT NULL
	,intPlayerID			INTEGER						NOT NULL
	,CONSTRAINT TTeamPlayer_PK PRIMARY KEY ( intTeamID, intPlayerID )
)

-- --------------------------------------------------------------------------------
-- Step #2.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child						Parent					Column(s)
--		-----						------					---------
-- 1	TTeams						TCoaches				intCoachID
-- 2	TTeamPlayers				TTeams					intTeamID
-- 3	TTeamPlayers				TPlayers				intPlayerID

--1
ALTER TABLE TTeams ADD CONSTRAINT TTeams_TCoaches_FK
FOREIGN KEY ( intCoachID ) REFERENCES TCoaches ( intCoachID )

--2
ALTER TABLE TTeamPlayers ADD CONSTRAINT TTeamPlayers_TTeams_FK
FOREIGN KEY ( intTeamID ) REFERENCES TTeams ( intTeamID )

--3
ALTER TABLE TTeamPlayers ADD CONSTRAINT TTeamPlayers_TPlayers_FK
FOREIGN KEY ( intPlayerID ) REFERENCES TPlayers ( intPlayerID )

-- --------------------------------------------------------------------------------
-- Step #2.3 uspAddCoach 
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddCoach
	 @intCoachID			AS INTEGER OUTPUT
	,@strFirstName			AS VARCHAR(50)
	,@strLastName			AS VARCHAR(50)
	,@strPhoneNumber		AS VARCHAR(50)
AS
SET NOCOUNT ON     --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

BEGIN TRANSACTION

	SELECT @intCoachID = MAX(intCoachID) + 1
	FROM TCoaches (TABLOCKX)  --Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intCoachID = COALESCE( @intCoachID, 1 )

	INSERT INTO TCoaches( intCoachID, strFirstName, strLastName, strPhoneNumber )
	VALUES( @intCoachID, @strFirstName, @strLastName, @strPhoneNumber )

COMMIT TRANSACTION

GO

DECLARE @intCoachID AS INTEGER = 0;
EXECUTE uspAddCoach @intCoachID OUTPUT, 'Leonhard', 'Euler', '222-2222'
PRINT 'intCoachID = ' + CONVERT( VARCHAR, @intCoachID )

-- --------------------------------------------------------------------------------
-- Step #2.4 uspAddTeam 
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddTeam
	 @intTeamID				AS INTEGER OUTPUT
	,@strTeam				AS VARCHAR(50)
	,@strMascot				AS VARCHAR(50)
	,@intCoachID			AS VARCHAR(50)
AS
SET NOCOUNT ON     --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

BEGIN TRANSACTION

	SELECT @intTeamID = MAX(intTeamID) + 1
	FROM TTeams (TABLOCKX)  --Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intTeamID = COALESCE( @intTeamID, 1 )

	INSERT INTO TTeams( intTeamID, strTeam, strMascot, intCoachID )
	VALUES( @intTeamID, @strTeam, @strMascot, @intCoachID )

COMMIT TRANSACTION

GO

DECLARE @intTeamID AS INTEGER = 0;
EXECUTE uspAddTeam @intTeamID OUTPUT, 'Trigonometrists', 'The Unit Circle', 1
PRINT 'intTeamID = ' + CONVERT( VARCHAR, @intTeamID )

-- --------------------------------------------------------------------------------
-- Step #2.5 uspAddPlayer
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddPlayer
	 @intPlayerID			AS INTEGER OUTPUT
	,@strFirstName			AS VARCHAR(50)
	,@strLastName			AS VARCHAR(50)
	,@strPhoneNumber		AS VARCHAR(50)
AS
SET NOCOUNT ON     --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

BEGIN TRANSACTION

	SELECT @intPlayerID = MAX(intPlayerID) + 1
	FROM TPlayers (TABLOCKX)  --Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intPlayerID = COALESCE( @intPlayerID, 1 )

	INSERT INTO TPlayers( intPlayerID, strFirstName, strLastName, strPhoneNumber )
	VALUES( @intPlayerID, @strFirstName, @strLastName, @strPhoneNumber)

COMMIT TRANSACTION

GO

DECLARE @intPlayerID AS INTEGER = 0;
EXECUTE uspAddPlayer @intPlayerID OUTPUT, 'Leonardo', 'Fibonacci', '404-9827'
PRINT 'intPlayerID = ' + CONVERT( VARCHAR, @intPlayerID )

-- --------------------------------------------------------------------------------
-- Step #2.6 uspAddTeamCoachAndPlayer
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddTeamCoachAndPlayer
	 @strTeam				AS VARCHAR(50)
	,@strMascot				AS VARCHAR(50)

	,@strCoachFirstName		AS VARCHAR(50)
	,@strCoachLastName		AS VARCHAR(50)
	,@strCoachPhoneNumber	AS VARCHAR(50)

	,@strPlayerFirstName	AS VARCHAR(50)
	,@strPlayerLastName		AS VARCHAR(50)
	,@strPlayerPhoneNumber	AS VARCHAR(50)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION

	DECLARE @intCoachID		AS INTEGER = 0;
	DECLARE @intTeamID		AS INTEGER = 0;
	DECLARE @intPlayerID	AS INTEGER = 0;

	--Add Coach
	EXECUTE uspAddCoach @intCoachID OUTPUT, @strCoachFirstName, @strCoachLastName, @strCoachPhoneNumber

	--Add Team
	EXECUTE uspAddTeam @intTeamID OUTPUT, @strTeam, @strMascot, @intCoachID

	--Add Player
	EXECUTE uspAddPlayer @intPlayerID OUTPUT, @strPlayerFirstName, @strPlayerLastName, @strPlayerPhoneNumber

	INSERT INTO TTeamPlayers( intTeamID, intPlayerID )
	VALUES ( @intTeamID, @intPlayerID )

COMMIT TRANSACTION

GO

uspAddTeamCoachAndPlayer 'The Astrophysicists', 'Supernova', 'Stephen', 'Hawking', '123-4567', 'Michio', 'Kaku', '867-5309'

SELECT * FROM TTeams
SELECT * FROM TPlayers
SELECT * FROM TCoaches
SELECT * FROM TTeamPlayers
-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: IT-112-401 (SQL 2)
-- Abstract: Homework 6
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TTeamPlayers' )				IS NOT NULL DROP TABLE TTeamPlayers
IF OBJECT_ID( 'TPlayers' )					IS NOT NULL DROP TABLE TPlayers
IF OBJECT_ID( 'TTeams' )					IS NOT NULL DROP TABLE TTeams

IF OBJECT_ID( 'uspSetTeamStatus' )			IS NOT NULL DROP PROCEDURE uspSetTeamStatus
IF OBJECT_ID( 'uspSetPlayerStatus' )		IS NOT NULL DROP PROCEDURE uspSetPlayerStatus
IF OBJECT_ID( 'uspSetTeamPlayerStatus' )	IS NOT NULL DROP PROCEDURE uspSetTeamPlayerStatus
IF OBJECT_ID( 'uspAddTeam' )				IS NOT NULL DROP PROCEDURE uspAddTeam
IF OBJECT_ID( 'uspAddPlayer' )				IS NOT NULL DROP PROCEDURE uspAddPlayer
IF OBJECT_ID( 'uspAddTeamPlayer' )			IS NOT NULL DROP PROCEDURE uspAddTeamPlayer

IF OBJECT_ID( 'VActiveTeams' )				IS NOT NULL DROP VIEW VActiveTeams
IF OBJECT_ID( 'VActivePlayers' )			IS NOT NULL DROP VIEW VActivePlayers
IF OBJECT_ID( 'VInActiveTeams' )			IS NOT NULL DROP VIEW VInActiveTeams
IF OBJECT_ID( 'VInActivePlayers' )			IS NOT NULL DROP VIEW VInActivePlayers

-- --------------------------------------------------------------------------------
-- Step #1: Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TTeams
(
	 intTeamID 					INTEGER			NOT NULL
	,strTeam					VARCHAR(50)		NOT NULL
	,strMascot					VARCHAR(50)		NOT NULL
	,blnIsActive				BIT				NOT NULL
	,CONSTRAINT TTeams_PK PRIMARY KEY( intTeamID )
)

CREATE TABLE TPlayers
(
	 intPlayerID				INTEGER			NOT NULL
	,strFirstName				VARCHAR(50)		NOT NULL
	,strLastName				VARCHAR(50)		NOT NULL
	,strPhoneNumber				VARCHAR(50)		NOT NULL
	,blnIsActive				BIT				NOT NULL
	,CONSTRAINT TPlayers_PK PRIMARY KEY( intPlayerID )
)

CREATE TABLE TTeamPlayers
(
	 intTeamID					INTEGER			NOT NULL
	,intPlayerID				INTEGER			NOT NULL
	,blnIsActive				BIT				NOT NULL
	,CONSTRAINT TTeamPlayers_PK PRIMARY KEY( intTeamID, intPlayerID )
)

-- --------------------------------------------------------------------------------
-- Step #2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------

--	Child						Parent					Column(s)
--	-----						------					---------
-- 1	TTeamPlayers			TTeams					intTeamID
-- 2	TTeamPlayers			TPlayers				intPlayerID

-- 1
ALTER TABLE TTeamPlayers ADD CONSTRAINT TTeamPlayers_TTeams_FK 
FOREIGN KEY ( intTeamID ) REFERENCES TTeams ( intTeamID )

-- 2
ALTER TABLE TTeamPlayers ADD CONSTRAINT TTeamPlayers_TPlayers_FK 
FOREIGN KEY ( intPlayerID ) REFERENCES TPlayers ( intPlayerID )

-- --------------------------------------------------------------------------------
-- Step #3 Insert data into all tables
-- --------------------------------------------------------------------------------
INSERT INTO TTeams( intTeamID, strTeam, strMascot, blnIsActive )
VALUES	 ( 1, 'Trigonometry', 'Unit Circle', 1 )
		,( 2, 'Astrophysics', 'Higgs Boson', 1 )
		,( 3, 'Chemistry', 'Carbon Atom', 0 )

INSERT INTO TPlayers( intPlayerID, strFirstName, strLastName, strPhoneNumber, blnIsActive )
VALUES   ( 1, 'Sam', 'Johnson', '111-111-1111', 1 )
		,( 2, 'Sarah', 'Smith', '222-222-2222', 1 )
		,( 3, 'Andy', 'Douglas', '333-333-3333', 1 )
		,( 4, 'Jill', 'Dennison', '444-444-4444', 0 )

INSERT INTO TTeamPlayers ( intTeamID, intPlayerID, blnIsActive )
VALUES   ( 1, 1, 0 )
		,( 2, 2, 1 )
		,( 3, 3, 1 )

-- --------------------------------------------------------------------------------
-- Step #4 uspSetTeamStatus
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspSetTeamStatus
	 @intTeamID			AS INTEGER
	,@blnIsActive		AS BIT
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
-- Update the record
UPDATE
	TTeams
SET
	blnIsActive = @blnIsActive
WHERE
	intTeamID = @intTeamID

-- --------------------------------------------------------------------------------
-- Step #5 uspSetPlayerStatus
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspSetPlayerStatus
	 @intPlayerID		AS INTEGER
	,@blnIsActive		AS BIT
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
-- Update the record
UPDATE
	TPlayers
SET
	blnIsActive = @blnIsActive
WHERE
	intPlayerID = @intPlayerID

-- --------------------------------------------------------------------------------
-- Step #6 uspSetTeamPlayerStatus
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspSetTeamPlayerStatus
	 @intTeamID		AS INTEGER
	,@intPlayerID	AS INTEGER
	,@blnIsActive	AS BIT
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
-- Update the record
UPDATE
	TTeamPlayers
SET
	blnIsActive = @blnIsActive
WHERE
	intTeamID	 = @intTeamID
AND intPlayerID	 = @intPlayerID

-- --------------------------------------------------------------------------------
-- Step #7 uspAddTeam
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddTeam
	  @strTeam		AS VARCHAR(50)
	 ,@strMascot	AS VARCHAR(50)
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @intTeamID AS INTEGER
DECLARE @blnAlreadyExists AS BIT = 0

BEGIN TRANSACTION

	-- Check to see if the team already exists.
	SELECT
		@blnAlreadyExists = 1
	FROM
		TTeams (TABLOCKX) -- Lock table until end of transaction
	WHERE 
		strTeam	= @strTeam

	-- Does the team name already exist?
	IF @blnAlreadyExists = 0

		-- No, add the team.
		BEGIN
			
			-- Get the team ID for the new team.
			SELECT @intTeamID = MAX(intTeamID) + 1
			FROM TTEAMS(TABLOCKX) -- Lock table until end of transaction

			-- Default to 1 if table is empty
			SELECT @intTeamID = COALESCE(@intTeamID, 1)

			INSERT INTO TTeams( intTeamID, strTeam, strMascot, blnIsActive )
			VALUES( @intTeamID, @strTeam, @strMascot, 1 )
			
		END
		ELSE BEGIN

			-- Yes, get the team ID associated with the team name
			SELECT 
				@intTeamID = intTeamID
			FROM
				TTeams
			WHERE
				strTeam = @strTeam

			-- Set the team status flag to active
			EXECUTE uspSetTeamStatus @intTeamID, 1
			
		END

		-- Return ID to caller
		SELECT @intTeamID AS intTeamID

COMMIT TRANSACTION

GO

EXECUTE uspAddTeam 'Calculus', 'Derivative'

SELECT * FROM TTeams

-- --------------------------------------------------------------------------------
-- Step #8 uspAddPlayer
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddPlayer
	  @strFirstName		AS VARCHAR(50)
	 ,@strLastName		AS VARCHAR(50)
	 ,@strPhoneNumber	AS VARCHAR(50)
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @intPlayerID AS INTEGER
DECLARE @blnAlreadyExists AS BIT = 0

BEGIN TRANSACTION

	-- Check to see if the player already exists.
	SELECT
		@blnAlreadyExists = 1
	FROM
		TPlayers (TABLOCKX) -- Lock table until end of transaction
	WHERE 
		strFirstName = @strFirstName
	AND strLastName	 = @strLastName

	-- Does the player already exist?
	IF @blnAlreadyExists = 0
		
		-- No, add the player
		BEGIN

			SELECT @intPlayerID = MAX(intPlayerID) + 1
			FROM TPlayers(TABLOCKX) -- Lock table until end of transaction

			-- Default to 1 if table is empty
			SELECT @intPlayerID = COALESCE(@intPlayerID, 1)

			INSERT INTO TPlayers( intPlayerID, strFirstName, strLastName, strPhoneNumber, blnIsActive )
			VALUES( @intPlayerID, @strFirstName, @strLastName, @strPhoneNumber, 1 )
			
		END
		ELSE BEGIN

			-- Yes, get the Team ID associated with the team name
			SELECT 
				@intPlayerID = intPlayerID
			FROM
				TPlayers
			WHERE
				strFirstName = @strFirstName
			AND strLastName =  @strLastName

			-- Set the team status flag to active
			EXECUTE uspSetPlayerStatus @intPlayerID, 1
			
		END

		-- Return ID to caller
		SELECT @intPlayerID AS intPlayerID

COMMIT TRANSACTION

GO

EXECUTE uspAddPlayer 'Natasha', 'McClain', '555-555-5555'

SELECT * FROM TPlayers

-- --------------------------------------------------------------------------------
-- Step #9 uspAddTeamPlayer
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddTeamPlayer
	  @intTeamID		AS INTEGER
	 ,@intPlayerID		AS INTEGER
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @blnAlreadyExists AS BIT = 0

BEGIN TRANSACTION

	-- Check to see if the team player already exists.
	SELECT
		@blnAlreadyExists = 1
	FROM
		TTeamPlayers (TABLOCKX) -- Lock table until end of transaction
	WHERE 
		intTeamID	= @intTeamID
	AND intPlayerID	= @intPlayerID

	-- Does the team player already exist?
	IF @blnAlreadyExists = 0
		
		-- No, add the team player
		BEGIN

			INSERT INTO TTeamPlayers( intTeamID, intPlayerID, blnIsActive )
			VALUES( @intTeamID, @intPlayerID, 1 )
			
		END
		ELSE BEGIN

			-- Set the team player status flag to active
			EXECUTE uspSetTeamPlayerStatus @intTeamID, @intPlayerID, 1
			
		END

		-- Return ID to caller
		SELECT @intTeamID AS intTeamID, @intPlayerID AS intPlayerID

COMMIT TRANSACTION

GO

EXECUTE uspAddTeamPlayer 2, 4

SELECT * FROM TTeamPlayers

-- --------------------------------------------------------------------------------
-- Step #10 VActiveTeams
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VActiveTeams
AS
SELECT
	 intTeamID
	,strTeam
	,strMascot
FROM
	TTeams
WHERE
	blnIsActive = 1

GO

SELECT * FROM TTeams
SELECT * FROM VActiveTeams

-- --------------------------------------------------------------------------------
-- Step #11 VActivePlayers
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VActivePlayers
AS
SELECT
	 intPlayerID
	,strFirstName
	,strLastName
	,strPhoneNumber
FROM
	TPlayers
WHERE 
	blnIsActive = 1

GO

SELECT * FROM TPlayers
SELECT * FROM VActivePlayers

-- --------------------------------------------------------------------------------
-- Step #12 VInActiveTeams
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VInActiveTeams
AS
SELECT
	 intTeamID
	,strTeam
	,strMascot
FROM
	TTeams
WHERE
	blnIsActive = 0

GO

SELECT * FROM TTeams
SELECT * FROM VInActiveTeams

-- --------------------------------------------------------------------------------
-- Step #13 VInActivePlayers
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VInActivePlayers
AS
SELECT
	 intPlayerID
	,strFirstName
	,strLastName
	,strPhoneNumber
FROM
	TPlayers
WHERE 
	blnIsActive = 0

GO

SELECT * FROM TPlayers
SELECT * FROM VInActivePlayers






-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: IT-112-401 (SQL 2)
-- Abstract: Homework 5
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TScheduledRouteDrivers' )	IS NOT NULL DROP TABLE TScheduledRouteDrivers
IF OBJECT_ID( 'TDriverRoles' )			IS NOT NULL DROP TABLE TDriverRoles
IF OBJECT_ID( 'TScheduledRoutes' )		IS NOT NULL DROP TABLE TScheduledRoutes
IF OBJECT_ID( 'TScheduledTimes' )		IS NOT NULL DROP TABLE TScheduledTimes
IF OBJECT_ID( 'TDrivers' )			IS NOT NULL DROP TABLE TDrivers
IF OBJECT_ID( 'TBuses' )			IS NOT NULL DROP TABLE TBuses
IF OBJECT_ID( 'TRoutes' )			IS NOT NULL DROP TABLE TRoutes

IF OBJECT_ID( 'uspEditRoute' )			IS NOT NULL DROP PROCEDURE uspEditRoute
IF OBJECT_ID( 'uspEditDriver' )			IS NOT NULL DROP PROCEDURE uspEditDriver
IF OBJECT_ID( 'uspEditScheduledRoute' )		IS NOT NULL DROP PROCEDURE uspEditScheduledRoute
IF OBJECT_ID( 'uspMoveScheduledRoute' )		IS NOT NULL DROP PROCEDURE uspMoveScheduledRoute
IF OBJECT_ID( 'uspSuperEditScheduledRoute' )	IS NOT NULL DROP PROCEDURE uspSuperEditScheduledRoute

-- --------------------------------------------------------------------------------
-- Step #1: Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TRoutes
(
	 intRouteID 		INTEGER			NOT NULL
	,strRoute		VARCHAR(50)		NOT NULL
	,strRouteDescription	VARCHAR(50)		NOT NULL
	,rvLastUpdated		ROWVERSION		NOT NULL
	,CONSTRAINT TRoutes_PK PRIMARY KEY( intRouteID )
)

CREATE TABLE TBuses
(
	 intBusID		INTEGER			NOT NULL
	,strBus			VARCHAR(50)		NOT NULL
	,intCapacity		INTEGER			NOT NULL
	,CONSTRAINT TBuses_PK PRIMARY KEY( intBusID )
)

CREATE TABLE TDrivers
(
	 intDriverID		INTEGER			NOT NULL
	,strFirstName		VARCHAR(50)		NOT NULL
	,strLastName		VARCHAR(50)		NOT NULL
	,strPhoneNumber		VARCHAR(50)		NOT NULL
	,rvLastUpdated		ROWVERSION		NOT NULL
	,CONSTRAINT TDrivers_PK PRIMARY KEY( intDriverID )
)

CREATE TABLE TScheduledTimes
(	
	 intScheduledTimeID	INTEGER			NOT NULL
	,strScheduledTime	VARCHAR(50)		NOT NULL
	,CONSTRAINT TScheduledTimes_PK PRIMARY KEY( intScheduledTimeID )
)

CREATE TABLE TScheduledRoutes
(
	 intScheduledTimeID	INTEGER			NOT NULL
	,intRouteID		INTEGER			NOT NULL
	,intBusID		INTEGER			NOT NULL
	,rvLastUpdated		ROWVERSION		NOT NULL
	,CONSTRAINT TScheduledRoutes_PK PRIMARY KEY( intScheduledTimeID, intRouteID )
)

CREATE TABLE TDriverRoles
(
	 intDriverRoleID	INTEGER			NOT NULL
	,strDriverRole		VARCHAR(50)		NOT NULL
	,intSortOrder		INTEGER			NOT NULL
	,CONSTRAINT TDriverRoles_PK PRIMARY KEY( intDriverRoleID )
)

CREATE TABLE TScheduledRouteDrivers
(
	 intScheduledTimeID	INTEGER			NOT NULL
	,intRouteID		INTEGER			NOT NULL
	,intDriverID		INTEGER			NOT NULl
	,intDriverRoleID	INTEGER			NOT NULL
	,CONSTRAINT TScheduledRouteDrivers_PK PRIMARY KEY( intScheduledTimeID, intRouteID, intDriverID )
)

-- --------------------------------------------------------------------------------
-- Step #2a Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------

--	Child				Parent				Column(s)
--	-----				------				---------
-- 1	TScheduledRoutes		TScheduledTimes			intScheduledTimeID
-- 2	TScheduledRoutes		TRoutes				intRouteID
-- 3	TScheduledRoutes		TBuses				intBusID
-- 4	TScheduledRouteDrivers		TScheduledRoutes		intScheduledTimeID, intRouteID
-- 5	TScheduledRouteDrivers		TDrivers			intDriverID
-- 6	TScheduledRouteDrivers		TDriverRoles			intDriverRoleID

-- 1
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TScheduledTimes_FK 
FOREIGN KEY ( intScheduledTimeID ) REFERENCES TScheduledTimes ( intScheduledTimeID )

-- 2
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TRoutes_FK 
FOREIGN KEY ( intRouteID ) REFERENCES TRoutes ( intRouteID )

-- 3
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TBuses_FK
FOREIGN KEY ( intBusID ) REFERENCES TBuses ( intBusID )

-- 4
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TScheduledRoutes_FK
FOREIGN KEY ( intScheduledTimeID, intRouteID ) REFERENCES TScheduledRoutes ( intScheduledTimeID, intRouteID )

-- 5
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDrivers_FK
FOREIGN KEY( intDriverID ) REFERENCES TDrivers ( intDriverID )

-- 6
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDriverRoles_FK
FOREIGN KEY( intDriverRoleID ) REFERENCES TDriverRoles ( intDriverRoleID )

-- --------------------------------------------------------------------------------
-- Step #2b Unique constraints for data integrity
-- --------------------------------------------------------------------------------
-- Don't allow the same bus to be scheduled more than once at the same time
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_intScheduledTimeID_intBusID
UNIQUE( intScheduledTimeID, intBusID )

-- Don't allow the same driver more than once at the same time
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_intScheduledTimeID_intDriverID
UNIQUE( intScheduledTimeID, intDriverID )

-- --------------------------------------------------------------------------------
-- Step #3 Insert data into all tables
-- --------------------------------------------------------------------------------
INSERT INTO TRoutes( intRouteID, strRoute, strRouteDescription )
VALUES	 ( 1, 'RT-56', 'Blue Ash to Anderson' )
	,( 2, 'RT-11', 'West Chester to Downtown' )
	,( 3, 'RT-7', 'Norwood to Cheviot' )
	,( 4, 'RT-21', 'Downtown to Springdale' )
	,( 5, 'RT-42', 'Liberty Township to Kenwood' )
	,( 6, 'RT-51', 'Anderson to Downtown' )
	,( 7, 'RT-85', 'Newport to Harrison' )

INSERT INTO TBuses( intBusID, strBus, intCapacity )
VALUES   ( 1, '21', 105 )
	,( 2, '104', 75 )
	,( 3, '78', 88 )
	,( 4, '44', 100 )
	,( 5, '11', 95 )

INSERT INTO TDrivers( intDriverID, strFirstName, strLastName, strPhoneNumber )
VALUES	 ( 1, 'Stanley', 'Lo', '513-111-1111' )
	,( 2, 'Bridget', 'Migrans','513-222-2222' )
	,( 3, 'James', 'Reilly', '513-333-3333' )
	,( 4, 'Kyra', 'Longhauser', '513-444-4444' )
	,( 5, 'Erik', 'Burnside', '513-555-5555' )

INSERT INTO TScheduledTimes( intScheduledTimeID, strScheduledTime )
VALUES   ( 1, '7am' )
	,( 2, '8am' )
	,( 3, '9am' )
	,( 4, '10am' )
	,( 5, '11am' )
	,( 6, '12pm' )
	,( 7, '1 pm' )

INSERT INTO TScheduledRoutes( intScheduledTimeID, intRouteID, intBusID )
VALUES	 ( 1, 1, 1 )
	,( 2, 2, 2 )
	,( 3, 3, 3 )
	,( 4, 4, 4 )
	,( 5, 5, 5 )

INSERT INTO TDriverRoles( intDriverRoleID, strDriverRole, intSortOrder )
VALUES   ( 1, 'primary', 1 )
	,( 2, 'backup1', 2 )
	,( 3, 'backup2', 3 )

INSERT INTO TScheduledRouteDrivers( intScheduledTimeID, intRouteID, intDriverID, intDriverRoleID )
VALUES   ( 1, 1, 1, 1 )
        ,( 1, 1, 2, 2 )
	,( 1, 1, 3, 3 )
	,( 2, 2, 2, 1 )
	,( 2, 2, 3, 2 )
	,( 2, 2, 4, 3 )
	,( 3, 3, 3, 1 )
	,( 3, 3, 4, 2 )
	,( 3, 3, 5, 3 )
	,( 4, 4, 4, 1 )
	,( 4, 4, 5, 2 )
	,( 4, 4, 1, 3 )
	,( 5, 5, 5, 1 )
	,( 5, 5, 1, 2 )
	,( 5, 5, 2, 3 )

-- --------------------------------------------------------------------------------
-- Step #4 uspEditRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditRoute
	 @intRouteID		AS INTEGER
	,@strRoute		AS VARCHAR(50)
	,@strRouteDescription	AS VARCHAR(50)
	,@rvLastUpdated		AS ROWVERSION
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @blnRaceConditionExists AS BIT = 1 -- Assume there is a race condition
 
-- Update the record but ...
UPDATE
	TRoutes
SET
	 strRoute = @strRoute
	,strRouteDescription = @strRouteDescription
WHERE
	intRouteID	= @intRouteID
AND	rvLastUpdated	= @rvLastUpdated -- ... only if it hasn't changed
 
-- Was the row updated?
IF @@ROWCOUNT = 1
 
	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0
 
-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

-- --------------------------------------------------------------------------------
-- Step #5 Call and test uspEditRoute
-- --------------------------------------------------------------------------------
GO 

DECLARE @strRoute		AS VARCHAR( 50 )
DECLARE @strRouteDescription	AS VARCHAR( 50 )
DECLARE @rvLastUpdated		AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strRoute            = strRoute
	,@strRouteDescription = strRouteDescription
	,@rvLastUpdated	      = rvLastUpdated
FROM
	TRoutes
WHERE
	intRouteID = 1	-- Hard code for curling/whatever team

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:03'
SELECT @strRouteDescription = 'Anderson to Blue Ash'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditRoute 1, @strRoute, @strRouteDescription, @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TRoutes WHERE intRouteID = 1	-- Verify change.

-- --------------------------------------------------------------------------------
-- Step #6 Call and test uspEditRoute with another copy of SSMS
-- --------------------------------------------------------------------------------
GO

DECLARE @strRoute		AS VARCHAR( 50 )
DECLARE @strRouteDescription	AS VARCHAR( 50 )
DECLARE @rvLastUpdated		AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strRoute		= strRoute
	,@strRouteDescription	= strRouteDescription
	,@rvLastUpdated		= rvLastUpdated
FROM
	TRoutes
WHERE
	intRouteID	= 1	-- Hard code for curling/whatever team

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:05'
SELECT @strRouteDescription = 'Anderson to Fort Mitchell'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditRoute 1, @strRoute, @strRouteDescription, @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TRoutes WHERE intRouteID = 1	-- Verify change.

-- --------------------------------------------------------------------------------
-- Step #7 uspEditDriver
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditDriver
	 @intDriverID		AS INTEGER
	,@strFirstName		AS VARCHAR(50)
	,@strLastName		AS VARCHAR(50)
	,@strPhoneNumber	AS VARCHAR(50)
	,@rvLastUpdated		AS ROWVERSION
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @blnRaceConditionExists AS BIT = 1 -- Assume there is a race condition
 
-- Update the record but ...
UPDATE
	TDrivers
SET
	 strFirstName 	= @strFirstName
	,strLastName	= @strLastName
	,strPhoneNumber	= @strPhoneNumber
WHERE
	intDriverID = @intDriverID
AND	rvLastUpdated = @rvLastUpdated -- ... only if it hasn't changed
 
-- Was the row updated?
IF @@ROWCOUNT = 1
 
	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0
 
-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

-- --------------------------------------------------------------------------------
-- Step #8 Call and test uspEditDriver
-- --------------------------------------------------------------------------------
GO

DECLARE @strFirstName	AS VARCHAR( 50 )
DECLARE @strLastName	AS VARCHAR( 50 )
DECLARE @strPhoneNumber	AS VARCHAR( 50 )
DECLARE @rvLastUpdated	AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strFirstName	 = strFirstName
	,@strLastName	 = strLastName
	,@strPhoneNumber = strPhoneNumber
	,@rvLastUpdated	 = rvLastUpdated
FROM
	TDrivers
WHERE
	intDriverID = 1	-- Hard code for curling/whatever team

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:03'
SELECT @strFirstName = 'Pham'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditDriver 1, @strFirstName, @strLastName, @strPhoneNumber, @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TDrivers WHERE intDriverID = 1	-- Verify change.

--------------------------------------------------------------------------------
-- Step #9 Call and test uspEditDriver with another copy of SSMS
--------------------------------------------------------------------------------
GO 

DECLARE @strFirstName		AS VARCHAR( 50 )
DECLARE @strLastName		AS VARCHAR( 50 )
DECLARE @strPhoneNumber		AS VARCHAR( 50 )
DECLARE @rvLastUpdated		AS ROWVERSION

-- Simulate loading data from database onto form
SELECT
	 @strFirstName	  = strFirstName
	,@strLastName	  = strLastName
	,@strPhoneNumber  = strPhoneNumber
	,@rvLastUpdated	  = rvLastUpdated
FROM
	TDrivers
WHERE
	intDriverID	= 1	-- Hard code for curling/whatever team

-- Simulate a delay during which the user would change the fields on the form
WAITFOR DELAY '00:00:05'	-- hh:mm:ss  change to whatever you need
SELECT @strFirstName = 'Zipp'

-- Simulate clicking OK on the edit form and attempt to save data by calling USP
EXECUTE uspEditDriver 1, @strFirstName, @strLastName, @strPhoneNumber, @rvLastUpdated

-- It should return 0 for blnRaceConditionExists and you should see that the record was updated
SELECT * FROM TDrivers WHERE intDriverID = 1	-- Verify change.

-- --------------------------------------------------------------------------------
-- Step #10 uspEditScheduledRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspEditScheduledRoute
	 @intOldScheduledTimeID	AS INTEGER
	,@intOldRouteID		AS INTEGER
	,@intNewScheduledTimeID	AS INTEGER
	,@intNewRouteID		AS INTEGER
	,@intBusID		AS INTEGER
	,@rvLastUpdated		AS ROWVERSION
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @blnRaceConditionExists AS BIT = 1 -- Assume there is a race condition
 
-- Update the record but ...
UPDATE
	TScheduledRoutes
SET
	 intScheduledTimeID = @intNewScheduledTimeID
	,intRouteID	    = @intNewRouteID
	,intBusID	    = @intBusID
WHERE
	intScheduledTimeID  = @intOldScheduledTimeID
    AND intRouteID	    = @intOldRouteID
    AND	rvLastUpdated       = @rvLastUpdated -- ... only if it hasn't changed
 
-- Was the row updated?
IF @@ROWCOUNT = 1
 
	-- Yes, the row has not been changed so no edit race condition exists
	SET @blnRaceConditionExists = 0
 
-- Let the caller know if there was a race condition or not
SELECT @blnRaceConditionExists AS blnRaceConditionExists

----------------------------------------------------------------------------------
--Step #11 Call and test uspEditScheduledRoute
----------------------------------------------------------------------------------
GO

DECLARE @rvLastUpdated AS ROWVERSION
SELECT
	@rvLastUpdated = rvLastUpdated
FROM
	TScheduledRoutes
WHERE
	intScheduledTimeID = 1
AND	intRouteID = 1

-- EXECUTE uspEditScheduledRoute 1, 1, 2, 1, 1, @rvLastUpdated	

-- --------------------------------------------------------------------------------
-- Step #12 Explain why step 11 failed.
-- --------------------------------------------------------------------------------
-- An UPDATE is considered a DELETE + an INSERT within a transaction.  TScheduledRoutes 
-- is a parent table with a child dependency (TScheduledRouteDrivers).  You cannot 
-- perform a DELETE on a parent table without first peforming the DELETE on the child
-- dependency.

-- --------------------------------------------------------------------------------
-- Step #13 uspMoveScheduledRoute: Move the old route to a new route if the new
--								   route doesn't already exist.
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspMoveScheduledRoute
	 @intOldScheduledTimeID		AS INTEGER
	,@intOldRouteID			AS INTEGER
	,@intNewScheduledTimeID		AS INTEGER
	,@intNewRouteID			AS INTEGER
	,@intBusID			AS INTEGER
	,@blnResult			AS BIT OUTPUT
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON	-- Terminate and rollback entire transaction on error
 
DECLARE @blnAlreadyExists AS BIT = 0 -- False, does not exist

BEGIN TRANSACTION
	-- Check to see if the scheduled route already exists.
	SELECT
		@blnAlreadyExists = 1
	FROM
		TScheduledRoutes (TABLOCKX) -- Lock table until end of transaction
	WHERE 
		intScheduledTimeID = @intNewScheduledTimeID
	    AND intRouteID	   = @intNewRouteID

	-- Does the scheduled route already exist?
	IF @blnAlreadyExists = 0
	BEGIN
		-- No...add the new route
		INSERT INTO TScheduledRoutes( intScheduledTimeID, intRouteID, intBusID )
		VALUES( @intNewScheduledTimeID, @intNewRouteID, @intBusID )

		-- Copy drivers from the old scheduled route
		INSERT INTO TScheduledRouteDrivers( intScheduledTimeID, intRouteID, intDriverID, intDriverRoleID )
		( 
			SELECT
				 @intNewScheduledTimeID
				,@intNewRouteID
				,intDriverID
				,intDriverRoleID
			FROM
				TScheduledRouteDrivers
			WHERE
				intScheduledTimeID  = @intOldScheduledTimeID
			    AND intRouteID	    = @intOldRouteID
		)

		-- Delete drivers from old scheduled route
		DELETE FROM TScheduledRouteDrivers
		WHERE 
			intScheduledTimeID = @intOldScheduledTimeID
		AND	intRouteID	   = @intOldRouteID

		-- Delete old scheduled route
		DELETE FROM TScheduledRoutes
		WHERE
			intScheduledTimeID = @intOldScheduledTimeID
		AND	intRouteID	   = @intOldRouteID

		-- Success
		SELECT @blnResult = 1
			
	END

COMMIT TRANSACTION

-- --------------------------------------------------------------------------------
-- Step #14 uspSuperEditScheduledRoute: Move the scheduled route if the old route
--					or time is different.  Otherwise, just update
--					the bus info.
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspSuperEditScheduledRoute
	 @intOldScheduledTimeID	AS INTEGER
	,@intOldRouteID		AS INTEGER
	,@intNewScheduledTimeID	AS INTEGER
	,@intNewRouteID		AS INTEGER
	,@intBusID		AS INTEGER
AS
SET NOCOUNT ON	-- Report only errors
SET XACT_ABORT ON -- Terminate and rollback entire transaction on error

DECLARE @blnResult AS BIT = 0 -- Assume failure
BEGIN TRANSACTION

	-- Do we need to move the route?
	IF @intOldScheduledTimeID   <> @intNewScheduledTimeID
	OR @intOldRouteID	    <> @intNewRouteID BEGIN

		-- Yes
		EXECUTE uspMoveScheduledRoute    @intOldScheduledTimeID, @intOldRouteID
						,@intNewScheduledTimeID, @intNewRouteID
						,@intBusID, @blnResult OUTPUT

	END 
	ELSE BEGIN

	-- No, just update the bus info
	UPDATE
		TScheduledRoutes
	SET 
		intBusID = @intBusID
	WHERE
		intScheduledTimeID = @intOldScheduledTimeID
	AND	intRouteID	   = @intOldRouteID

	-- Success
	SELECT @blnResult = 1

	END
	
	-- Let the calling procedure know what happened
	SELECT @blnResult AS blnResult

COMMIT TRANSACTION

GO

-- --------------------------------------------------------------------------------
-- Step #15 Call and test uspSuperEditScheduledRoute.
-- --------------------------------------------------------------------------------
EXECUTE uspSuperEditScheduledRoute 1, 1, 6, 6, 1

-- --------------------------------------------------------------------------------
-- Step #16 Call and test uspSuperEditScheduledRoute with bus changes only.
-- --------------------------------------------------------------------------------
EXECUTE uspSuperEditScheduledRoute 6, 6, 6, 6, 2

-- --------------------------------------------------------------------------------
-- Step #17 Call and test uspSuperEditScheduledRoute with bad data.
-- --------------------------------------------------------------------------------
GO

sp_Lock

GO

EXECUTE uspSuperEditScheduledRoute 6, 6, 100, 200, 2

GO

sp_Lock



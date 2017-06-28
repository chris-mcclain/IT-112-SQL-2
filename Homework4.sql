-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Homework 4 - Add Race Conditions
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
IF OBJECT_ID( 'TScheduledRoutes' )		IS NOT NULL DROP TABLE TScheduledRoutes
IF OBJECT_ID( 'TScheduledTimes' )		IS NOT NULL DROP TABLE TScheduledTimes
IF OBJECT_ID( 'TDriverRoles' )			IS NOT NULL DROP TABLE TDriverRoles
IF OBJECT_ID( 'TDrivers' )			IS NOT NULL DROP TABLE TDrivers
IF OBJECT_ID( 'TBuses' )			IS NOT NULL DROP TABLE TBuses
IF OBJECT_ID( 'TRoutes' )			IS NOT NULL DROP TABLE TRoutes

IF OBJECT_ID( 'uspAddRoute' )			IS NOT NULL DROP PROCEDURE uspAddRoute
IF OBJECT_ID( 'uspAddBus' )			IS NOT NULL DROP PROCEDURE uspAddBus
IF OBJECT_ID( 'uspAddDriver' )			IS NOT NULL DROP PROCEDURE uspAddDriver
IF OBJECT_ID( 'uspAddScheduledTime' )		IS NOT NULL DROP PROCEDURE uspAddScheduledTime
IF OBJECT_ID( 'uspAddDriverRole' )		IS NOT NULL DROP PROCEDURE uspAddDriverRole
IF OBJECT_ID( 'uspAddScheduledRoute' )		IS NOT NULL DROP PROCEDURE uspAddScheduledRoute
IF OBJECT_ID( 'uspAddScheduledRouteDriver' )	IS NOT NULL DROP PROCEDURE uspAddScheduledRouteDriver


-- --------------------------------------------------------------------------------
-- Step #1.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TRoutes
(
	 intRouteID		INTEGER					NOT NULL
	,strRoute		VARCHAR(50)				NOT NULL
	,strRouteDescription	VARCHAR(50)				NOT NULL
	,CONSTRAINT TRoutes_PK PRIMARY KEY ( intRouteID )
)

CREATE TABLE TBuses
(
	 intBusID		INTEGER					NOT NULL
	,strBus			VARCHAR(50)				NOT NULL
	,intCapacity		INTEGER					NOT NULL
	,CONSTRAINT TBuses_PK PRIMARY KEY ( intBusID )
)

CREATE TABLE TDrivers
(
	 intDriverID		INTEGER					NOT NULL
	,strFirstName		VARCHAR(50)				NOT NULL
	,strLastName		VARCHAR(50)				NOT NULL
	,strPhoneNumber		VARCHAR(50)				NOT NULL
	,CONSTRAINT TDrivers_PK PRIMARY KEY ( intDriverID )
)

CREATE TABLE TDriverRoles
(
	 intDriverRoleID	INTEGER					NOT NULL
	,strDriverRole		VARCHAR(50)				NOT NULL
	,intSortOrder		INTEGER					NOT NULL
	,CONSTRAINT TDriverRoles_PK PRIMARY KEY ( intDriverRoleID )
)

CREATE TABLE TScheduledTimes
(
	 intScheduledTimeID	INTEGER					NOT NULL
	,strScheduledTime	VARCHAR(50)				NOT NULL
	,CONSTRAINT TScheduledTimes_PK PRIMARY KEY ( intScheduledTimeID )
)

CREATE TABLE TScheduledRoutes
(
	 intScheduledTimeID	INTEGER					NOT NULL	
	,intRouteID		INTEGER					NOT NULL
	,intBusID		INTEGER					NOT NULL	
	,CONSTRAINT TScheduledRoutes_PK PRIMARY KEY ( intScheduledTimeID, intRouteID )
	,CONSTRAINT TScheduledRoutes_intScheduledTimeID_UN UNIQUE ( intScheduledTimeID )
	,CONSTRAINT TScheduledRoutes_intBusID_UN UNIQUE ( intBusID )
)

CREATE TABLE TScheduledRouteDrivers
(
	 intScheduledTimeID	INTEGER					NOT NULL
	,intRouteID		INTEGER					NOT NULL
	,intDriverID		INTEGER					NOT NULL
	,intDriverRoleID	INTEGER					NOT NULL
	,CONSTRAINT TScheduledRouteDrivers_PK PRIMARY KEY ( intScheduledTimeID, intRouteID, intDriverID )
	,CONSTRAINT TScheduledRouteDrivers_intScheduledTimeID_UN UNIQUE ( intScheduledTimeID )
	,CONSTRAINT TScheduledRouteDrivers_intDriverID_UN UNIQUE ( intDriverID )
)

-- --------------------------------------------------------------------------------
-- Step #1.2 - Identify and Create Foreign Keys
-- --------------------------------------------------------------------------------
--	Child				Parent				Column(s)
--	-----				------				---------
-- 1	TScheduledRoutes		TScheduledTimes			intScheduledTimeID
-- 2	TScheduledRoutes		TRoutes				intRouteID
-- 3	TScheduledRoutes		TBuses				intBusID
-- 4	TScheduledRouteDrivers		TScheduledRoutes		intScheduledTimeID, intRouteID
-- 5	TScheduledRouteDrivers		TDrivers			intDriverID
-- 6	TScheduledRouteDrivers		TDriverRoles			intDriverRoleID

--1
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TScheduledTimes_FK1
FOREIGN KEY ( intScheduledTimeID ) REFERENCES TScheduledTimes ( intScheduledTimeID )

--2
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TRoutes_FK1
FOREIGN KEY ( intRouteID ) REFERENCES TRoutes ( intRouteID )

--3
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_TBuses_FK1
FOREIGN KEY ( intBusID ) REFERENCES TBuses ( intBusID )

--4
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TScheduledRoutes_FK1
FOREIGN KEY ( intScheduledTimeID, intRouteID ) REFERENCES TScheduledRoutes ( intScheduledTimeID, intRouteID )

--5
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDrivers_FK1
FOREIGN KEY ( intDriverID ) REFERENCES TDrivers ( intDriverID )

--6
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_TDriverRoles_FK1
FOREIGN KEY ( intDriverRoleID ) REFERENCES TDriverRoles ( intDriverRoleID )


-- --------------------------------------------------------------------------------
-- Step #1.3 - uspAddRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddRoute
	 @strRoute	      AS VARCHAR(50)
	,@strRouteDescription AS VARCHAR(50)
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intRouteID AS INTEGER

BEGIN TRANSACTION
	
	SELECT @intRouteID = MAX( intRouteID ) + 1
	FROM TRoutes (TABLOCKX) -- Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intRouteID = COALESCE( @intRouteID, 1 )

	INSERT INTO TRoutes ( intRouteID, strRoute, strRouteDescription )
	VALUES ( @intRouteID, @strRoute, @strRouteDescription )

	--Return value to caller
	SELECT @intRouteID AS intRouteID

COMMIT TRANSACTION

GO

uspAddRoute 'R32', 'Kenwood -> Downtown'

GO

uspAddRoute 'R57', 'Florence -> Downtown'

GO

SELECT * FROM TRoutes

-- --------------------------------------------------------------------------------
-- Step #1.4 - uspAddBus
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddBus
	 @strBus     AS VARCHAR(50)
	,@intCapcity AS INTEGER
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intBusID AS INTEGER

BEGIN TRANSACTION
	
	SELECT @intBusID = MAX( intBusID ) + 1
	FROM TBuses (TABLOCKX) -- Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intBusID = COALESCE( @intBusID, 1 )

	INSERT INTO TBuses ( intBusID, strBus, intCapacity )
	VALUES ( @intBusID, @strBus, @intCapcity )

	--Return value to caller
	SELECT @intBusID AS intBusID

COMMIT TRANSACTION

GO

uspAddBus 'Bus A', 20

GO

uspAddBus 'Bus B', 25

GO

SELECT * FROM TBuses

-- --------------------------------------------------------------------------------
-- Step #1.5 - uspAddDriver
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddDriver
	 @strFirstName		AS VARCHAR(50)
	,@strLastName		AS VARCHAR(50)
	,@strPhoneNumber	AS VARCHAR(50)
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intDriverID AS INTEGER

BEGIN TRANSACTION
	
	SELECT @intDriverID = MAX( intDriverID ) + 1
	FROM TDrivers (TABLOCKX) -- Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intDriverID = COALESCE( @intDriverID, 1 )

	INSERT INTO TDrivers ( intDriverID, strFirstName, strLastName, strPhoneNumber )
	VALUES ( @intDriverID, @strFirstName, @strLastName, @strPhoneNumber )

	--Return value to caller
	SELECT @intDriverID AS intDriverID

COMMIT TRANSACTION

GO

uspAddDriver 'Simon', 'Simonson', '123-4567'

GO

uspAddDriver 'Gregory', 'Gregorson', '234-5678'

GO

SELECT * FROM TDrivers

-- --------------------------------------------------------------------------------
-- Step #1.6 - uspAddScheduledTime
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddScheduledTime
	 @strScheduledTime AS VARCHAR(50)
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intScheduledTimeID AS INTEGER

BEGIN TRANSACTION
	
	SELECT @intScheduledTimeID = MAX( intScheduledTimeID ) + 1
	FROM TScheduledTimes (TABLOCKX) -- Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intScheduledTimeID = COALESCE( @intScheduledTimeID, 1 )

	INSERT INTO TScheduledTimes( intScheduledTimeID, strScheduledTime )
	VALUES ( @intScheduledTimeID, @strScheduledTime )

	--Return value to caller
	SELECT @intScheduledTimeID AS intScheduledTimeID

COMMIT TRANSACTION

GO

uspAddScheduledTime '8 am'

GO

uspAddScheduledTime '10 am'

GO

uspAddScheduledTIme '12 pm'

Go

uspAddScheduledTime '2 pm'

GO

SELECT * FROM TScheduledTimes

-- --------------------------------------------------------------------------------
-- Step #1.7 - uspAddDriverRole
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddDriverRole
	  @strDriverRole AS VARCHAR(50)
	 ,@intSortOrder	 AS INTEGER
AS
SET NOCOUNT ON  --Report only errors
SET XACT_ABORT ON  --Terminate and rollback entire transaction on error

DECLARE @intDriverRoleID AS INTEGER

BEGIN TRANSACTION
	
	SELECT @intDriverRoleID = MAX( intDriverRoleID ) + 1
	FROM TDriverRoles (TABLOCKX) -- Lock table until end of transaction

	--Default to 1 if table is empty
	SELECT @intDriverRoleID = COALESCE( @intDriverRoleID, 1 )

	INSERT INTO TDriverRoles( intDriverRoleID, strDriverRole, intSortOrder )
	VALUES ( @intDriverRoleID, @strDriverRole, @intSortOrder )

	--Return value to caller
	SELECT @intDriverRoleID AS intDriverRoleID

COMMIT TRANSACTION

GO

uspAddDriverRole 'Primary', 1

GO

uspAddDriverRole 'Backup #1', 2

GO

uspAddDriverRole 'Backup #2', 3

GO

SELECT * FROM TDriverRoles ORDER BY intSortOrder

-- --------------------------------------------------------------------------------
-- Step #1.8 - uspAddScheduledRoute
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddScheduledRoute
	 @intScheduledTimeID	AS INTEGER
	,@intRouteID		AS INTEGER
	,@intBusID		AS INTEGER
AS 
SET NOCOUNT ON		--Report only errors
SET XACT_ABORT ON	--Terminate and rollback entire transaction on error

DECLARE @blnAlreadyExists AS BIT = 0  --False, does not exist

BEGIN TRANSACTION

	SELECT
		@blnAlreadyExists = 1
	FROM
		TScheduledRoutes (TABLOCKX) --Lock table  until end of transaction
	WHERE	intScheduledTimeID =	@intScheduledTimeID
	AND	intRouteID 	   =	@intRouteID

	IF @blnAlreadyExists = 0
	BEGIN
		
		INSERT INTO TScheduledRoutes ( intScheduledTimeID, intRouteID, intBusID )
		VALUES ( @intScheduledTimeID, @intRouteID, @intBusID )

	END

COMMIT TRANSACTION

GO

uspAddScheduledRoute 1, 1, 1

GO

uspAddScheduledRoute 2, 2, 2

GO

SELECT * FROM TScheduledRoutes
		
-- --------------------------------------------------------------------------------
-- Step #1.9 - uspAddScheduledRouteDriver
-- --------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspAddScheduledRouteDriver
	 @intScheduledTimeID	AS INTEGER
	,@intRouteID		AS INTEGER
	,@intDriverID		AS INTEGER
	,@intDriverRoleID	AS INTEGER
AS 
SET NOCOUNT ON	--Report only errors
SET XACT_ABORT ON --Terminate and rollback entire transaction on error

DECLARE @blnAlreadyExists AS BIT = 0  --False, does not exist

BEGIN TRANSACTION

	SELECT
		@blnAlreadyExists = 1
	FROM
		TScheduledRouteDrivers (TABLOCKX) --Lock table  until end of transaction
	WHERE	intScheduledTimeID = @intScheduledTimeID
	AND	intRouteID	   = @intRouteID
	AND	intDriverID	   = @intDriverID

	IF @blnAlreadyExists = 0
	BEGIN
		
		INSERT INTO TScheduledRouteDrivers ( intScheduledTimeID, intRouteID, intDriverID, intDriverRoleID )
		VALUES ( @intScheduledTimeID, @intRouteID, @intDriverID, @intDriverRoleID )

	END

COMMIT TRANSACTION

GO

uspAddScheduledRouteDriver 1, 1, 1, 1

GO

uspAddScheduledRouteDriver 1, 1, 1, 2

GO

uspAddScheduledRouteDriver 2, 2, 2, 2

GO

uspAddScheduledRouteDriver 2, 2, 2, 1

GO

SELECT * FROM TScheduledRouteDrivers

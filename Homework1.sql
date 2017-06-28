-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: IT112-401: SQL #2
-- Abstract: Homework 1 - Review of SQL #1
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop View and Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'VScheduledRoutes' )		IS NOT NULL DROP VIEW VScheduledRoutes
IF OBJECT_ID( 'TScheduledRouteDrivers' )	IS NOT NULL DROP TABLE TScheduledRouteDrivers
IF OBJECT_ID( 'TDriverRoles' )			IS NOT NULL DROP TABLE TDriverRoles
IF OBJECT_ID( 'TScheduledRoutes' )		IS NOT NULL DROP TABLE TScheduledRoutes
IF OBJECT_ID( 'TScheduledTimes' )		IS NOT NULL DROP TABLE TScheduledTimes
IF OBJECT_ID( 'TDrivers' )			IS NOT NULL DROP TABLE TDrivers
IF OBJECT_ID( 'TBuses' )			IS NOT NULL DROP TABLE TBuses
IF OBJECT_ID( 'TRoutes' )			IS NOT NULL DROP TABLE TRoutes

-- --------------------------------------------------------------------------------
-- Step #1: Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TRoutes
(
	 intRouteID 		INTEGER			NOT NULL
	,strRoute		VARCHAR(50)		NOT NULL
	,strRouteDescription	VARCHAR(50)		NOT NULL
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
	,strMiddleName		VARCHAR(50)		NOT NULL
	,strLastName		VARCHAR(50)		NOT NULL
	,strAddress		VARCHAR(50)		NOT NULL
	,strCity		VARCHAR(50)		NOT NULL
	,strState		VARCHAR(50)		NOT NULL
	,strZipCode		VARCHAR(50)		NOT NULL
	,strPhoneNumber		VARCHAR(50)		NOT NULL
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
-- Step #2A/B Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------

--	Child				Parent				Column(s)
--	-----				------				---------
-- 1	TScheduledRoutes		TScheduledTimes			intScheduledTimeID
-- 2	TScheduledRoutes		TRoutes				intRouteID
-- 3	TScheduledRoutes		TBuses				intBusID
-- 4	TScheduledRouteDrivers	        TScheduledRoutes		intScheduledTimeID, intRouteID
-- 5	TScheduledRouteDrivers	        TDrivers			intDriverID
-- 6	TScheduledRouteDrivers	        TDriverRoles			intDriverRoleID

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
-- Step #3 Unique constraints for data integrity
-- --------------------------------------------------------------------------------
-- Don't allow the same bus to be scheduled more than once at the same time
ALTER TABLE TScheduledRoutes ADD CONSTRAINT TScheduledRoutes_intScheduledTimeID_intBus
UNIQUE( intScheduledTimeID, intBusID )

-- Don't allow the same driver more than once at the same time
ALTER TABLE TScheduledRouteDrivers ADD CONSTRAINT TScheduledRouteDrivers_intScheduledTimeID_intDriverID
UNIQUE( intScheduledTimeID, intDriverID )

-- --------------------------------------------------------------------------------
-- Step #4 Insert data into all tables
-- --------------------------------------------------------------------------------
INSERT INTO TRoutes( intRouteID, strRoute, strRouteDescription )
VALUES	 ( 1, 'RT-56', 'Blue Ash to Anderson' )
	,( 2, 'RT-11', 'West Chester to Downtown' )
	,( 3, 'RT-7', 'Norwood to Cheviot' )
	,( 4, 'RT-21', 'Downtown to Springdale' )
	,( 5, 'RT-42', 'Liberty Township to Kenwood' )

INSERT INTO TBuses( intBusID, strBus, intCapacity )
VALUES   ( 1, '21', 105 )
	,( 2, '104', 75 )
	,( 3, '78', 88 )
	,( 4, '44', 100 )
	,( 5, '11', 95 )

INSERT INTO TDrivers( intDriverID, strFirstName, strMiddleName, strLastName, strAddress, strCity, strState, strZipCode, strPhoneNumber )
VALUES	 ( 1, 'Stanley', 'Lee', 'Lo', '4578 Middleberg Lane', 'Blue Ash', 'Ohio', '45242', '513-111-1111' )
	,( 2, 'Bridget', 'Hope', 'Migrans', '7788 Selkirk Avenue', 'Anderson', 'Ohio', '45244', '513-222-2222' )
	,( 3, 'James', 'Patrick', 'Reilly', '121 Austere Lane', 'West Chester', 'Ohio', '45069', '513-333-3333' )
	,( 4, 'Kyra', 'Ann', 'Longhauser', '777 Yarmark Drive', 'Mason', 'Ohio', '45040', '513-444-4444' )
	,( 5, 'Erik', 'George', 'Burnside', '1245 Foxtrot Lane', 'West Chester', 'Ohio', '45069', '513-555-5555' )

INSERT INTO TScheduledTimes( intScheduledTimeID, strScheduledTime )
VALUES   ( 1, '7am' )
	,( 2, '8am' )
	,( 3, '9am' )
	,( 4, '10am' )
	,( 5, '11am' )

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
-- Step #4 Create the VScheduledRoutes View
-- --------------------------------------------------------------------------------
GO

CREATE VIEW VScheduledRoutes
AS
SELECT
	 TST.intScheduledTimeID
	,TST.strScheduledTime
	,TR.intRouteID
	,TR.strRoute
	,TR.strRouteDescription
	,TB.intBusID
	,TB.strBus
	,TD.intDriverID
	,TD.strFirstName
		+ ' ' 
		+ TD.strLastName AS Driver
	,TDR.intDriverRoleID
	,TDR.strDriverRole
FROM
	 TScheduledRoutes AS TSR
		INNER JOIN TScheduledTimes AS TST
		ON( TSR.intScheduledTimeID = TST.intScheduledTimeID )

		INNER JOIN TRoutes AS TR
		ON( TSR.intRouteID = TR.intRouteID )

		INNER JOIN TBuses AS TB
		ON( TSR.intBusID = TB.intBusID )

		INNER JOIN TScheduledRouteDrivers AS TSRD
			INNER JOIN TDrivers AS TD
			ON( TSRD.intDriverID = TD.intDriverID )

			INNER JOIN TDriverRoles AS TDR
			ON( TSRD.intDriverRoleID = TDR.intDriverRoleID )

		ON( TSR.intScheduledTimeID = TSRD.intScheduledTimeID 
		AND TSR.intRouteID = TSRD.intRouteID )
				
GO

SELECT * 
FROM VScheduledRoutes
ORDER BY intRouteID, intDriverRoleID

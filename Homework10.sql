-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Homework 10 - Unions, Triggers, and Cursors...oh my!
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TUserFavoriteSongs' )		IS NOT NULL DROP TABLE TUserFavoriteSongs
IF OBJECT_ID( 'TUsers' )			IS NOT NULL DROP TABLE TUsers
IF OBJECT_ID( 'TSongs' )			IS NOT NULL DROP TABLE TSongs
IF OBJECT_ID( 'TGenres' )			IS NOT NULL DROP TABLE TGenres

IF OBJECT_ID( 'TCourseStudents' )		IS NOT NULL DROP TABLE TCourseStudents
IF OBJECT_ID( 'TGrades' )			IS NOT NULL DROP TABLE TGrades
IF OBJECT_ID( 'TStudents' )			IS NOT NULL DROP TABLE TStudents
IF OBJECT_ID( 'TMajors' )			IS NOT NULL DROP TABLE TMajors
IF OBJECT_ID( 'TCourses' )			IS NOT NULL DROP TABLE TCourses
IF OBJECT_ID( 'TRooms' )			IS NOT NULL DROP TABLE TRooms
IF OBJECT_ID( 'TInstructors' )			IS NOT NULL DROP TABLE TInstructors
IF OBJECT_ID( 'TCourseStudentChangeLogs' )	IS NOT NULL DROP TABLE TCourseStudentChangeLogs

IF OBJECT_ID( 'uspDropUserForeignKeys' )	IS NOT NULL DROP PROCEDURE uspDropUserForeignKeys
IF OBJECT_ID( 'uspDropUserViews' )		IS NOT NULL DROP PROCEDURE uspDropUserViews
IF OBJECT_ID( 'uspDropUserTables' )		IS NOT NULL DROP PROCEDURE uspDropUserTables
IF OBJECT_ID( 'uspDropUserStoredProcedures' )	IS NOT NULL DROP PROCEDURE uspDropUserStoredProcedures
IF OBJECT_ID( 'uspCleanDatabase' )		IS NOT NULL DROP PROCEDURE uspCleanDatabase

-- --------------------------------------------------------------------------------
-- Step 1.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TUsers 
(
	 intUserID				INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,CONSTRAINT TUsers_PK PRIMARY KEY ( intUserID )
)

CREATE TABLE TSongs
(
	 intSongID				INTEGER							NOT NULL
	,strSong				VARCHAR(50)						NOT NULL
	,strArtist				VARCHAR(50)						NOT NULL
	,intGenreID				INTEGER							NOT NULL
	,CONSTRAINT TSongs_PK PRIMARY KEY ( intSongID )
)

CREATE TABLE TGenres
(
	 intGenreID				INTEGER							NOT NULL
	,strGenre				VARCHAR(50)						NOT NULL
	,CONSTRAINT TGenres_PK PRIMARY KEY ( intGenreID )
)

CREATE TABLE TUserFavoriteSongs
(	
	 intUserID				INTEGER							NOT NULL
	,intSongID				INTEGER							NOT NULL
	,intSortOrder				INTEGER							NOT NULL
	,CONSTRAINT TUserFavoriteSongs_PK PRIMARY KEY ( intUserID, intSongID )			
)

-- --------------------------------------------------------------------------------
-- Step #1.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--	Child					Parent					Column(s)
--	-----					------					---------
-- 1	TUserFavoriteSongs			TUsers					intUserID
-- 2	TUserFavoriteSongs			TSongs					intSongID
-- 3	TSongs					TGenres					intGenreID

--1
ALTER TABLE TUserFavoriteSongs ADD CONSTRAINT TUserFavoriteSongs_TUsers_FK
FOREIGN KEY ( intUserID ) REFERENCES TUsers ( intUserID )

--2
ALTER TABLE TUserFavoriteSongs ADD CONSTRAINT TUserFavoriteSongs_TSongs_FK
FOREIGN KEY ( intSongID ) REFERENCES TSongs ( intSongID )

--3
ALTER TABLE TSongs ADD CONSTRAINT TSongs_TGenres_FK
FOREIGN KEY ( intGenreID ) REFERENCES TGenres ( intGenreID )

-- --------------------------------------------------------------------------------
-- Step #1.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TUsers ( intUserID, strFirstName, strLastName )
VALUES   ( 1, 'Mary', 'Braun' )
	,( 2, 'James', 'Jamison' )
	,( 3, 'Longwind', 'Sparklepants' )
	,( 4, 'Maris', 'Marquette' )
	,( 5, 'Brandon', 'Brandywine' )

INSERT INTO TGenres ( intGenreID, strGenre )
VALUES	 ( 1, 'Punk' )
	,( 2, 'Hardcore' )
	,( 3, '80''s Alternative' )
	,( 4, 'Heavy Metal' )

INSERT INTO TSongs ( intSongID, strSong, strArtist, intGenreID )
VALUES   ( 1, 'Give Me Fire', 'GBH', 1 )
	,( 2, 'Never Let Me Down Again', 'Depeche Mode', 3 )
	,( 3, 'United and Strong', 'Agnostic Front', 2 )
	,( 4, 'World Eater', 'Bolt Thrower', 4 )
	,( 5, 'Punk''s Not Dead', 'The Exploited', 1 )
	,( 6, 'How Soon is Now', 'The Smiths', 3 )
	,( 7, 'You Suffer', 'Napalm Death', 4 )
	,( 8, 'Birds Fly (Whisper to a Scream)', 'The Icicle Works', 3 )

INSERT INTO TUserFavoriteSongs ( intUserID, intSongID, intSortOrder )
VALUES   ( 1, 2, 1 )
	,( 1, 8, 2 )
	,( 1, 3, 3 )
	,( 2, 3, 1 )
	,( 2, 4, 2 )
	,( 2, 5, 3 )
	,( 2, 6, 4 )
	,( 3, 1, 1 )
	,( 3, 2, 2 )
	,( 3, 3, 3 )
	,( 3, 6, 4 )
	,( 3, 8, 5 )
	,( 3, 7, 6 )
	,( 4, 4, 1 )
	,( 4, 2, 2 )
	,( 4, 8, 3 )
	,( 4, 6, 4 )
	,( 5, 3, 1 )
	,( 5, 8, 2 )
	,( 5, 2, 3 )
	,( 5, 1, 4 )

-- --------------------------------------------------------------------------------
-- Step 1.4 - Write a SELECT statement with at least 2 conditions linked with the 
--            logical OR operator.  
-- --------------------------------------------------------------------------------
SELECT 
	 TS.intSongID
	,TS.strSong
	,TG.intGenreID
	,TG.strGenre
FROM 
	 TSongs AS TS
		INNER JOIN TGenres AS TG
		ON TS.intGenreID = TG.intGenreID
WHERE
	TG.intGenreID = 1
 OR	TG.intGenreID = 2

 -- --------------------------------------------------------------------------------
-- Step 1.5 - Split the single SELECT statement from the previous step at the OR 
--	          operator into two separate SELECT statements and combine with the 
--            UNION operator
-- ---------------------------------------------------------------------------------
SELECT 
	 TS.intSongID
	,TS.strSong
	,TG.intGenreID
	,TG.strGenre
FROM 
	 TSongs AS TS
		INNER JOIN TGenres AS TG
		ON TS.intGenreID = TG.intGenreID
WHERE
	TG.intGenreID = 1

UNION

SELECT 
	 TS.intSongID
	,TS.strSong
	,TG.intGenreID
	,TG.strGenre
FROM 
	 TSongs AS TS
		INNER JOIN TGenres AS TG
		ON TS.intGenreID = TG.intGenreID
WHERE
	TG.intGenreID = 2

-- --------------------------------------------------------------------------------
-- Step 2.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TInstructors
(
	 intInstructorID			INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,CONSTRAINT TInstructors_PK PRIMARY KEY ( intInstructorID )
)

CREATE TABLE TRooms
(
	 intRoomID				INTEGER							NOT NULL
	,strRoomNumber				VARCHAR(50)						NOT NULL
	,intCapacity				INTEGER							NOT NULL
	,CONSTRAINT TRooms_PK PRIMARY KEY ( intRoomID )
)

CREATE TABLE TCourses
(
	 intCourseID				INTEGER							NOT NULL
	,strCourse				VARCHAR(50)						NOT NULL
	,strDescription				VARCHAR(50)						NOT NULL
	,intInstructorID			INTEGER							NOT NULL
	,intRoomID				INTEGER							NOT NULL
	,strMeetingTimes			VARCHAR(50)						NOT NULL
	,decCreditHours				DECIMAL(16,2)						NOT NULL
	,CONSTRAINT TCourses_PK PRIMARY KEY ( intCourseID )				
)

CREATE TABLE TMajors
(
	 intMajorID				INTEGER							NOT NULL
	,strMajor				VARCHAR(50)						NOT NULL
	,CONSTRAINT TMajors_PK PRIMARY KEY ( intMajorID )
)

CREATE TABLE TStudents
(
	 intStudentID				INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,intMajorID				INTEGER							NOT NULL
	,CONSTRAINT TStudents_PK PRIMARY KEY ( intStudentID )
)

CREATE TABLE TGrades
(
	 intGradeID				INTEGER							NOT NULL
	,strGradeLetter				VARCHAR(50)						NOT NULL
	,decGradePointValue			DECIMAL(16, 2)						NOT NULL
	,CONSTRAINT TGrades_PK PRIMARY KEY ( intGradeID )
)

CREATE TABLE TCourseStudents
(
	 intCourseID				INTEGER							NOT NULL
	,intStudentID				INTEGER							NOT NULL
	,intGradeID				INTEGER							NOT NULL
	,CONSTRAINT TCourseStudents_PK PRIMARY KEY ( intCourseID, intStudentID )
)

-- --------------------------------------------------------------------------------
-- Step #2.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--	Child					Parent					Column(s)
--	-----					------					---------
-- 1	TCourses				TInstructors				intInstructorID
-- 2	TCourses				TRooms					intRoomID
-- 3	TStudents				TMajors					intMajorID
-- 4	TCourseStudents				TCourses				intCourseID
-- 5	TCourseStudents				TStudents				intStudentID
-- 6	TCourseStudents				TGrades					intGradeID

-- 1
ALTER TABLE TCourses ADD CONSTRAINT TCourses_TInstructors_FK
FOREIGN KEY ( intInstructorID ) REFERENCES TInstructors ( intInstructorID )

-- 2
ALTER TABLE TCourses ADD CONSTRAINT TCourses_TRooms_FK
FOREIGN KEY ( intRoomID ) REFERENCES TRooms ( intRoomID )

-- 3
ALTER TABLE TStudents ADD CONSTRAINT TStudents_TMajors_FK
FOREIGN KEY ( intMajorID ) REFERENCES TMajors ( intMajorID )

-- 4
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TCourses_FK
FOREIGN KEY ( intCourseID ) REFERENCES TCourses ( intCourseID )

-- 5
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TStudents_FK
FOREIGN KEY ( intStudentID ) REFERENCES TStudents ( intStudentID )

-- 6
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TGrades_FK
FOREIGN KEY ( intGradeID ) REFERENCES TGrades ( intGradeID )

-- --------------------------------------------------------------------------------
-- Step #2.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TInstructors ( intInstructorID, strFirstName, strLastName )
VALUES   ( 1, 'Nigel', 'Stringtheory' )
	,( 2, 'Tatum', 'Hadroncollider' )
	,( 3, 'Sebastian', 'Beryllium' )
	,( 4, 'Erich', 'Hadoop' )

INSERT INTO TRooms ( intRoomID, strRoomNumber, intCapacity )
VALUES   ( 1, '407', 10 )
	,( 2, '222', 5 )
	,( 3, '820', 56 )
	,( 4, '333', 4 ) 

INSERT INTO TCourses ( intCourseID, strCourse, strDescription, intInstructorID, intRoomID,
                       strMeetingTimes, decCreditHours )
VALUES   ( 1, 'Philosophy 203', 'The Why of Quantum Jelly Beans', 1, 1, 'M/W: 2pm - 4pm', 3 )
	,( 2, 'Biology 459', 'Fun with Microtubules', 2, 2, 'T: 10am - 12pm', 2 )
	,( 3, 'Chemistry 350', 'Essential Apoptosis', 3, 3, 'T/R: 11am - 1pm', 4 )
	,( 4, 'Chemistry 678', 'Redox Revisited', 4, 4, 'M/W/F: 8am - 9am', 3 )

INSERT INTO TMajors ( intMajorID, strMajor )
VALUES	 ( 1, 'Computer Science' )
	,( 2, 'Accounting' )
	,( 3, 'Microbiology' )
	,( 4, 'Nursing' )
	,( 5, 'Physics' )
	,( 6, 'Chemistry' )


INSERT INTO TStudents ( intStudentID, strFirstName, strLastName, intMajorID )
VALUES   ( 1, 'Melissa', 'Cobol', 1 )
	,( 2, 'Farhad', 'Smalltalk', 2 )
	,( 3, 'Alistair', 'Matlab', 3 )
	,( 4, 'Cecily', 'Clojure', 4 )
	,( 5, 'Graham', 'Cracker', 5 )
	,( 6, 'Julie', 'Venow', 6 )
	,( 7, 'Karl', 'Withakay', 1 )
	,( 8, 'Sunshine', 'Day', 2 )
	,( 9, 'Hugh', 'Holly', 3 )
	,( 10, 'Christmas', 'Lane', 4 )
	,( 11, 'Heidi', 'Hoelle', 5 )

INSERT INTO TGrades ( intGradeID, strGradeLetter, decGradePointValue )
VALUES   ( 1, 'A', 4.0 )
	,( 2, 'B', 3.0 )
	,( 3, 'C', 2.0 )
	,( 4, 'D', 1.0 )
	,( 5, 'F', 0.0 )
	,( 6, 'S', 4.0 )
	,( 7, 'N', 0.0 )
	,( 8, 'I', 0.0 )
	,( 9, 'W', 0.0 )

INSERT INTO TCourseStudents ( intCourseID, intStudentID, intGradeID )
VALUES   ( 1, 3, 3 ) 
	,( 1, 4, 1 )
	,( 1, 1, 2 )
	,( 1, 7, 4 )
	,( 1, 8, 1 )
	,( 1, 10, 6 )
	,( 1, 5, 8 )
	,( 1, 6, 5 )
	,( 1, 9, 7 )
	,( 1, 11, 9 )
	,( 2, 1, 2 )
	,( 2, 4, 7 )
	,( 2, 3, 1 )
	,( 2, 10, 2 )
	,( 4, 1, 4 )
	,( 4, 3, 1 )
	,( 4, 4, 5 )
	,( 4, 8, 1 )
	,( 4, 10, 6 )

-- --------------------------------------------------------------------------------
-- Step #2.4 Create a history/log table for TCourseStudents (TCS) named 
--           TCourseStudentChangeLogs (TCSCL).  Use the same columns as the TCS but
--           add in an intChangeIndex and make it part of the primary key.  Also
--           add dtmChangedDate and strChangedBy columns.
-- --------------------------------------------------------------------------------
CREATE TABLE TCourseStudentChangeLogs
(
	 intCourseID				INTEGER							NOT NULL
	,intStudentID				INTEGER							NOT NULL
	,intChangeIndex				INTEGER							NOT NULL
	,dtmChangedDate				DATETIME						NOT NULL
	,strChangedBy				VARCHAR(50)						NOT NULL
	,intGradeID				INTEGER							NOT NULL
	,CONSTRAINT TCourseStudentChangeLogs_PK PRIMARY KEY ( intCourseID, intStudentID, intChangeIndex )
)

-- --------------------------------------------------------------------------------
-- Step #2.5 Create a trigger for UPDATE on the TCS table.  The trigger should
--           record any changes made to the TCS table in the TCSCL table.
-- --------------------------------------------------------------------------------
GO

CREATE TRIGGER tgrTCourseStudents_Update
ON TCourseStudents AFTER UPDATE
AS
SET NOCOUNT ON  -- Report only errors
SET XACT_ABORT ON  -- Terminate and rollback entire transaction on error

DECLARE @dtmChangedDate	AS DATETIME
DECLARE @strChangedBy	AS VARCHAR(50)

BEGIN TRANSACTION

-- Date Changed
SELECT @dtmChangedDate = GETDATE( )

-- Changed By
SELECT @strChangedBy = CURRENT_USER

-- Add record to history table
INSERT INTO TCourseStudentChangeLogs
(
	 intCourseID
	,intStudentID
	,intChangeIndex
	,dtmChangedDate
	,strChangedBy
	,intGradeID
)
SELECT
	 intCourseID
	,intStudentID
	-- Must use subquery with cross-query join because ALL
	-- updated records are in the DELETED table.
	,(
		SELECT ISNULL( MAX( intChangeIndex ) + 1, 1 )
		FROM TCourseStudentChangeLogs AS TCSCL (TABLOCKX)
		WHERE  TCSCL.intCourseID = DELETED.intCourseID 
		   AND TCSCL.intStudentID = DELETED.intStudentID
	)
	,@dtmChangedDate
	,@strChangedBy
	,intGradeID
FROM
	DELETED

COMMIT TRANSACTION

GO

-- --------------------------------------------------------------------------------
-- Step #2.6 Update a single record in the TCS table.  Make sure the change is
--           recorded correctly.
-- --------------------------------------------------------------------------------
UPDATE
	TCourseStudents
SET
	intGradeID = 2
WHERE
	 intCourseID  = 1
     AND intStudentID = 3

SELECT
	*
FROM
	TCourseStudents
WHERE  
	 intCourseID  = 1
     AND intStudentID = 3

SELECT 
	* 
FROM 
	TCourseStudentChangeLogs

-- --------------------------------------------------------------------------------
-- Step #2.7 Update at least two records with the same update statement in the TCS
--           and make sure all the changes are recorded correctly.
-- ---------------------------------------------------------------------------------
UPDATE
	TCourseStudents
SET
	intGradeID = 9
WHERE
	intStudentID = 1

SELECT 
	* 
FROM 
	TCourseStudents
WHERE
	intStudentID = 1

SELECT 
	* 
FROM 
	TCourseStudentChangeLogs
ORDER BY
	dtmChangedDate

-- ---------------------------------------------------------------------------------
-- Step #3.1 Using cursors, create a stored procedure named uspDropForeignKeys that
--           will drop all foreign keys in the current database. 
-- ---------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspDropUserForeignKeys
AS
SET NOCOUNT ON
DECLARE @strMessage		VARCHAR(250)
DECLARE @strForeignKey		VARCHAR(250)
DECLARE @strChildTable		VARCHAR(250)
DECLARE @strCommand		VARCHAR(250)
DECLARE @chrTab			CHAR = CHAR(9)

------------------------------Drop all user foreign keys-----------------------------
PRINT @chrTab + 'DROP ALL USER FOREIGN KEYS ...'

DECLARE crsForeignKeys CURSOR FOR
SELECT
	 name				AS strForeignKey
	,OBJECT_NAME( parent_obj )	AS strChildTable

FROM
	SysObjects
WHERE
		    type	=	'F'		/* Foreign Keys Only */
	AND (		
		    name	LIKE	'%_FK'
		OR  name	LIKE	'%_FK_'
	    )
	AND OBJECT_NAME( parent_obj ) LIKE	'T%'
ORDER BY
	name

OPEN crsForeignKeys
FETCH NEXT FROM crsForeignKeys INTO @strForeignKey, @strChildTable

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @strMessage = @chrTab + @chrTab + '-DROP ' + @strForeignKey
	PRINT @strMessage

	-- Build command
	SELECT @strCommand = 'ALTER TABLE ' + @strChildTable + ' DROP CONSTRAINT ' + @strForeignKey

	-- Execute command
	EXEC( @strCommand )

	FETCH NEXT FROM crsForeignKeys INTO @strForeignKey, @strChildTable

END

-- Clean up
CLOSE crsForeignKeys
DEALLOCATE crsForeignKeys

PRINT @chrTab + 'DONE'

GO
	
--uspDropUserForeignKeys
		
-- ---------------------------------------------------------------------------------
-- Step #3.2 Using cursors, create a stored procedure named uspDropUserViews that
--           will drop all user views in the current database. 
-- ---------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspDropUserViews
AS
SET NOCOUNT ON

DECLARE @strMessage		VARCHAR(250)
DECLARE @strUserView		VARCHAR(250)
DECLARE @strCommand		VARCHAR(250)
DECLARE @chrTab			CHAR = CHAR(9)

------------------------------Drop all user views-----------------------------------
PRINT @chrTab + 'DROP ALL USER VIEWS ...'

DECLARE crsUserViews CURSOR FOR
SELECT
	name AS strUserView
FROM
	SysObjects
WHERE
		type	=	'V'     /* Views Only */
	AND	name	LIKE	'V%' 
ORDER BY
	name

OPEN crsUserViews
FETCH NEXT FROM crsUserViews INTO @strUserView

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @strMessage = @chrTab + @chrTab + '-DROP ' + @strUserView
	PRINT @strMessage

	-- Build command
	SELECT @strCommand = 'DROP VIEW ' + @strUserView

	-- Execute command
	EXEC( @strCommand )

	FETCH NEXT FROM crsUserViews INTO @strUserView

END

-- Clean up
CLOSE crsUserViews
DEALLOCATE crsUserViews

PRINT @chrTab + 'DONE'

GO

--uspDropUserViews

-- ---------------------------------------------------------------------------------
-- Step #3.3 Using cursors, create a stored procedure named uspDropUserTables that
--           will drop all user tables in the current database. 
-- ---------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspDropUserTables
AS
SET NOCOUNT ON

DECLARE @strMessage		VARCHAR(250)
DECLARE @strUserTable		VARCHAR(250)
DECLARE @strCommand		VARCHAR(250)
DECLARE @chrTab			CHAR = CHAR(9)

------------------------------Drop all user tables-----------------------------------
PRINT @chrTab + 'DROP ALL USER TABLES ...'

DECLARE crsUserTables CURSOR FOR
SELECT
	name AS strUserTable
FROM
	SysObjects
WHERE
		type	=	'U'     /* User Tables Only */
	AND	name	LIKE	'T%' 
ORDER BY
	name

OPEN crsUserTables
FETCH NEXT FROM crsUserTables INTO @strUserTable

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @strMessage = @chrTab + @chrTab + '-DROP ' + @strUserTable
	PRINT @strMessage

	-- Build command
	SELECT @strCommand = 'DROP TABLE ' + @strUserTable

	-- Execute command
	EXEC( @strCommand )

	FETCH NEXT FROM crsUserTables INTO @strUserTable

END

-- Clean up
CLOSE crsUserTables
DEALLOCATE crsUserTables

PRINT @chrTab + 'DONE'

GO

--uspDropUserTables

-- ---------------------------------------------------------------------------------
-- Step #3.4 Extra Credit: Using cursors, create a stored procedure named 
--                         uspDropUserStoredProcedures that will drop all user 
--                         stored procedures in the current database except for the 
--                         ones created for this homework. 
-- ---------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspDropUserStoredProcedures
AS
SET NOCOUNT ON
DECLARE @strMessage				VARCHAR(250)
DECLARE @strUserStoredProcedure			VARCHAR(250)
DECLARE @strCommand				VARCHAR(250)
DECLARE @chrTab					CHAR = CHAR(9)

------------------------------Drop all user stored procedures-----------------------------------
PRINT @chrTab + 'DROP ALL USER STORED PROCEDURES ...'

DECLARE crsUserStoredProcedures CURSOR FOR
SELECT
	name AS strUserStoredProcedure
FROM
	SysObjects
WHERE
		type	=	'P'     /* Stored Procedures Only */
	AND	name	LIKE	'usp%' 
	AND	name    <>      'uspDropUserForeignKeys'
	AND     name    <>	'uspDropUserViews'
	AND	name	<>	'uspDropUserTables'
	AND	name	<>	'uspDropUserStoredProcedures'
	AND	name	<>	'uspCleanDatabase'
ORDER BY
	name

OPEN crsUserStoredProcedures
FETCH NEXT FROM crsUserStoredProcedures INTO @strUserStoredProcedure

-- Loop until no more records
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT @strMessage = @chrTab + @chrTab + '-DROP ' + @strUserStoredProcedure
	PRINT @strMessage

	-- Build command
	SELECT @strCommand = 'DROP PROCEDURE ' + @strUserStoredProcedure 
						 
	-- Execute command
	EXEC( @strCommand )

	FETCH NEXT FROM crsUserStoredProcedures INTO @strUserStoredProcedure

END

-- Clean up
CLOSE crsUserStoredProcedures
DEALLOCATE crsUserStoredProcedures

PRINT @chrTab + 'DONE'

GO

--uspDropUserStoredProcedures

-- ---------------------------------------------------------------------------------
-- Step #3.5 Extra Credit: Create a stored procedure named uspCleanDatabase that
--                         will call the stored procedures in the previous steps.
-- ---------------------------------------------------------------------------------
GO

CREATE PROCEDURE uspCleanDatabase
AS
SET NOCOUNT ON
DECLARE @chrTab		CHAR = CHAR(9)

PRINT 'CLEANING THE DATABASE ...'

EXECUTE uspDropUserForeignKeys
EXECUTE uspDropUserViews
EXECUTE uspDropUserTables
EXECUTE uspDropUserStoredProcedures

GO

--uspCleanDatabase

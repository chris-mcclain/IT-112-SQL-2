-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Homework 2 - Subqueries and Aggregates
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TTeamPlayers' )		IS NOT NULL DROP TABLE TTeamPlayers
IF OBJECT_ID( 'TPlayers' )		IS NOT NULL DROP TABLE TPlayers
IF OBJECT_ID( 'TTeams' )		IS NOT NULL DROP TABLE TTeams

IF OBJECT_ID( 'TUserFavoriteSongs' )	IS NOT NULL DROP TABLE TUserFavoriteSongs
IF OBJECT_ID( 'TUsers' )		IS NOT NULL DROP TABLE TUsers
IF OBJECT_ID( 'TSongs' )		IS NOT NULL DROP TABLE TSongs

IF OBJECT_ID( 'TCourseBooks')		IS NOT NULL DROP TABLE TCourseBooks
IF OBJECT_ID( 'TBooks' )		IS NOT NULL DROP TABLE TBooks
IF OBJECT_ID( 'TCourseStudents' )	IS NOT NULL DROP TABLE TCourseStudents
IF OBJECT_ID( 'TGrades' )		IS NOT NULL DROP TABLE TGrades
IF OBJECT_ID( 'TStudents' )		IS NOT NULL DROP TABLE TStudents
IF OBJECT_ID( 'TCourses' )		IS NOT NULL DROP TABLE TCourses
IF OBJECT_ID( 'TRooms' )		IS NOT NULL DROP TABLE TRooms
IF OBJECT_ID( 'TInstructors' )		IS NOT NULL DROP TABLE TInstructors

IF OBJECT_ID( 'TCustomerOrderItems' )	IS NOT NULL DROP TABLE TCustomerOrderItems
IF OBJECT_ID( 'TItems' )		IS NOT NULL DROP TABLE TItems
IF OBJECT_ID( 'TCustomerOrders' )	IS NOT NULL DROP TABLE TCustomerOrders
IF OBJECT_ID( 'TSalesRepresentatives' )	IS NOT NULL DROP TABLE TSalesRepresentatives
IF OBJECT_ID( 'TCustomers' )		IS NOT NULL DROP TABLE TCustomers

-- --------------------------------------------------------------------------------
-- Step 1.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TTeams
(
	 intTeamID		INTEGER					NOT NULL
	,strTeam		VARCHAR(50)				NOT NULL
	,strMascot		VARCHAR(50)				NOT NULL
	,CONSTRAINT TTeams_PK PRIMARY KEY ( intTeamID )
)

CREATE TABLE TPlayers
(
	 intPlayerID		INTEGER					NOT NULL
	,strFirstName		VARCHAR(50)				NOT NULL
	,strLastName		VARCHAR(50)				NOT NULL
	,CONSTRAINT TPlayers_PK PRIMARY KEY ( intPlayerID )
)

CREATE TABLE TTeamPlayers
(
	 intTeamID		INTEGER					NOT NULL
	,intPlayerID		INTEGER					NOT NULL
	,CONSTRAINT TTeamPlayers_PK PRIMARY KEY ( intTeamID, intPlayerID )
)

-- --------------------------------------------------------------------------------
-- Step #1.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child			Parent				Column(s)
--		-----			------				---------
-- 1	TTeamPlayers			TTeams				intTeamID
-- 2	TTeamPlayers			TPlayers			intPlayerID

-- 1
ALTER TABLE TTeamPlayers  ADD CONSTRAINT TTeamPlayers_TTeams_FK 
FOREIGN KEY ( intTeamID  ) REFERENCES TTeams ( intTeamID )

-- 2
ALTER TABLE TTeamPlayers  ADD CONSTRAINT TTeamPlayers_TPlayers_FK 
FOREIGN KEY ( intPlayerID ) REFERENCES TPlayers ( intPlayerID )

-- --------------------------------------------------------------------------------
-- Step #1.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TTeams ( intTeamID, strTeam, strMascot )
VALUES   ( 1, 'The Trigonometrists', 'The Unit Circle' )
        ,( 2, 'The Octopi', 'Calamari' )
	,( 3, 'The Prime Numbers', 'The Number 7' )
	,( 4, 'The Biochemists', 'The Krebs Cycle' )

INSERT INTO TPlayers ( intPlayerID, strFirstName, strLastName )
VALUES   ( 1, 'Johan', 'Sprinklebutter' )
        ,( 2, 'Lars', 'Gardengnome' )
	,( 3, 'Rosa', 'Prantangle' )
	,( 4, 'Stavros', 'Melonballer' )

INSERT INTO TTeamPlayers ( intTeamID, intPlayerID )
VALUES   ( 1, 1 )
	,( 1, 2 )
	,( 1, 4 )
	,( 2, 2 )
	,( 2, 4 )
	,( 3, 1 )
	,( 3, 2 )

-- --------------------------------------------------------------------------------
-- Step #1.4A Display the ID and name of every team with a player count for each 
--           team - old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TT.intTeamID
	,TT.strTeam
	,COUNT(*)	AS intPlayerCount
FROM
	 TTeams		AS TT
	,TTeamPlayers	AS TTP
WHERE
	TT.intTeamID = TTP.intTeamID
GROUP BY
	 TT.intTeamID
	,TT.strTeam
ORDER BY
	strTeam

-- --------------------------------------------------------------------------------
-- Step #1.4B Display the ID and name of every team with a player count for each 
--           team - new syntax 
-- --------------------------------------------------------------------------------
-- ******************************************************************************
-- 10% Extra Credit for using both old and new syntax inner joins
-- ******************************************************************************
SELECT
	 TT.intTeamID
	,TT.strTeam
	,COUNT(*) AS intPlayerCount
FROM
	 TTeams	AS TT
		INNER JOIN TTeamPlayers	AS TTP
		ON ( TT.intTeamID = TTP.intTeamID )
GROUP BY
	 TT.intTeamID
	,TT.strTeam
ORDER BY
	strTeam

-- --------------------------------------------------------------------------------
-- Step #1.5 Show all players on a specific team 
-- --------------------------------------------------------------------------------
SELECT
	 TP.intPlayerID
	,TP.strLastName
		+ ', ' 
		+ TP.strFirstName AS strPlayer
FROM
	TPlayers AS TP
WHERE
	 TP.intPlayerID IN
	 (
		SELECT 
			TTP.intPlayerID
		FROM
			TTeamPlayers AS TTP
		WHERE
			TTP.intTeamID = 3
	 )
ORDER BY
	 TP.strLastName
	,TP.strFirstName

-- --------------------------------------------------------------------------------
-- Step #1.6 Show all players not on a specific team
-- --------------------------------------------------------------------------------
SELECT
	 TP.intPlayerID
	,TP.strFirstName
		+ ', '
		+ TP.strLastName As strPlayer
FROM
	TPlayers AS TP
WHERE
	TP.intPlayerID NOT IN
	(
		SELECT
			TTP.intPlayerID
		FROM 
			TTeamPlayers AS TTP
		WHERE
			TTP.intTeamID = 3
	)
ORDER BY
	 TP.strLastName
	,TP.strFirstName

-- ********************************************************************************
-- +15% extra credit: Display the ID and name of every team with a player count  
--                    for each team, even if there are no players on the team
-- ********************************************************************************
SELECT
	 TT.intTeamID
	,TT.strTeam
	,ISNULL(COUNT(intPlayerID), 0)	AS intPlayerCount
FROM
	 TTeams	AS TT
		LEFT OUTER JOIN TTeamPlayers AS TTP
		ON ( TT.intTeamID = TTP.intTeamID )
GROUP BY
	 TT.intTeamID
	,TT.strTeam
ORDER BY
	strTeam

-- --------------------------------------------------------------------------------
-- Step 2.1 Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TUsers 
(
	 intUserID		INTEGER			NOT NULL
	,strFirstName		VARCHAR(50)	 	NOT NULL
	,strLastName		VARCHAR(50)		NOT NULL
	,CONSTRAINT TUsers_PK PRIMARY KEY ( intUserID )
)

CREATE TABLE TSongs
(
	 intSongID		INTEGER			NOT NULL
	,strSong		VARCHAR(50)		NOT NULL
	,strArtist		VARCHAR(50)		NOT NULL
	,CONSTRAINT TSongs_PK PRIMARY KEY ( intSongID )
)

CREATE TABLE TUserFavoriteSongs
(	
	 intUserID		INTEGER			NOT NULL
	,intSongID		INTEGER			NOT NULL
	,intSortOrder		INTEGER			NOT NULL
	,CONSTRAINT TUserFavoriteSongs_PK PRIMARY KEY ( intUserID, intSongID )			
)

-- --------------------------------------------------------------------------------
-- Step #2.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--	Child					Parent				Column(s)
--	-----					------				---------
-- 1	TUserFavoriteSongs			TUsers				intUserID
-- 2	TUserFavoriteSongs			TSongs				intSongID

--1
ALTER TABLE TUserFavoriteSongs ADD CONSTRAINT TUserFavoriteSongs_TUsers_FK
FOREIGN KEY ( intUserID ) REFERENCES TUsers ( intUserID )

--2
ALTER TABLE TUserFavoriteSongs ADD CONSTRAINT TUserFavoriteSongs_TSongs_FK
FOREIGN KEY ( intSongID ) REFERENCES TSongs ( intSongID )

-- --------------------------------------------------------------------------------
-- Step #2.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TUsers ( intUserID, strFirstName, strLastName )
VALUES   ( 1, 'Mary', 'Merriweather' )
	,( 2, 'James', 'Jamison' )
	,( 3, 'Longwind', 'Sparklepants' )
	,( 4, 'Maris', 'Marquette' )
	,( 5, 'Brandon', 'Brandywine' )

INSERT INTO TSongs ( intSongID, strSong, strArtist )
VALUES   ( 1, 'People are People', 'Depeche Mode' )
	,( 2, 'Never Let Me Down Again', 'Depeche Mode' )
	,( 3, 'Behind the Wheel', 'Depeche Mode' )
	,( 4, 'Get the Balance Right', 'Depeche Mode' )
	,( 5, 'Reel Around the Fountain', 'The Smiths' )
	,( 6, 'How Soon is Now', 'The Smiths' )
	,( 7, 'Bigmouth Strikes Again', 'The Smiths' )
	,( 8, 'Birds Fly (Whisper to a Scream)', 'The Icicle Works' )
	,( 9, 'Love is a Wonderful Colour', 'The Icicle Works' )
	,( 10, 'Out of Season', 'The Icicle Works' )
	,( 11, 'Love Will Tear Us Apart', 'Joy Division' )
	,( 12, 'The Killing Moon', 'Echo and the Bunnymen' )
	,( 13, 'The Sky''s Gone Out', 'Bauhaus' )
	,( 14, 'Swing the Heartache', 'Bauhaus' )
	,( 15, 'Third Uncle', 'Bauhaus' )

-- ************************************************
--  5% Extra Credit for using I-Love-The-80s songs
-- ************************************************

INSERT INTO TUserFavoriteSongs ( intUserID, intSongID, intSortOrder )
VALUES   ( 1, 2, 1 )
	,( 1, 9, 2 )
	,( 1, 8, 3 )
	,( 1, 3, 4 )
	,( 2, 3, 1 )
	,( 2, 4, 2 )
	,( 2, 5, 3 )
	,( 2, 6, 4 )
	,( 2, 12, 5 )
	,( 2, 13, 6 )
	,( 2, 14, 7 )
	,( 3, 1, 1 )
	,( 3, 2, 2 )
	,( 3, 3, 3 )
	,( 3, 10, 4 )
	,( 3, 8, 5 )
	,( 3, 9, 6 )
	,( 3, 4, 7 )
	,( 4, 4, 1 )
	,( 4, 2, 2 )
	,( 4, 8, 3 )
	,( 4, 6, 4 )
	,( 5, 3, 1 )
	,( 5, 8, 2 )
	,( 5, 2, 3 )
	,( 5, 10, 4 )
	,( 5, 1, 5 )
	,( 5, 9, 6 )

-- --------------------------------------------------------------------------------
-- Step #2.4A Display the ID and name for every user, include the number of 
--           favorite songs for each user - old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TU.intUserID
	,TU.strLastName
		+ ', '
		+ TU.strFirstName AS strUser
	,COUNT(*) AS intUserFavoriteSongCount
FROM
	 TUsers	AS TU
	,TUserFavoriteSongs AS TUFS
WHERE
	TU.intUserID = TUFS.intUserID
GROUP BY
	 TU.intUserID
	,TU.strLastName
	,TU.strFirstName
ORDER BY
	strUser

-- --------------------------------------------------------------------------------
-- Step #2.4B Display the ID and name for every user, include the number of 
--           favorite songs for each user - new syntax
-- --------------------------------------------------------------------------------
SELECT
	 TU.intUserID
	,TU.strLastName
		+ ', '
		+ TU.strFirstName AS strUser
	,COUNT(*) AS intUserFavoriteSongCount
FROM
	 TUsers	AS TU
		INNER JOIN TUserFavoriteSongs AS TUFS
		ON ( TU.intUserID = TUFS.intUserID )
GROUP BY
	 TU.intUserID
	,TU.strLastName
	,TU.strFirstName
ORDER BY
	strUser

-- --------------------------------------------------------------------------------
-- Step #2.5A Show all users that have at least 3 favorite songs by your favorite
--           band - old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TU.intUserID
	,TU.strLastName
		+ ', '
		+ TU.strFirstName AS strUser
	,COUNT(*) AS intUserFavoriteBandSongCount
FROM
	 TUsers	AS TU
	,TUserFavoriteSongs AS TUFS
	,TSongs	AS TS
WHERE 
	 TS.strArtist = 'The Icicle Works'
 AND TUFS.intSongID = TS.intSongID 
 AND TU.intUserID = TUFS.intUserID 
GROUP BY
	 TU.intUserID
	,TU.strLastName
	,TU.strFirstName
HAVING
	COUNT(*) >= 3
ORDER BY
	 TU.strLastName
	,TU.strFirstName
-- --------------------------------------------------------------------------------
-- Step #2.5B Show all users that have at least 3 favorite songs by your favorite
--           band - new syntax
-- --------------------------------------------------------------------------------
SELECT
	 TU.intUserID
	,TU.strLastName
		+ ', '
		+ TU.strFirstName AS strUser
	,COUNT(*) AS intUserFavoriteBandSongCount
FROM
	 TUsers	AS TU
		INNER JOIN TUserFavoriteSongs AS TUFS
			INNER JOIN TSongs AS TS
			ON ( TUFS.intSongID = TS.intSongID )
		ON ( TU.intUserID = TUFS.intUserID )
WHERE 
	TS.strArtist = 'The Icicle Works'
GROUP BY
	 TU.intUserID
	,TU.strLastName
	,TU.strFirstName
HAVING
	COUNT(*) >= 3
ORDER BY
	 TU.strLastName
	,TU.strFirstName

-- --------------------------------------------------------------------------------
-- +25% Extra credit Show all users that have at least 3 favorite songs by your
--                   number 1 favorite band and at least 3 songs by your second
--					 favorite band
-- --------------------------------------------------------------------------------	
SELECT 
	 TU.intUserID
	,TU.strLastName
		+ ', '
		+ TU.strFirstName AS strUser
	,COUNT(*) AS intFavoriteBandSongCount
FROM
	TUsers	AS TU
		INNER JOIN TUserFavoriteSongs AS TUFS
			INNER JOIN TSongs AS TS
			ON ( TUFS.intSongID = TS.intSongID )
		ON ( TU.intUserID = TUFS.intUserID )
WHERE 
	TS.strArtist = 'The Icicle Works'
GROUP BY
	TU.intUserID
	,TU.strLastName
	,TU.strFirstName
HAVING
	COUNT(TS.strSong) >= 3

UNION ALL

SELECT 
	TU.intUserID
	,TU.strLastName
	+ ', '
	+ TU.strFirstName AS strUser
	,COUNT(*)  AS intFavoriteBandSongCount
FROM
	TUsers AS TU
		INNER JOIN TUserFavoriteSongs AS TUFS
			INNER JOIN TSongs AS TS
			ON ( TUFS.intSongID = TS.intSongID )
		ON ( TU.intUserID = TUFS.intUserID )
WHERE 
	TS.strArtist = 'Depeche Mode'
GROUP BY
	 TU.intUserID
	,TU.strLastName
	,TU.strFirstName
HAVING
	COUNT(TS.strSong) >= 3
ORDER BY
	 strUser
-- --------------------------------------------------------------------------------
-- Step 3.1 Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TInstructors
(
	 intInstructorID		INTEGER				NOT NULL
	,strFirstName			VARCHAR(50)			NOT NULL
	,strLastName			VARCHAR(50)			NOT NULL
	,CONSTRAINT TInstructors_PK PRIMARY KEY ( intInstructorID )
)

CREATE TABLE TRooms
(
	 intRoomID			INTEGER				NOT NULL
	,strRoomNumber			VARCHAR(50)			NOT NULL
	,intCapacity			INTEGER				NOT NULL
	,CONSTRAINT TRooms_PK PRIMARY KEY ( intRoomID )
)

CREATE TABLE TCourses
(
	 intCourseID			INTEGER				NOT NULL
	,strCourse			VARCHAR(50)			NOT NULL
	,strDescription			VARCHAR(50)			NOT NULL
	,intInstructorID		INTEGER				NOT NULL
	,intRoomID			INTEGER				NOT NULL
	,strMeetingTimes		VARCHAR(50)			NOT NULL
	,decCreditHours			DECIMAL(38, 0)			NOT NULL
	,CONSTRAINT TCourses_PK PRIMARY KEY ( intCourseID )				
)

CREATE TABLE TStudents
(
	 intStudentID			INTEGER				NOT NULL
	,strFirstName			VARCHAR(50)			NOT NULL
	,strLastName			VARCHAR(50)			NOT NULL
	,CONSTRAINT TStudents_PK PRIMARY KEY ( intStudentID )
)

CREATE TABLE TGrades
(
	 intGradeID			INTEGER				NOT NULL
	,strGradeLetter			VARCHAR(50)			NOT NULL
	,decGradePointValue		DECIMAL(38, 0)			NOT NULL
	,CONSTRAINT TGrades_PK PRIMARY KEY ( intGradeID )
)

CREATE TABLE TCourseStudents
(
	 intCourseID			INTEGER				NOT NULL
	,intStudentID			INTEGER				NOT NULL
	,intGradeID			INTEGER				NOT NULL
	,CONSTRAINT TCourseStudents_PK PRIMARY KEY ( intCourseID, intStudentID )
)

CREATE TABLE TBooks
(
	 intBookID			INTEGER				NOT NULL
	,strBookName			VARCHAR(50)			NOT NULL
	,strAuthor			VARCHAR(50)			NOT NULL
	,strISBN			VARCHAR(50)			NOT NULL
	,CONSTRAINT TBooks_PK PRIMARY KEY ( intBookID )
)

CREATE TABLE TCourseBooks
(
	 intCourseID			INTEGER				NOT NULL
	,intBookID			INTEGER				NOT NULL
	,CONSTRAINT TCourseBooks_PK PRIMARY KEY ( intCourseID, intBookID )
)

-- --------------------------------------------------------------------------------
-- Step #3.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child				Parent				Column(s)
--		-----				------				---------
-- 1	TCourses				TInstructors			intInstructorID
-- 2	TCourses				TRooms				intRoomID
-- 3	TCourseStudents				TCourses			intCourseID
-- 4	TCourseStudents				TStudents			intStudentID
-- 5	TCourseStudents				TGrades				intGradeID
-- 6	TCourseBooks				TCourses			intCourseID
-- 7	TCourseBooks				TBooks				intBookID

--1
ALTER TABLE TCourses ADD CONSTRAINT TCourses_TInstructors_FK
FOREIGN KEY ( intInstructorID ) REFERENCES TInstructors ( intInstructorID )

--2
ALTER TABLE TCourses ADD CONSTRAINT TCourses_TRooms_FK
FOREIGN KEY ( intRoomID ) REFERENCES TRooms ( intRoomID )

--3
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TCourses_FK
FOREIGN KEY ( intCourseID ) REFERENCES TCourses ( intCourseID )

--4
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TStudents_FK
FOREIGN KEY ( intStudentID ) REFERENCES TStudents ( intStudentID )

--5
ALTER TABLE TCourseStudents ADD CONSTRAINT TCourseStudents_TGrades_FK
FOREIGN KEY ( intGradeID ) REFERENCES TGrades ( intGradeID )

--6
ALTER TABLE TCourseBooks ADD CONSTRAINT TCourseBooks_TCourses_FK
FOREIGN KEY ( intCourseID ) REFERENCES TCourses ( intCourseID )

--7
ALTER TABLE TCourseBooks ADD CONSTRAINT TCourseBooks_TBooks_FK
FOREIGN KEY ( intBookID ) REFERENCES TBooks ( intBookID )

-- --------------------------------------------------------------------------------
-- Step #3.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TInstructors ( intInstructorID, strFirstName, strLastName )
VALUES   ( 1, 'Nigel', 'Stringtheory' )
	,( 2, 'Tatum', 'Hadroncollider' )
	,( 3, 'Sebastian', 'Beryllium' )
	,( 4, 'Erich', 'Hadoop' )

INSERT INTO TRooms ( intRoomID, strRoomNumber, intCapacity )
VALUES   ( 1, '407', 47 )
	,( 2, '222', 100 )
	,( 3, '820', 56 )
	,( 4, '333', 50 ) 

INSERT INTO TCourses ( intCourseID, strCourse, strDescription, intInstructorID, intRoomID,
                       strMeetingTimes, decCreditHours )
VALUES   ( 1, 'Philosophy 203', 'The Why of Quantum Jelly Beans', 1, 1, 'M/W: 2pm - 4pm', 3 )
	,( 2, 'Biology 459', 'Fun with Microtubules', 2, 2, 'T: 10am - 12pm', 2 )
	,( 3, 'Chemistry 350', 'Essential Apoptosis', 3, 3, 'T/R: 11am - 1pm', 4 )
	,( 4, 'Chemistry 678', 'Redox Revisited', 4, 4, 'M/W/F: 8am - 9am', 3 )

INSERT INTO TStudents ( intStudentID, strFirstName, strLastName )
VALUES   ( 1, 'Melissa', 'Cobol' )
	,( 2, 'Farhad', 'Smalltalk' )
	,( 3, 'Alistair', 'Matlab' )
	,( 4, 'Cecily', 'Clojure' )

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
	,( 2, 1, 2 )
	,( 2, 2, 7 )
	,( 3, 3, 8 )
	,( 3, 4, 6 )
	,( 4, 1, 4 )
	,( 4, 3, 1 )
	,( 4, 4, 5 )

INSERT INTO TBooks ( intBookID, strBookName, strAuthor, strISBN )
VALUES   ( 1, 'Jelly Bean Physics', 'Nan Planck', '1111111111' )
	,( 2, 'Cytosine Unseen', 'Philip Krick', '2222222222' )
	,( 3, 'Programmed Cell Death', 'Emery Ligand', '3333333333' )
	,( 4, 'Pare Redoxical', 'Emily Rust', '4444444444' )

INSERT INTO TCourseBooks ( intCourseID, intBookID )
VALUES	 ( 1, 1 )
	,( 2, 2 )
	,( 3, 3 )
	,( 4, 4 )

-- --------------------------------------------------------------------------------
-- Step #3.4A Display the ID and name for every course, room capacity, number of
--            students enrolled, and number of spots left - old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TC.intCourseID
	,TC.strCourse
	,TR.intCapacity
	,COUNT(*) AS intEnrolledStudentCount
	,TR.intCapacity - COUNT(*) AS intAvailableCount
FROM
	 TCourses AS TC
	,TRooms	AS TR
	,TCourseStudents AS TCS
WHERE
	  TC.intRoomID = TR.intRoomID
  AND TC.intCourseID = TCS.intCourseID
GROUP BY
	 TC.intCourseID
	,TC.strCourse
	,TR.intCapacity
ORDER BY
	TC.strCourse

-- --------------------------------------------------------------------------------
-- Step #3.4B Display the ID and name for every course, room capacity, number of
--            students enrolled, and number of spots left - new syntax
-- --------------------------------------------------------------------------------
SELECT
	 TC.intCourseID
	,TC.strCourse
	,TR.intCapacity
	,COUNT(*) AS intEnrolledStudentCount
	,TR.intCapacity - COUNT(*) AS intAvailableCount
FROM
	 TCourses AS TC
		INNER JOIN TRooms AS TR
		ON ( TC.intRoomID = TR.intRoomID )

		INNER JOIN TCourseStudents AS TCS
		ON ( TC.intCourseID = TCS.intCourseID )
GROUP BY
	 TC.intCourseID
	,TC.strCourse
	,TR.intCapacity
ORDER BY
	TC.strCourse

-- --------------------------------------------------------------------------------
-- Step #3.5A Display the ID and name for every student - include student GPAs -
--            old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TS.intStudentID
	,TS.strLastName
		+ ', '
		+ TS.strFirstName AS strStudent
	,SUM( TC.decCreditHours * TG.decGradePointValue )
	/SUM( TC.decCreditHours ) AS decGradePointAverage
FROM
	 TStudents AS TS
	,TCourseStudents AS TCS
	,TCourses AS TC
	,TGrades AS TG
WHERE
      TS.intStudentID = TCS.intStudentID
  AND TCS.intCourseID = TC.intCourseID
  AND TCS.intGradeID  = TG.intGradeID
  AND TG.intGradeID <> 8
  AND TG.intGradeID <> 9
GROUP BY
	 TS.intStudentID
	,TS.strLastName
	,TS.strFirstName
ORDER BY
	 TS.strLastName
	,TS.strFirstName

-- --------------------------------------------------------------------------------
-- Step #3.5B Display the ID and name for every student - include student GPAs -
--            new syntax
-- --------------------------------------------------------------------------------
SELECT
	 TS.intStudentID
	,TS.strLastName
		+ ', '
		+ TS.strFirstName AS strStudent
	,SUM( TC.decCreditHours * TG.decGradePointValue )
	/SUM( TC.decCreditHours ) AS decGradePointAverage
FROM
	 TStudents AS TS
		INNER JOIN TCourseStudents AS TCS

			INNER JOIN TCourses AS TC
			ON ( TCS.intCourseID = TC.intCourseID )

			INNER JOIN TGrades AS TG
			ON ( TCS.intGradeID = TG.intGradeID )

		ON ( TS.intStudentID = TCS.intStudentID )
WHERE
	TG.intGradeID <> 8
  AND   TG.intGradeID <> 9
GROUP BY
	 TS.intStudentID
	,TS.strLastName
	,TS.strFirstName
ORDER BY
	 TS.strLastName
	,TS.strFirstName

-- --------------------------------------------------------------------------------
-- Step 4.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TCustomers
(
	 intCustomerID			INTEGER				NOT NULL
	,strFirstName			VARCHAR(50)			NOT NULL
	,strLastName			VARCHAR(50)			NOT NULL
	,CONSTRAINT TCustomers_PK PRIMARY KEY ( intCustomerID )
)

CREATE TABLE TSalesRepresentatives
(
	intSalesRepresentativeID	INTEGER				NOT NULL
	,strFirstName			VARCHAR(50)			NOT NULL
	,strLastName			VARCHAR(50)			NOT NULL
	,CONSTRAINT TSalesRepresentatives_PK PRIMARY KEY ( intSalesRepresentativeID )
)

CREATE TABLE TCustomerOrders
(
	 intCustomerID			INTEGER				NOT NULL
	,intOrderIndex			INTEGER				NOT NULL
	,dtmOrderDate			DATETIME			NOT NULL
	,intSalesRepresentativeID	INTEGER				NOT NULL
	,CONSTRAINT TCustomerOrders_PK PRIMARY KEY ( intCustomerID, intOrderIndex )
)

CREATE TABLE TItems
(
	 intItemID			INTEGER				NOT NULL
	,strItem			VARCHAR(50)			NOT NULL
	,monPrice			MONEY				NOT NULL
	,CONSTRAINT TItems_PK PRIMARY KEY ( intItemID )
)

CREATE TABLE TCustomerOrderItems
(
	 intCustomerID			INTEGER				NOT NULL
	,intOrderIndex			INTEGER				NOT NULL
	,intItemID			INTEGER				NOT NULL
	,intQuantity			INTEGER				NOT NULL
	,CONSTRAINT TCustomerOrderItems_PK PRIMARY KEY ( intCustomerID, intOrderIndex, intItemID )
)

-- --------------------------------------------------------------------------------
-- Step #4.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child				Parent					Column(s)
--		-----				------					---------
-- 1	TCustomerOrders				TCustomers				intCustomerID
-- 2	TCustomerOrders				TSalesRepresentatives			intSalesRepresentativeID
-- 3	TCustomerOrderItems			TCustomerOrders				intCustomerID, intOrderIndex
-- 4	TCustomerOrderItems			TItems					intItemID

--1
ALTER TABLE TCustomerOrders ADD CONSTRAINT TCustomerOrders_TCustomers_FK
FOREIGN KEY ( intCustomerID ) REFERENCES TCustomers ( intCustomerID )

--2
ALTER TABLE TCustomerOrders ADD CONSTRAINT TCustomerOrders_TSalesRepresentatives_FK
FOREIGN KEY ( intSalesRepresentativeID ) REFERENCES TSalesRepresentatives ( intSalesRepresentativeID )

--3
ALTER TABLE TCustomerOrderItems ADD CONSTRAINT TCustomerOrderItems_TCustomerOrders_FK
FOREIGN KEY ( intCustomerID, intOrderIndex ) REFERENCES TCustomerOrders ( intCustomerID, intOrderIndex )

--4
ALTER TABLE TCustomerOrderItems ADD CONSTRAINT TCustomerOrderItems_TItems_FK
FOREIGN KEY ( intItemID ) REFERENCES TItems ( intItemID )

-- --------------------------------------------------------------------------------
-- Step #4.3 Add at least 2 inserts per table
-- --------------------------------------------------------------------------------
INSERT INTO TCustomers ( intCustomerID, strFirstName, strLastName )
VALUES   ( 1, 'Sandy', 'Squirtle' )
	,( 2, 'Joseph', 'Butterfree' )
	,( 3, 'Martin', 'Ivysaur' )
	,( 4, 'Ian', 'Vulpix' )
	,( 5, 'James', 'Pikachu' )

INSERT INTO TSalesRepresentatives ( intSalesRepresentativeID, strFirstName, strLastName )
VALUES   ( 1, 'Henri', 'Becquerel' )
	,( 2, 'Alexander', 'Von Humbolt' )
	,( 3, 'Anders', 'Celsius' )
	,( 4, 'James', 'Van Allen' )

INSERT INTO TCustomerOrders ( intCustomerID, intOrderIndex, dtmOrderDate, intSalesRepresentativeID )
VALUES   ( 1, 1, '01/01/2015 15:00', 1 )
	,( 1, 2, '05/05/2015 12:21', 2 )
	,( 1, 3, '07/17/2015 08:30', 3 )
	,( 2, 1, '10/03/2012 05:30', 4 )
	,( 2, 2, '12/12/2013 09:50', 1 )
	,( 2, 3, '06/06/2014 18:49', 2 )
	,( 3, 1, '02/23/2014 17:38', 3 )
	,( 3, 2, '11/30/2014 15:45', 4 )
	,( 3, 3, '09/21/2015 10:30', 1 )
	,( 4, 1, '04/14/2014 12:40', 2 )
	,( 4, 2, '08/08/2015 07:30', 3 )
	,( 4, 3, '03/14/2016 13:20', 4 )
	,( 5, 1, '12/01/2009 16:45', 1 )
	,( 5, 2, '05/09/2014 06:20', 2 )
	,( 5, 3, '07/07/2015 15:10', 3 )

INSERT INTO TItems ( intItemID, strItem, monPrice )
VALUES   ( 1, 'Higgs Boson', 23000 )
	,( 2, 'Quark', 16000 )
	,( 3, 'Black Hole', 25000 )
	,( 4, 'Quasar', 9000 )
	,( 5, 'Positron', 5000 )
	,( 6, 'Accretion Disk', 10000 )
	,( 7, 'Supernova', 20000 )

INSERT INTO TCustomerOrderItems ( intCustomerID, intOrderIndex, intItemID, intQuantity )
VALUES   ( 1, 1, 6, 2 )
	,( 1, 2, 4, 1 )
	,( 1, 3, 1, 1 )
	,( 2, 1, 5, 10 )
	,( 2, 2, 7, 5 )
	,( 2, 3, 2, 6 )
	,( 3, 1, 3, 3 )
	,( 3, 2, 7, 2 )
	,( 3, 3, 1, 5 )
	,( 4, 1, 2, 3 )
	,( 4, 2, 6, 1 )
	,( 4, 3, 4, 3 )
	,( 5, 1, 5, 1 )
	,( 5, 2, 2, 2 )
	,( 5, 3, 3, 12 )

-- --------------------------------------------------------------------------------
-- Step #4.4A Display the customer ID, customer name, order index, order date,
--            total cost of the order, total number of items in the order, and the
--            average price of each item in the order -  old syntax
-- --------------------------------------------------------------------------------
SELECT 
	 TC.intCustomerID
	,TC.strLastName
		+ ', '
		+ TC.strFirstName AS strCustomer
	,TCO.intOrderIndex
	,CONVERT( VARCHAR, TCO.dtmOrderDate, 111 ) strOrderDate
	,SUM( TCOI.intQuantity * TI.monPrice ) AS monOrderTotalPrice
	,SUM( TCOI.intQuantity ) AS intItemCount
	,SUM( TCOI.intQuantity * TI.monPrice )
	/SUM(TCOI.intQuantity) AS monOrderAverageItemPrice
FROM
	 TCustomers AS TC
	,TCustomerOrders AS TCO
	,TCustomerOrderItems AS TCOI
	,TItems	AS TI
WHERE
	  TC.intCustomerID = TCO.intCustomerID
  AND TCO.intCustomerID	= TCOI.intCustomerID
  AND TCO.intOrderIndex	= TCOI.intOrderIndex
  AND TCOI.intItemID = TI.intItemID
GROUP BY
	 TC.intCustomerID
	,TC.strLastName
	,TC.strFirstName
	,TCO.intOrderIndex
	,TCO.dtmOrderDate
ORDER BY
	 TC.strLastName
	,TC.strFirstName
	,TCO.dtmOrderDate

-- --------------------------------------------------------------------------------
-- Step #4.4B Display the customer ID, customer name, order index, order date,
--            total cost of the order, total number of items in the order, and the
--            average price of each item in the order -  old syntax
-- --------------------------------------------------------------------------------
SELECT 
	 TC.intCustomerID
	,TC.strLastName
		+ ', '
		+ TC.strFirstName AS strCustomer
	,TCO.intOrderIndex
	,CONVERT( VARCHAR, TCO.dtmOrderDate, 111 ) strOrderDate
	,SUM( TCOI.intQuantity * TI.monPrice ) AS monOrderTotalPrice
	,SUM( TCOI.intQuantity ) AS intItemCount
	,SUM( TCOI.intQuantity * TI.monPrice )
	/SUM(TCOI.intQuantity)	AS monOrderAverageItemPrice
FROM
	 TCustomers AS TC
		INNER JOIN TCustomerOrders AS TCO

			INNER JOIN TCustomerOrderItems AS TCOI

				INNER JOIN TItems AS TI
				ON ( TCOI.intItemID = TI.intItemID )

			ON ( TCO.intCustomerID = TCOI.intCustomerID
			 AND TCO.intOrderIndex = TCOI.intOrderIndex )

		ON ( TC.intCustomerID = TCO.intCustomerID )  
GROUP BY
	 TC.intCustomerID
	,TC.strLastName
	,TC.strFirstName
	,TCO.intOrderIndex
	,TCO.dtmOrderDate
ORDER BY
	 TC.strLastName
	,TC.strFirstName
	,TCO.dtmOrderDate

-- --------------------------------------------------------------------------------
-- Step #4.5A Display the ID and name of each sales representative and the total
--            sales for each sales representative for each of the last three years
--            old syntax
-- --------------------------------------------------------------------------------
SELECT
	 TSR.intSalesRepresentativeID
	,TSR.strLastName
		+ ', '
		+ TSR.strFirstName AS strSalesRepresentative
	,DATEPART(YEAR, TCO.dtmOrderDate) AS intOrderYear
	,SUM( TCOI.intQuantity * TI.monPrice ) AS monOrderTotalPrice
FROM
	 TSalesRepresentatives AS TSR
	,TCustomerOrders AS TCO
	,TCustomerOrderItems AS TCOI
	,TItems	AS TI
WHERE
      TSR.intSalesRepresentativeID = TCO.intSalesRepresentativeID
  AND TCO.intCustomerID	= TCOI.intCustomerID
  AND TCO.intOrderIndex	= TCOI.intOrderIndex
  AND TCOI.intItemID    = TI.intItemID
  AND DATEPART(YEAR, TCO.dtmOrderDate) >= DATEPART(YEAR, GETDATE()) - 2
GROUP BY
	 TSR.intSalesRepresentativeID
	,TSR.strLastName
	,TSR.strFirstName 
	,DATEPART(YEAR, TCO.dtmOrderDate)
ORDER BY
	 DATEPART(YEAR, TCO.dtmOrderDate)
	,SUM( TCOI.intQuantity * TI.monPrice ) DESC
	,TSR.strLastName
	,TSR.strFirstName

-- --------------------------------------------------------------------------------
-- Step #4.5B Display the ID and name of each sales representative and the total
--            sales for each sales representative for each of the last three years
--            new syntax
-- --------------------------------------------------------------------------------
SELECT
	 TSR.intSalesRepresentativeID
	,TSR.strLastName
		+ ', '
		+ TSR.strFirstName AS strSalesRepresentative
	,DATEPART(YEAR, TCO.dtmOrderDate) AS intOrderYear
	,SUM( TCOI.intQuantity * TI.monPrice ) AS monOrderTotalPrice
FROM
	 TSalesRepresentatives AS TSR
		INNER JOIN TCustomerOrders AS TCO

			INNER JOIN TCustomerOrderItems AS TCOI

				INNER JOIN TItems AS TI
				ON ( TCOI.intItemID	= TI.intItemID )

			ON ( TCO.intCustomerID = TCOI.intCustomerID
			 AND TCO.intOrderIndex = TCOI.intOrderIndex )

		ON ( TSR.intSalesRepresentativeID = TCO.intSalesRepresentativeID )
WHERE
	DATEPART(YEAR, TCO.dtmOrderDate) >= DATEPART(YEAR, GETDATE()) - 2
GROUP BY
	 TSR.intSalesRepresentativeID
	,TSR.strLastName
	,TSR.strFirstName 
	,DATEPART(YEAR, TCO.dtmOrderDate)
ORDER BY
	 DATEPART(YEAR, TCO.dtmOrderDate)
	,SUM( TCOI.intQuantity * TI.monPrice ) DESC
	,TSR.strLastName
	,TSR.strFirstName


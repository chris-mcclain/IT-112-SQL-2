-- --------------------------------------------------------------------------------
-- Name: Chris McClain
-- Class: SQL #112-401
-- Abstract: Homework 7 - Outer Joins
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------------
USE dbSQL1;     -- Get out of the master database
SET NOCOUNT ON; -- Report only errors

-- --------------------------------------------------------------------------------
-- Drop Tables
-- --------------------------------------------------------------------------------
IF OBJECT_ID( 'TTeamPlayers' )					IS NOT NULL DROP TABLE TTeamPlayers
IF OBJECT_ID( 'TPlayers' )						IS NOT NULL DROP TABLE TPlayers
IF OBJECT_ID( 'TTeams' )						IS NOT NULL DROP TABLE TTeams

IF OBJECT_ID( 'TUserFavoriteSongs' )			IS NOT NULL DROP TABLE TUserFavoriteSongs
IF OBJECT_ID( 'TUsers' )						IS NOT NULL DROP TABLE TUsers
IF OBJECT_ID( 'TSongs' )						IS NOT NULL DROP TABLE TSongs

IF OBJECT_ID( 'TCourseBooks')					IS NOT NULL DROP TABLE TCourseBooks
IF OBJECT_ID( 'TBooks' )						IS NOT NULL DROP TABLE TBooks
IF OBJECT_ID( 'TCourseStudents' )				IS NOT NULL DROP TABLE TCourseStudents
IF OBJECT_ID( 'TGrades' )						IS NOT NULL DROP TABLE TGrades
IF OBJECT_ID( 'TStudents' )						IS NOT NULL DROP TABLE TStudents
IF OBJECT_ID( 'TCourses' )						IS NOT NULL DROP TABLE TCourses
IF OBJECT_ID( 'TRooms' )						IS NOT NULL DROP TABLE TRooms
IF OBJECT_ID( 'TInstructors' )					IS NOT NULL DROP TABLE TInstructors

IF OBJECT_ID( 'TCustomerOrderItems' )			IS NOT NULL DROP TABLE TCustomerOrderItems
IF OBJECT_ID( 'TItems' )						IS NOT NULL DROP TABLE TItems
IF OBJECT_ID( 'TCustomerOrders' )				IS NOT NULL DROP TABLE TCustomerOrders
IF OBJECT_ID( 'TSalesAgents' )					IS NOT NULL DROP TABLE TSalesAgents
IF OBJECT_ID( 'TCustomers' )					IS NOT NULL DROP TABLE TCustomers

-- --------------------------------------------------------------------------------
-- Step 1.1 - Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TTeams
(
	 intTeamID					INTEGER							NOT NULL
	,strTeam					VARCHAR(50)						NOT NULL
	,strMascot					VARCHAR(50)						NOT NULL
	,CONSTRAINT TTeams_PK PRIMARY KEY ( intTeamID )
)

CREATE TABLE TPlayers
(
	 intPlayerID				INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,CONSTRAINT TPlayers_PK PRIMARY KEY ( intPlayerID )
)

CREATE TABLE TTeamPlayers
(
	 intTeamID					INTEGER							NOT NULL
	,intPlayerID				INTEGER							NOT NULL
	,CONSTRAINT TTeamPlayers_PK PRIMARY KEY ( intTeamID, intPlayerID )
)

-- --------------------------------------------------------------------------------
-- Step #1.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child						Parent					Column(s)
--		-----						------					---------
-- 1	TTeamPlayers				TTeams					intTeamID
-- 2	TTeamPlayers				TPlayers				intPlayerID

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
-- Step #1.4 Display the ID and name of every team with a player count for each 
--           team, even if there are no players on the team.
-- --------------------------------------------------------------------------------
SELECT
	 TT.intTeamID
	,TT.strTeam
	,COUNT( TTP.intPlayerID ) AS intPlayerCount
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
-- Step #1.5 Display the ID and name of every player along with a count of how 
--           many teams each player is on, even if a player isn't on a team.
-- --------------------------------------------------------------------------------
SELECT
	 TP.intPlayerID
	,TP.strLastName
		+ ', '
		+ TP.strFirstName AS strPlayer
	,COUNT( TTP.intTeamID ) AS intTeamCount
FROM
	 TPlayers AS TP
		LEFT OUTER JOIN TTeamPlayers	AS TTP
		ON ( TP.intPlayerID = TTP.intPlayerID )
GROUP BY
	 TP.intPlayerID
	,TP.strLastName
	,TP.strFirstName
ORDER BY
	 TP.strLastName
	,TP.strFirstName

-- --------------------------------------------------------------------------------
-- Step 2.1 Create Tables
-- --------------------------------------------------------------------------------
CREATE TABLE TUsers 
(
	 intUserID					INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,CONSTRAINT TUsers_PK PRIMARY KEY ( intUserID )
)

CREATE TABLE TSongs
(
	 intSongID					INTEGER							NOT NULL
	,strSong					VARCHAR(50)						NOT NULL
	,strArtist					VARCHAR(50)						NOT NULL
	,CONSTRAINT TSongs_PK PRIMARY KEY ( intSongID )
)

CREATE TABLE TUserFavoriteSongs
(	
	 intUserID					INTEGER							NOT NULL
	,intSongID					INTEGER							NOT NULL
	,intSortOrder				INTEGER							NOT NULL
	,CONSTRAINT TUserFavoriteSongs_PK PRIMARY KEY ( intUserID, intSongID )			
)

-- --------------------------------------------------------------------------------
-- Step #2.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child						Parent					Column(s)
--		-----						------					---------
-- 1	TUserFavoriteSongs			TUsers					intUserID
-- 2	TUserFavoriteSongs			TSongs					intSongID

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
-- Step #2.4 Display the ID and name of all songs and a count of how many users
--			 like each song
-- --------------------------------------------------------------------------------
SELECT
	 TS.intSongID
	,TS.strSong
	,COUNT( TUFS.intSongID ) AS intUserFavoriteSongCount
FROM
	TSongs AS TS
		LEFT OUTER JOIN TUserFavoriteSongs AS TUFS
		ON( TS.intSongID = TUFS.intSongID )
GROUP BY
	 TS.intSongID
	,TS.strSong
ORDER BY
	TS.strSong

-- --------------------------------------------------------------------------------
-- Step #2.5 Display the ID and name of all songs and a weighted count of how many 
--           users like each song
-- --------------------------------------------------------------------------------
SELECT
	 TS.intSongID
	,TS.strSong
	,SUM(CASE
		 WHEN TUFS.intSortOrder = 1 THEN 5 
	     WHEN TUFS.intSortOrder = 2 THEN 3
		 WHEN TUFS.intSortOrder = 3 THEN 1
		 ELSE							 0
	END) AS intUserFavoriteSongWeightedCount 
FROM
	TSongs AS TS
		LEFT OUTER JOIN TUserFavoriteSongs AS TUFS
		ON( TS.intSongID = TUFS.intSongID )
GROUP BY
	 TS.intSongID
	,TS.strSong
ORDER BY
	intUserFavoriteSongWeightedCount

-- --------------------------------------------------------------------------------
-- Step 3.1 Create Tables
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
	 intRoomID					INTEGER							NOT NULL
	,strRoomNumber				VARCHAR(50)						NOT NULL
	,intCapacity				INTEGER							NOT NULL
	,CONSTRAINT TRooms_PK PRIMARY KEY ( intRoomID )
)

CREATE TABLE TCourses
(
	 intCourseID				INTEGER							NOT NULL
	,strCourse					VARCHAR(50)						NOT NULL
	,strDescription				VARCHAR(50)						NOT NULL
	,intInstructorID			INTEGER							NOT NULL
	,intRoomID					INTEGER							NOT NULL
	,strMeetingTimes			VARCHAR(50)						NOT NULL
	,decCreditHours				DECIMAL(38, 0)					NOT NULL
	,CONSTRAINT TCourses_PK PRIMARY KEY ( intCourseID )				
)

CREATE TABLE TStudents
(
	 intStudentID				INTEGER							NOT NULL
	,strFirstName				VARCHAR(50)						NOT NULL
	,strLastName				VARCHAR(50)						NOT NULL
	,CONSTRAINT TStudents_PK PRIMARY KEY ( intStudentID )
)

CREATE TABLE TGrades
(
	 intGradeID					INTEGER							NOT NULL
	,strGradeLetter				VARCHAR(50)						NOT NULL
	,decGradePointValue			DECIMAL(38, 0)					NOT NULL
	,CONSTRAINT TGrades_PK PRIMARY KEY ( intGradeID )
)

CREATE TABLE TCourseStudents
(
	 intCourseID				INTEGER							NOT NULL
	,intStudentID				INTEGER							NOT NULL
	,intGradeID					INTEGER							NOT NULL
	,CONSTRAINT TCourseStudents_PK PRIMARY KEY ( intCourseID, intStudentID )
)

CREATE TABLE TBooks
(
	 intBookID					INTEGER							NOT NULL
	,strBookName				VARCHAR(50)						NOT NULL
	,strAuthor					VARCHAR(50)						NOT NULL
	,strISBN					VARCHAR(50)						NOT NULL
	,CONSTRAINT TBooks_PK PRIMARY KEY ( intBookID )
)

CREATE TABLE TCourseBooks
(
	 intCourseID				INTEGER							NOT NULL
	,intBookID					INTEGER							NOT NULL
	,CONSTRAINT TCourseBooks_PK PRIMARY KEY ( intCourseID, intBookID )
)

-- --------------------------------------------------------------------------------
-- Step #3.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child						Parent					Column(s)
--		-----						------					---------
-- 1	TCourses					TInstructors			intInstructorID
-- 2	TCourses					TRooms					intRoomID
-- 3	TCourseStudents				TCourses				intCourseID
-- 4	TCourseStudents				TStudents				intStudentID
-- 5	TCourseStudents				TGrades					intGradeID
-- 6	TCourseBooks				TCourses				intCourseID
-- 7	TCourseBooks				TBooks					intBookID

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

INSERT INTO TStudents ( intStudentID, strFirstName, strLastName )
VALUES   ( 1, 'Melissa', 'Cobol' )
		,( 2, 'Farhad', 'Smalltalk' )
		,( 3, 'Alistair', 'Matlab' )
		,( 4, 'Cecily', 'Clojure' )
		,( 5, 'Graham', 'Cracker' )
		,( 6, 'Julie', 'Venow' )
		,( 7, 'Karl', 'Withakay' )
		,( 8, 'Sunshine', 'Day' )
		,( 9, 'Hugh', 'Holly' )
		,( 10, 'Christmas', 'Lane' )
		,( 11, 'Heidi', 'Hoelle' )

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
-- Step #3.4 Display the ID and name of every course along with the room number, 
--           the room capacity, a count of how many students are currently enrolled
--           and how many spots are left in the class.  Display all courses even if
--           there are not students enrolled. 
-- --------------------------------------------------------------------------------
SELECT 
	 TC.intCourseID
	,TC.strCourse
	,TR.intRoomID
	,TR.strRoomNumber
	,TR.intCapacity
	,COUNT( TCS.intStudentID ) AS intNumberOfCourseStudents
	,TR.intCapacity -  COUNT( TCS.intStudentID ) AS intOpenSeatsRemaining
FROM
	 TCourses AS TC
		 INNER JOIN TRooms AS TR
		 ON( TC.intRoomID = TR.intRoomID )

		 LEFT OUTER JOIN TCourseStudentS AS TCS
		 ON( TC.intCourseID = TCS.intCourseID )
GROUP BY
	 TC.intCourseID
	,TC.strCourse
	,TR.intRoomID
	,TR.strRoomNumber
	,TR.intCapacity
ORDER BY
	TC.strCourse

-- --------------------------------------------------------------------------------
-- Step #3.5 Display the ID and name of every course along with the room number, 
--           the room capacity, a count of how many students are currently enrolled
--           and how many spots are left in the class.  Display all courses even if
--           there are not students enrolled. Display a value of "Open" if # of 
--           students is less than room capacity.  Display a value of "Closed" if 
--           the number of students is equal to or greater than capacity.
-- --------------------------------------------------------------------------------
SELECT 
	 TC.intCourseID
	,TC.strCourse
	,TR.intRoomID
	,TR.strRoomNumber
	,TR.intCapacity
	,COUNT( TCS.intStudentID ) AS intNumberOfCourseStudents
	,TR.intCapacity -  COUNT( TCS.intStudentID ) AS intOpenSeatsRemaining
	,(CASE 
		WHEN TR.intCapacity > COUNT( TCS.intStudentID ) THEN 'Open' 
		ELSE 'Closed' 
	  END) AS strCourseStatus

FROM
	 TCourses AS TC
		 INNER JOIN TRooms AS TR
		 ON( TC.intRoomID = TR.intRoomID )

		 LEFT OUTER JOIN TCourseStudentS AS TCS
		 ON( TC.intCourseID = TCS.intCourseID )
GROUP BY
	 TC.intCourseID
	,TC.strCourse
	,TR.intRoomID
	,TR.strRoomNumber
	,TR.intCapacity
ORDER BY
	TC.strCourse

-- --------------------------------------------------------------------------------
-- Step #3.5 Display the ID and name for every student along with each student's
--           GPA.  Sort by last name and first name.  Do not count incompletes and/
--           or withdrawals.  Display all students even if a student hasn't taken
--           any classes (display a 4.0 in that case). 
-- --------------------------------------------------------------------------------
SELECT
	 TS.intStudentID
	,TS.strLastName
		+ ', '
		+ TS.strFirstName				AS strStudent
	,ISNULL(SUM( TC.decCreditHours * TG.decGradePointValue )
	/SUM( TC.decCreditHours ), 4.0)			AS decGradePointAverage
FROM
	 TStudents							AS TS
		LEFT OUTER JOIN TCourseStudents	AS TCS

			INNER JOIN TCourses	AS TC
			ON ( TCS.intCourseID = TC.intCourseID )

			INNER JOIN TGrades	AS TG
			ON ( TCS.intGradeID = TG.intGradeID 
			AND TG.intGradeID <> 8
			AND TG.intGradeID <> 9 )
		ON ( TS.intStudentID = TCS.intStudentID )
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
	 intCustomerID					INTEGER							NOT NULL
	,strFirstName					VARCHAR(50)						NOT NULL
	,strLastName					VARCHAR(50)						NOT NULL
	,CONSTRAINT TCustomers_PK PRIMARY KEY ( intCustomerID )
)

CREATE TABLE TSalesAgents
(
	 intSalesAgentID				INTEGER							NOT NULL
	,strFirstName					VARCHAR(50)						NOT NULL
	,strLastName					VARCHAR(50)						NOT NULL
	,CONSTRAINT TSalesRepresentatives_PK PRIMARY KEY ( intSalesAgentID )
)

CREATE TABLE TCustomerOrders
(
	 intCustomerID					INTEGER							NOT NULL
	,intOrderIndex					INTEGER							NOT NULL
	,dtmOrderDate					DATETIME						NOT NULL
	,intSalesAgentID				INTEGER							NOT NULL
	,CONSTRAINT TCustomerOrders_PK PRIMARY KEY ( intCustomerID, intOrderIndex )
)

CREATE TABLE TItems
(
	 intItemID						INTEGER							NOT NULL
	,strItemName					VARCHAR(50)						NOT NULL
	,monPrice						MONEY							NOT NULL
	,CONSTRAINT TItems_PK PRIMARY KEY ( intItemID )
)

CREATE TABLE TCustomerOrderItems
(
	 intCustomerID					INTEGER							NOT NULL
	,intOrderIndex					INTEGER							NOT NULL
	,intItemID						INTEGER							NOT NULL
	,intQuantity					INTEGER							NOT NULL
	,CONSTRAINT TCustomerOrderItems_PK PRIMARY KEY ( intCustomerID, intOrderIndex, intItemID )
)

-- --------------------------------------------------------------------------------
-- Step #4.2 Identify and Create Foreign Keys 
-- --------------------------------------------------------------------------------
--		Child						Parent							Column(s)
--		-----						------							---------
-- 1	TCustomerOrders				TCustomers						intCustomerID
-- 2	TCustomerOrders				TSalesAgents					intSalesAgentID
-- 3	TCustomerOrderItems			TCustomerOrders					intCustomerID, intOrderIndex
-- 4	TCustomerOrderItems			TItems							intItemID

--1
ALTER TABLE TCustomerOrders ADD CONSTRAINT TCustomerOrders_TCustomers_FK
FOREIGN KEY ( intCustomerID ) REFERENCES TCustomers ( intCustomerID )

--2
ALTER TABLE TCustomerOrders ADD CONSTRAINT TCustomerOrders_TSalesAgents_FK
FOREIGN KEY ( intSalesAgentID ) REFERENCES TSalesAgents ( intSalesAgentID )

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
		,( 6, 'Nigel', 'Caterpie' )

INSERT INTO TSalesAgents ( intSalesAgentID, strFirstName, strLastName )
VALUES   ( 1, 'Henri', 'Becquerel' )
		,( 2, 'Alexander', 'Von Humbolt' )
		,( 3, 'Anders', 'Celsius' )
		,( 4, 'James', 'Van Allen' )

INSERT INTO TCustomerOrders ( intCustomerID, intOrderIndex, dtmOrderDate, intSalesAgentID )
VALUES   ( 1, 1, '01/01/2015 15:00', 1 )
		,( 1, 2, '05/05/2016 12:21', 2 )
		,( 1, 3, '04/10/2017 08:30', 3 )
		,( 1, 4, '05/16/2017 12:40', 2 )
		,( 2, 1, '10/03/2012 05:30', 1 )
		,( 2, 2, '02/01/2014 09:50', 1 )
		,( 2, 3, '06/06/2017 18:49', 2 )
		,( 3, 1, '02/23/2014 17:38', 3 )
		,( 3, 2, '11/30/2014 15:45', 2 )
		,( 3, 3, '09/21/2015 10:30', 1 )
		,( 4, 1, '04/14/2014 12:40', 2 )
		,( 4, 2, '08/08/2015 07:30', 3 )
		,( 4, 3, '03/14/2016 13:20', 1 )
		,( 5, 1, '12/01/2009 16:45', 1 )
		,( 5, 2, '05/09/2014 06:20', 2 )
		,( 5, 3, '05/07/2017 15:10', 3 )

INSERT INTO TItems ( intItemID, strItemName, monPrice )
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
		,( 1, 4, 2, 1 )
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
-- Step #4.4 Display the ID and name for every sales agent, the current year and
--           the total sales for each sales agent for the current year.  Return a
--           record for each sales agent even if a sales agent didn't make any 
--           sales.
-- --------------------------------------------------------------------------------
SELECT
	 TSA.intSalesAgentID
	,TSA.strLastName
		+ ', '
		+ TSA.strFirstName AS strSalesAgent
	,YEAR( GETDATE() ) AS dtmCurrentYear
	,ISNULL(SUM( TCOI.intQuantity * TI.monPrice ), 0 ) AS monTotalSales
FROM
	TSalesAgents AS TSA
		LEFT OUTER JOIN TCustomerOrders AS TCO
			INNER JOIN TCustomerOrderItems As TCOI
				INNER JOIN TItems AS TI
				ON( TCOI.intItemID = TI.intItemID )
			ON( TCO.intCustomerID = TCOI.intCustomerID
			AND TCO.intOrderIndex = TCOI.intOrderIndex )
		ON( TSA.intSalesAgentID = TCO.intSalesAgentID
		AND YEAR( TCO.dtmOrderDate ) = YEAR( GETDATE() ) )
GROUP BY
	 TSA.intSalesAgentID
	,TSA.strLastName
	,TSA.strFirstName 
ORDER BY
	 TSA.strLastName
	,TSA.strFirstName

-- --------------------------------------------------------------------------------
-- Step #4.5 Calculate the average number of items per order 
--			 order count / item count
-- --------------------------------------------------------------------------------
SELECT
	CONVERT( DECIMAL(16,2),
		-- Order count
		(SELECT CONVERT( DECIMAL(16,2), SUM( intQuantity ) ) FROM TCustomerOrderItems)
		/
		-- Item count
		(SELECT CONVERT( DECIMAL(16,2), COUNT( * ) ) FROM TCustomerOrders) ) AS decAverageItemsPerOrder
		
-- --------------------------------------------------------------------------------
-- Step #4.6 Display all customers, the total of all orders, a count of orders
--           made, the average total of each order, average number of items per 
--			 order, the largest order total and the smallest order total for each
--           customer.
-- --------------------------------------------------------------------------------
SELECT 
	 TC.intCustomerID
	,TC.strLastName
		+ ', '
		+ TC.strFirstName AS strCustomer

	-- Order total
	,ISNULL(SUM( TCOI.intQuantity * TI.monPrice ), 0 ) AS monTotalOrders

	-- Order count
	,COUNT( DISTINCT TCO.intOrderIndex ) AS intOrderCount

	-- Average total 
	,ISNULL( SUM( TCOI.intQuantity * TI.monPrice ) 
		   / COUNT(DISTINCT TCOI.intOrderIndex) , 0 )  AS monAverageOrderTotal

	-- Average number of items
	,CONVERT( DECIMAL(16,2),
		ISNULL(	CONVERT(DECIMAL(16,2), SUM( TCOI.intQuantity ) )
			  / CONVERT(DECIMAL(16,2), COUNT(DISTINCT TCOI.intOrderIndex ) ), 0 ) , 0 ) AS decAverageItemsPerOrder

	-- Largest order total
	,ISNULL( (
		SELECT
			TOP	1 SUM( TI.monPrice * TCOI.intQuantity )
		FROM
			TCustomers AS TC
				INNER JOIN TCustomerOrders AS TCO
					INNER JOIN TCustomerOrderItems AS TCOI
						INNER JOIN TItems AS TI
						ON( TCOI.intItemID = TI.intItemID )
					ON( TCO.intCustomerID = TCOI.intCustomerID
					AND TCO.intOrderIndex = TCOI.intOrderIndex 

					-- Cross query join to limit current customer in outer query
					AND TC.intCustomerID = TCO.intCustomerID )
				ON( TC.intCustomerID = TCO.intCustomerID )
		GROUP BY
			 TC.intCustomerID
			,TCO.intOrderIndex
		ORDER BY
			SUM( TI.monPrice * TCOI.intQuantity ) Desc ), 0 ) AS monLargestOrderTotal

	-- Smallest order total
	,ISNULL( (
		SELECT
			TOP	1 SUM( TI.monPrice * TCOI.intQuantity )
		FROM
			TCustomers AS TC
				INNER JOIN TCustomerOrders AS TCO
					INNER JOIN TCustomerOrderItems AS TCOI
						INNER JOIN TItems AS TI
						ON( TCOI.intItemID = TI.intItemID )
					ON( TCO.intCustomerID = TCOI.intCustomerID
					AND TCO.intOrderIndex = TCOI.intOrderIndex 

					-- Cross query join to limit current customer in outer query
					AND TC.intCustomerID = TCO.intCustomerID )
				ON( TC.intCustomerID = TCO.intCustomerID )
		GROUP BY
			 TC.intCustomerID
			,TCO.intOrderIndex
		ORDER BY
			SUM( TI.monPrice * TCOI.intQuantity ) ASC ), 0 ) AS monSmallestOrderTotal
FROM
	TCustomers	AS TC
		LEFT OUTER JOIN TCustomerOrders AS TCO
			INNER JOIN TCustomerOrderItems AS TCOI
				INNER JOIN TItems AS TI
				ON TCOI.intItemID = TI.intItemID
			ON ( TCO.intCustomerID = TCOI.intCustomerID
			AND  TCO.intOrderIndex = TCOI.intOrderIndex )
		ON TC.intCustomerID = TCO.intCustomerID
GROUP BY
	 TC.intCustomerID
	,TC.strLastName
	,TC.strFirstName
ORDER BY
	 TC.strLastName
	,Tc.strFirstName
	

			

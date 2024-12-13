-- Table to store user login credentials
CREATE TABLE USERLOG (
    UserID INT NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID)
);

-- Table to store user profiles
CREATE TABLE UserProfiles (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Location VARCHAR(255)
);

-- Table to store resumes, associated with user profiles
CREATE TABLE Resumes (
    ResumeID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Summary TEXT,
   --drop WorkExperience TEXT,
    Skills TEXT,    -- Comma-separated list of skills
    Certifications TEXT,    -- Certifications the user has obtained
    Projects TEXT,   -- List of projects the user has worked on
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID)
);

-- Table to store educational background of users
CREATE TABLE Education (
    EducationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Degree VARCHAR(255) NOT NULL,
    Institution VARCHAR(255) NOT NULL,
    StartYear INT,
    EndYear INT,
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID)
);

-- Table to store company information
CREATE TABLE Companies (
    CompanyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Industry VARCHAR(255),
    Website VARCHAR(255),
    Location VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT
);

CREATE TABLE CompanyLog (
    CompanyLogID INT PRIMARY KEY AUTO_INCREMENT,
    CompanyID INT,
    Email VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID)
);

-- Table to store internships
CREATE TABLE Internships (
    InternshipID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    Location VARCHAR(255),
    Duration VARCHAR(100),
    ApplicationDeadline DATE,
    CompanyID INT,
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID)
);

-- Table to store internship applications
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    InternshipID INT,
    Status ENUM('Pending', 'Accepted', 'Rejected') DEFAULT 'Pending',
    ApplicationDate DATE,
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID),
    FOREIGN KEY (InternshipID) REFERENCES Internships(InternshipID)
);

-- Table to store notifications for users
CREATE TABLE Notifications (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Message VARCHAR(255),
    SentDate DATE,
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID)
);






DELIMITER ##
--PROCEDURE TO ADD USER
CREATE OR REPLACE PROCEDURE addUser(
   
    IN FirstName VARCHAR(100),
    IN LastName VARCHAR(100),
    IN Email VARCHAR(255),
    IN University VARCHAR(255),
    IN GraduationYear INT,
    IN Location VARCHAR(255)
)
BEGIN
    INSERT INTO UserProfiles ( FirstName, LastName, Email, University, GraduationYear, Location)
    VALUES ( FirstName, LastName, Email, University, GraduationYear, Location);
END##



--TRIGGER TO ADD USER TO USERLOG

CREATE OR REPLACE TRIGGER addToUserLog AFTER INSERT ON UserProfiles
FOR EACH ROW
BEGIN
IF NEW.userID NOT IN (SELECT userID from USERLOG) THEN
INSERT INTO USERLOG(USERID , Email) VALUES(NEW.userID , NEW.Email);
END IF;
END##

--PROCEDURE TO ADD OR UPDATE PASSWORD IN USER LOG

CREATE OR REPLACE PROCEDURE setPassword(IN Id INT , Pass VARCHAR(30))
BEGIN
    SET @hashed_password = SHA2(Pass, 256); 
    UPDATE userLog SET PASSWORD = @hashed_password WHERE userId = Id;
END##




-- update internship
CREATE OR REPLACE PROCEDURE updateInternshipDetails(
    IN id INT,
    IN newTitle VARCHAR(255),
    IN newDescription TEXT,
    IN newLocation VARCHAR(255),
    IN newDuration VARCHAR(50),
    IN newApplicationDeadline DATE
)
BEGIN
    UPDATE Internships
    SET 
        title = COALESCE(newTitle, title),
        description = COALESCE(newDescription, description),
        location = COALESCE(newLocation, location),
        duration = COALESCE(newDuration, duration),
        applicationDeadline = COALESCE(newApplicationDeadline, applicationDeadline)
    WHERE 
        InternshipID = id;
END ##



-- Ensure to set the delimiter correctly to avoid conflicts with semicolons in the procedure


-- Procedure to set company password
DELIMITER ##
CREATE OR REPLACE PROCEDURE setCompanyPassword(
    IN p_CompanyID INT,
    IN p_Password VARCHAR(255)
)
BEGIN
    SET @hashed_password = SHA2(p_Password, 256);
    UPDATE CompanyLog
    SET Password = @hashed_password
    WHERE CompanyID = p_CompanyID;
END ##
DELIMITER ;

-- Trigger to insert email and company ID into CompanyLog
DELIMITER ##
CREATE OR REPLACE TRIGGER insertCompanyLog
AFTER INSERT ON Companies
FOR EACH ROW
BEGIN
    INSERT INTO CompanyLog (CompanyID, Email)
    VALUES (NEW.CompanyID, NEW.Email);
END ##
DELIMITER ;


DELIMITER ##

CREATE OR REPLACE PROCEDURE insertResume(
    IN p_UserID INT,
    IN p_Summary TEXT,
    IN p_WorkExp TEXT,  -- Optional
    IN p_Skills TEXT,
    IN p_Certifications TEXT ,  -- Optional
    IN p_Projects TEXT   -- Optional
) -- numbers for certifications
BEGIN
    -- Insert resume data into the Resumes table, with NULL values for optional fields
    INSERT INTO Resumes (UserID, Summary, WorkExperience, Skills, Certifications, Projects)
    VALUES (p_UserID, p_Summary, 
            IFNULL(p_WorkExp, NULL), 
            p_Skills, 
            IFNULL(p_Certifications, NULL), 
            IFNULL(p_Projects, NULL)); --
END ##

DELIMITER ;


DELIMITER ##
CREATE OR REPLACE PROCEDURE getApplicationIDandStatusForUser (
    IN p_userid INT
) 


BEGIN
    SELECT 
        a.ApplicationID, 
        a.Status
    FROM 
        Applications a
    WHERE 
        a.UserID = p_userid;
END ##
DELIMITER ; 
   



DELIMITER ##

CREATE OR REPLACE PROCEDURE applyForInt (
    IN p_userid INT,
    IN p_internshipID INT
    
)
BEGIN
 
    IF EXISTS (
        SELECT 1 FROM applications WHERE userId = p_userid AND internshipId = p_internshipID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate applications found';
    ELSE
        
        INSERT INTO applications (userId, internshipId, applicationdate)
        VALUES (p_userid, p_internshipID, CURRENT_DATE());
    END IF; 
END ##

DELIMITER ;

--PROCEDURE TO ADD EDUCATION:

DELIMITER //

CREATE PROCEDURE AddEducation(
    IN p_UserID INT,
    IN p_Degree VARCHAR(255),
    IN p_Institution VARCHAR(255),
    IN p_StartYear INT,
    IN p_EndYear INT
)
BEGIN
    DECLARE p_DegreeLevel INT;

    -- Determine the DegreeLevel based on the Degree
    SET p_DegreeLevel = CASE
        WHEN p_Degree LIKE '%Diploma%' THEN 0
        WHEN p_Degree LIKE '%Bachelor%' THEN 1
        WHEN p_Degree LIKE 'B%' THEN 1
        WHEN p_Degree LIKE '%Master%' THEN 2
        WHEN p_Degree LIKE 'MBA%' THEN 2
        WHEN p_Degree LIKE '%PhD%' THEN 3
        ELSE p_Degree = 0
    END;

    -- Insert the new education record
    INSERT INTO Education (UserID, Degree, Institution, StartYear, EndYear, DegreeLevel)
    VALUES (p_UserID, p_Degree, p_Institution, p_StartYear, p_EndYear, p_DegreeLevel);
END //

DELIMITER ;



--Trigger to notify user that the application process is successfull
DELIMITER ##

CREATE OR REPLACE TRIGGER NotifyForApplication
AFTER INSERT ON applications
FOR EACH ROW
BEGIN
    INSERT INTO Notifications (userID, message, sentdate)
    VALUES (NEW.userID, 'APPLICATION SENT SUCCESSFULLY', CURRENT_DATE());
END ##

DELIMITER ; --not required 


--Procedure to update application status
DELIMITER ##
CREATE OR REPLACE PROCEDURE updateApplicationStatus (
    IN app_id  INT , 
    IN STATUS enum("Accepted" , "Rejected")
)
BEGIN 
    UPDATE APPLICATIONS set STATUS = STATUS WHERE applicationId = app_id;
END##
DELIMITER ;

DELIMITER ##

CREATE OR REPLACE TRIGGER NotifyAfterStatusUpdate
AFTER UPDATE ON applications
FOR EACH ROW
BEGIN 
    IF NEW.status = 'Rejected' THEN
        INSERT INTO Notifications (userID, message, sentDate) 
        VALUES (NEW.userID, 'Your application is Rejected', CURRENT_DATE());
    ELSE   
        IF NEW.status = 'Accepted' THEN
            INSERT INTO Notifications (userID, message, sentDate) 
            VALUES (NEW.userID, 'Your application is Accepted! Congrats', CURRENT_DATE());
        ELSE 
            UPDATE Notifications 
            SET status = 'Pending' 
            WHERE userID = NEW.userID;
        END IF;
    END IF;
END ##

DELIMITER ;

DELIMITER ##
CREATE OR REPLACE TRIGGER deleteapplicationOnDelInt BEFORE DELETE ON Internships 
FOR EACH ROW
BEGIN
DELETE FROM Applications WHERE internshipId = OLD.internshipId;
END ##

DELIMITER ;

DELIMITER ##
CREATE OR REPLACE PROCEDURE getCompanyInternships (
    IN P_companyID INT
)
BEGIN  
SELECT * FROM Internships WHERE companyID = companyID;
END ##


--CURSOR FOR RECOMMENDING INTERNSHIPS TO THE USER

DELIMITER //

-- CREATE  or REplace PROCEDURE sp_recommend_internships()
-- BEGIN
--     INSERT INTO Recommendations (UserID, InternshipID)
--     SELECT r.UserID, i.InternshipID
--     FROM Resumes r
--     JOIN Internships i ON i.Description LIKE CONCAT('%', r.Skills, '%');
-- END //

-- DELIMITER ;


CREATE OR PROCEDURE RecommendInternships(IN p_UserID INT, IN p_DesiredPosition VARCHAR(255))
BEGIN

    SELECT
        c.Name AS CompanyName,
        i.Title AS InternshipTitle,
        i.Description AS InternshipDescription,
        i.ApplicationDeadline
    FROM
        Internships i
    JOIN
        Companies c ON i.CompanyID = c.CompanyID
    WHERE
        i.Title LIKE CONCAT('%', p_DesiredPosition, '%')
        AND i.InternshipID NOT IN (

            SELECT InternshipID
            FROM Applications
            WHERE UserID = p_UserID
        );


DELIMITER ##
CREATE OR REPLACE FUNCTION getHighestEducatedUser(p_internshipID INT)
RETURNS INT
BEGIN
    DECLARE highest_educated_user_id INT;
    DECLARE highest_degree_level INT;

    SELECT 
        u.UserID, 
        MAX(e.DegreeLevel) INTO highest_educated_user_id, highest_degree_level
    FROM 
        Applications a
    JOIN 
        UserProfiles u ON a.UserID = u.UserID
    JOIN 
        Education e ON u.UserID = e.UserID
    WHERE 
        a.InternshipID = p_internshipID
    GROUP BY 
        u.UserID;

    RETURN highest_educated_user_id;
END ##
DELIMITER ;



-----




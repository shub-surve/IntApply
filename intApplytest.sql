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
    WorkExperience TEXT,
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
    Description TEXT
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

DELIMITER ;

--TRIGGER TO ADD USER TO USERLOG
DELIMITER ##
CREATE OR REPLACE TRIGGER addToUserLog AFTER INSERT ON UserProfiles
FOR EACH ROW
BEGIN
IF NEW.userID NOT IN (SELECT userID from USERLOG) THEN
INSERT INTO USERLOG(USERID , Email) VALUES(NEW.userID , NEW.Email);
END IF;
END##

--PROCEDURE TO ADD OR UPDATE PASSWORD IN USER LOG
DELIMITER ##
CREATE OR REPLACE PROCEDURE setPassword(IN Id INT , Pass VARCHAR(30))
BEGIN
    SET @hashed_password = SHA2(Pass, 256); 
    UPDATE userLog SET PASSWORD = @hashed_password WHERE userId = Id;
END##

DELIMITER ;

DELIMITER ##
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




DELIMITER ;
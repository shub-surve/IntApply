![intApply.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/78581573-0c0e-4d71-a082-7e1388af1f95/02530e9f-db13-44f4-bc56-4a71516afed0/intApply.png)

```sql
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
    ApplicationDate DATE DEFAULT Current_date(),
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID),
    FOREIGN KEY (InternshipID) REFERENCES Internships(InternshipID)
);

-- Table to store notifications for users
CREATE TABLE Notifications (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Message VARCHAR(255),
    SentDate DATE defa,
    FOREIGN KEY (UserID) REFERENCES UserProfiles(UserID)
);

```

### Overview of Database Flow

The flow of the database is designed to manage and facilitate an internship application system. This includes storing user profiles, company information, internships, applications, and notifications. The database flow typically involves several steps that align with user interactions and internal processes. Below is an explanation of how each table interacts and how data flows through the system.

### 1. **User Registration and Login**

- **UserProfiles Table**: When a new user registers, their personal information (like `FirstName`, `LastName`, `Email`, etc.) is stored in the `UserProfiles` table. The `UserID` is auto-generated upon successful registration.
- **USERLOG Table**: Upon registration, a corresponding entry is made in the `USERLOG` table for authentication purposes, including their `Email` and `Password`. The `UserID` from `UserProfiles` is used as a foreign key to maintain a relationship between profile data and login credentials.
    
    **Flow:**
    
    - User registers.
    - Data is added to both `UserProfiles` and `USERLOG` tables.
    - Users can log in using credentials stored in `USERLOG`.

### 2. **Company and Internship Management**

- **Companies Table**: Stores information about companies, including their `Name`, `Industry`, `Website`, and `Location`. Each company has a unique `CompanyID`.
- **Internships Table**: Companies can offer internships, and these internships are stored in the `Internships` table with details like `Title`, `Description`, `Location`, `Duration`, `ApplicationDeadline`, and the associated `CompanyID`.
    
    **Flow:**
    
    - A company is added to the `Companies` table.
    - Internships offered by the company are added to the `Internships` table, linking each internship to the corresponding `CompanyID`.

### 3. **Internship Applications**

- **Applications Table**: When a user applies for an internship, a new entry is created in the `Applications` table. This table captures the `UserID`, `InternshipID`, `Status` (such as 'Pending', 'Accepted', 'Rejected'), and `ApplicationDate`.
    
    **Flow:**
    
    - User finds an internship and applies.
    - An application record is created in the `Applications` table, linking the user and the internship.
    - The application status starts as 'Pending' and can be updated later.

### 4. **Notifications System**

- **Notifications Table**: Stores messages sent to users, such as updates on application status. It includes `UserID`, `Message`, and `SentDate`.
    
    **Flow:**
    
    - Whenever there is a significant event, like an application submission or a status change, a notification is generated and stored in the `Notifications` table.
    - Triggers handle the automatic generation of notifications based on specific actions (e.g., after inserting a new application or updating its status).

### 5 Procedures for the Database

1. **Procedure to Add a New User Profile (addUser())**: Adds a new user to the `UserProfiles` table and ensures that the email is unique.
2. **Procedure to set password (setPassword):** Sets password by taking in user id and password hashes the password and stores it in database.
3. **Procedure to Update Internship Details (updateInternshipDetails)**: Updates details for a specific internship in the `Internships` table, such as title, description, location, duration, or application deadline.
4. **Procedure to add an internship (addInternship):** Will have company id and all the inserting values. 
5. **Procedure to create or maintain resume (InsertResume):** Through this user can add his resume in a particular format.
6. **Procedure to apply for internship (ApplyForInt):**  Checks whether the applications exist or not if not then insert new application.
7. **Procedure to update status on applications (updateApplicationStatus):** Will take inputs of application id and status and will update the status of application
8. **Procedure to get application id and status of application (getApplicationIDandStatusForUser):** Will take user id and return table that has application number and the status of application.

### 5 Triggers for the Database

1. **Trigger To Insert into userLog after inserting in userProfile:** Userid , email will be added to userlog.
2. **Trigger After Inserting a New Application (NotifyForApplication)**: Automatically sends a notification to the user confirming the receipt of their internship application.
3. **Triggers to notify the user about the status update on application (NotifyAfterStatusUpdate):** After the procedure updateApplicationStatus will insert new notification about status update.
4. **Trigger After Deleting an Internship from `Internships`  (deleteapplicationOnDelInt)**: Automatically deletes any applications associated with the deleted internship to maintain data consistency.

1. **Procedure to Retrieve Company Internships**: Fetches all internships offered by a specific company, including details such as internship title, location, duration, and application deadline.

Function to get no of employees enrolled and their education

1. **Trigger Before Deleting a Company from `Companies`**: Checks if there are any active internships or applications associated with the company and prevents deletion if there are.
2. **Trigger After Deleting an Internship from `Internships`**: Automatically deletes any applications associated with the deleted internship to maintain data consistency.

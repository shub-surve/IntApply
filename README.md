# IntApply
### Overview of Database Flow

The flow of the database is designed to manage and facilitate an internship application system. This includes storing user profiles, company information, internships, applications, and notifications. The database flow typically involves several steps that align with user interactions and internal processes. Below is an explanation of how each table interacts and how data flows through the system.

### 1. **User Registration and Login**

- **UserProfiles Table**: When a new user registers, their personal information (like `FirstName`, `LastName`, `Email`, etc.) is stored in the `UserProfiles` table. The `UserID` is auto-generated upon successful registration.
- **USERLOG Table**: Upon registration, a corresponding entry is made in the `USERLOG` table for authentication purposes, including their `Email` and `Password`. The `UserID` from `UserProfiles` is used as a foreign key to maintain a relationship between profile data and login credentials.
    
    **Flow:**
    
    - User registers.
    - Data is added to both `UserProfiles` and `USERLOG` tables.
    - User can log in using credentials stored in `USERLOG`.

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
4. **Procedure to add an internship:** Will have company id and all the de
5. **Procedure to Apply for an Internship ()**: Adds a new entry in the `Applications` table for a user applying for a specific internship, checking for existing applications to avoid duplicates.
6. **Procedure to create or maintain resume (InsertResume):** Through this user can add his resume in a particular format.

### 5 Triggers for the Database

1. **Trigger To Insert into userLog after inserting in userProfile:** Userid , email will be added to userlog.
2. **Trigger After Inserting a New Application**: Automatically sends a notification to the user confirming the receipt of their internship application.

1. **Procedure to Retrieve Company Internships**: Fetches all internships offered by a specific company, including details such as internship title, location, duration, and application deadline.
2. **Procedure to Change Application Status**: Updates the status of an application in the `Applications` table (e.g., from 'Pending' to 'Accepted' or 'Rejected') and automatically triggers a notification to the user.

1. **Trigger After Updating Application Status in `Applications`**: Creates a notification for the user whenever there is a change in their application status (e.g., from 'Pending' to 'Accepted').
2. **Trigger Before Deleting a Company from `Companies`**: Checks if there are any active internships or applications associated with the company and prevents deletion if there are.
3. **Trigger After Deleting an Internship from `Internships`**: Automatically deletes any applications associated with the deleted internship to maintain data consistency.

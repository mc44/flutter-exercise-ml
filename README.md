# flutter_exercise_ml by Marc Fajardo

# Equipment Management App

This Flutter app is designed to help manage equipment requests, track equipment status, and streamline the approval process for equipment requests. Below are the key features and functionalities of this application.

## Equipment Details and Request

- [x] Upon clicking a specific equipment, the user should be able to view all the details of the equipment. 
  - In the redirection screen, the user should be able to see a "Request" button if the equipment is from the FIRST list.
  - If the equipment is from the SECOND list, no "Request" button should be seen, but the details of the employee who requested it should be seen in the details page.

## Data Storage

- [x] The data of the app is saved and fetched from Firebase, ensuring real-time data synchronization.

## Request Submission

- [x] Upon clicking the "Request" button, the user should be able to fill out the form about his/her details and request details (schedule, purpose, etc.).

## Equipment Lists

- [x] There should be 2 lists:
  - FIRST - list of equipment that can be requested.
  - SECOND - list of equipment that are already assigned to an employee.

## Equipment Details Display

- [x] The app can display the list of equipment with the following details:
  - Equipment Code
  - Equipment Specs
  - Description
  - Picture

## Collections or Database Specification

### Users Collection
- Name
- Number
- Email
- Role

### Equipment Collection
- Code
- Specs
- Description
- Picture
- Assigned

### Request Collection
- User_id
- Name
- Purpose
- equipment_id
- request_status

## Generated Features

### Employee Role
- [x] Request Equipment
- [x] View both lists

### Admin Role
- [x] Approve pending requests
- [x] View both lists

## Pages

- [x] Select user to Log in
- [x] Register user

### Profile Page
- [x] If no name yet, input name and other information

### Equipments Page
- [x] Top filter: 1. Available, 2. Assigned

### Product Detail Page
- [x] View to whom it is assigned
- [x] See request details and reasons, approve or not approve (admin)
- [x] Remove other requests if already assigned
- [x] Requests if unassigned
- [x] Information layout

### Requester Form Page
- [x] Request purpose
- [x] Auto-fill user information
- [x] UserID

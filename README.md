# NoteNook

NoteNook is a cross-platform note management application developed using Flutter and Node.js. The application enables users to create, organize, and manage notes efficiently while also providing communication and media-sharing features.

## Features

- User Authentication (Register & Login)
- Create, Edit, and Delete Notes
- Folder-Based Note Organization
- Chat System Between Users
- Media Upload and Sharing
- User Profile Management
- User Directory
- Responsive Cross-Platform Interface
- Secure API Authentication using JWT

---

## Technology Stack

### Frontend
- Flutter
- Dart

### Backend
- Node.js
- Express.js

### Database
- MySQL (XAMPP)

---

## Project Structure

```text
NoteNook
│
├── frontend
│   ├── lib
│   │   ├── pages
│   │   ├── services
│   │   ├── utils
│   │   └── widgets
│   ├── assets
│   ├── android
│   ├── ios
│   └── ...
│
├── backend
│   ├── config
│   ├── controllers
│   ├── database
│   │   └── mhs_lec.sql
│   ├── middleware
│   ├── routes
│   ├── uploads
│   ├── package.json
│   └── server.js
│
└── README.md
```

---

## Prerequisites

Before running this project, make sure the following software is installed:

- Flutter SDK
- Dart SDK
- Node.js
- npm
- XAMPP
- MySQL
- Git

---

## Database Setup

This project uses MySQL through XAMPP.

### Step 1 - Start XAMPP

Open XAMPP Control Panel and start:

- Apache
- MySQL

### Step 2 - Create Database

Open phpMyAdmin and create a new database:

```sql
Mhs_Lec
```

### Step 3 - Import Database

Import the SQL file located in:

```text
backend/database/mhs_lec.sql
```

Steps:

1. Open phpMyAdmin.
2. Select database `Mhs_Lec`.
3. Click **Import**.
4. Choose `backend/database/mhs_lec.sql`.
5. Click **Go**.
6. Wait until the import process completes.

---

## Backend Setup

Navigate to backend directory:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file inside the backend folder:

```env
PORT=3000

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=Mhs_Lec

JWT_SECRET=your_secret_key
```

Start the backend server:

```bash
npm start
```

or

```bash
node server.js
```

The backend server will run on:

```text
http://localhost:3000
```

---

## Frontend Setup

Navigate to frontend directory:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## API Configuration

Before running the frontend application, update the API base URL to match the IPv4 address of the machine running the backend server.

Example:

```dart
const String baseUrl = "http://192.168.1.10:3000";
```

You can find your IPv4 address using:

```bash
ipconfig
```

Look for:

```text
IPv4 Address
```

Replace the existing API URL with your local IPv4 address.

---

## Demo Files

Sample uploaded files used for testing and demonstration are stored in:

```text
backend/uploads
```

These files are included to support media-related application features.

---

## Environment Variables

Example configuration:

```env
PORT=3000

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=Mhs_Lec

JWT_SECRET=your_secret_key
```

A sample configuration file is also provided:

```text
backend/.env.example
```

---

## Running the Application

### Start Backend

```bash
cd backend
npm install
npm start
```

### Start Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Contributors

- Yupriando

---

## Academic Purpose

This project was developed as part of a university coursework/project assignment and is intended for educational purposes.

---

## License

This project is intended for academic and learning purposes only.

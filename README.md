# NoteNook

NoteNook is a cross-platform note management application developed using Flutter and Node.js. The application allows users to create, organize, and manage notes efficiently while also providing communication and media-sharing features.

## Features

- User Authentication (Register & Login)
- Create, Edit, and Delete Notes
- Organize Notes with Folders
- Real-time Chat System
- Media Upload and Sharing
- User Profile Management
- User Directory
- Responsive Cross-Platform Interface

## Technology Stack

### Frontend
- Flutter
- Dart

### Backend
- Node.js
- Express.js

### Database
- MySQL

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
│   └── ...
│
├── backend
│   ├── config
│   ├── controllers
│   ├── middleware
│   ├── routes
│   ├── database
│   ├── uploads
│   └── ...
│
└── README.md
```

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/Yupriando/NoteNook.git
cd NoteNook
```

---

## Backend Setup

Navigate to backend folder:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create `.env` file based on `.env.example`:

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

---

## Frontend Setup

Navigate to frontend folder:

```bash
cd frontend
```

Install Flutter packages:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## API Configuration

Before running the application, update the API Base URL in the frontend configuration to match the IPv4 address of the machine running the backend server.

Example:

```dart
const String baseUrl = "http://192.168.x.x:3000";
```

---

## Demo Data

The repository includes sample uploaded media files located in:

```text
backend/uploads
```

These files are included to support demonstration and testing of media-related features.

---

## Contributors

- Yupriando

## License

This project was developed for academic and educational purposes.

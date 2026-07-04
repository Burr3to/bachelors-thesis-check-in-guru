# 🎓 Bachelor's Thesis: Check-In Guru

[![Live Demo](https://img.shields.io/badge/Live_Demo-Check--In_Guru-blue?style=for-the-badge)](https://checkin.fit.vutbr.cz/checkin/welcome)
[![Thesis Details](https://img.shields.io/badge/Thesis_Evaluation-VUT_FIT-orange?style=for-the-badge)](https://www.vut.cz/studenti/zav-prace/detail/172215)

**Check-In Guru** is a modern web-based task management and attendance application developed as a Bachelor's Thesis at the Faculty of Information Technology, Brno University of Technology (FIT BUT).

The system is designed to simplify the process of assigning tasks to groups of users and providing the author with a real-time overview of their completion status. It eliminates unnecessary friction in user interaction while maintaining high data integrity, dynamic access control, and a fully responsive UI.

## Key Features

* **Two Task Completion Modes:**
    * 👥 **Collaborative Mode:** A shared task list where completing a task by one user saves work for the rest of the group. Ideal for team coordination and shared responsibilities.
    * 👤 **Individual Mode:** Each participant receives their own isolated copy of the task list to complete independently.
* **Flexible Access Control:** Tasks can be configured as completely public (accessible via a unique hash link), restricted to authenticated Google users, or strictly limited to specific email domains (e.g., `@vutbr.cz`).
* **Real-Time Synchronization:** Powered by SignalR WebSockets. The author's dashboard and collaborative lists update instantly without needing to refresh the page.
* **Smart Email Invitations:** The system automatically extracts email addresses from raw text, validates target DNS/MX records to prevent bounces, and sends invitations asynchronously in the background.
* **Rich Text Support:** Tasks can be formatted using a rich text editor (Flutter Quill), saved safely as platform-independent Delta JSON.

##  Technology Stack

* **Frontend:** [Flutter Web](https://flutter.dev/web) (Dart), Riverpod (State Management), GoRouter, Dio/Retrofit.
* **Backend:** [.NET 9](https://dotnet.microsoft.com/) (ASP.NET Core Web API), Entity Framework Core.
* **Database:** PostgreSQL 17 (Dockerized).
* **Authentication:** Firebase Auth (Google Sign-In) integrated with custom backend JWT & HttpOnly Cookie session management (Silent Refresh).
* **Real-Time:** ASP.NET Core SignalR.

##  Architecture Highlights

* **Template-Instance Pattern:** The database cleanly separates task definitions (Templates) from user progress (Instances) to efficiently handle data scaling for both Collaborative and Individual modes without redundant rows.
* **Reactive UI (Signal-then-Fetch):** The Flutter frontend utilizes a reactive data flow. SignalR only notifies the client about data changes, triggering Riverpod to invalidate the local state and fetch fresh data via REST API. This ensures the UI is perfectly synced with the database as the single source of truth.

---

## Local Development Setup

### 1. Prerequisites
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### 2. Database Setup
Run the following command in the root directory to start the PostgreSQL 17 container:
```bash  
docker-compose up -d
```
The database will be available at `localhost:5432` (User: `checkin_admin`, DB: `checkin_local_db`).

### 3. Backend Configuration (Secrets)
Sensitive keys are managed via **.NET Secret Manager**. Navigate to `CheckIn.Api.App/` and set:
```bash
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=checkin_local_db;Username=checkin_admin;Password=moje_silne_heslo123"
dotnet user-secrets set "Jwt:Key" "YOUR_STRONG_SECRET_KEY"
dotnet user-secrets set "Authentication:Google:ClientId" "YOUR_GOOGLE_ID"
dotnet user-secrets set "Authentication:Google:ClientSecret" "YOUR_GOOGLE_SECRET"
dotnet user-secrets set "FirebaseAdmin:ServiceAccountJson" "{...content of your firebase-adminsdk.json...}"
```

### 4. Frontend Configuration
The frontend automatically toggles between local and production API URLs based on the build mode (`kReleaseMode`):
- **Development:** `https://localhost:7084/`
- **Release:** `https://checkin.fit.vutbr.cz/checkin/`

**Firebase for Web:**
To use your own Firebase project, you must update `checkin_frontend/lib/firebase_options.dart` with your web credentials (API Key, App ID, etc.) or run `flutterfire configure`.

### 5. Running the Application
**Apply Migrations:**
```bash
cd CheckIn.Api.App
dotnet run -- migrate
```

**Run Backend:**
```bash
dotnet run
```

**Run Frontend:**
```bash
cd checkin_frontend
flutter run -d chrome
```

---  

## Production Deployment (Ubuntu + Nginx)

The application is deployed on an Ubuntu server using Nginx as a reverse proxy.

### 1. Configuration Templates
Templates for server deployment are located in the `/deployment` directory:
- `nginx/checkin.conf`: Nginx site configuration with SSL and proxy rules.
- `linux/start_api.example.sh`: Bash script to export production environment variables and start the DLL.
- `linux/run_migrations.example.sh`: Bash script to run EF Core migrations on the server.

### 2. Deployment Scripts (PowerShell)
Automation scripts are located in the root directory:
- `./b.ps1`: Builds the backend, packs it into `backend.tar.gz`, uploads it via SCP, and triggers migrations on the server.
- `./f.ps1`: Builds the Flutter web app with `--base-href "/checkin/"`, packs it, and uploads it to the server.

*Note: Update the SSH alias (`checkin`) and server paths in these scripts before use.*

### 3. CORS & Security
The backend `Program.cs` contains an `allowedOrigins` array. Ensure your production domain is listed there to prevent CORS errors. Production secrets are passed via environment variables in `start_api.sh`.

---  
**Author:** Jakub Fiľo - xfiloja00
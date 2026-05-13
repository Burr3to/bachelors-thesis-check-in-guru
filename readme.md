# CheckIn System

A web-based attendance and task management system built with **ASP.NET Core 9** (Backend), **Flutter Web** (Frontend), and **PostgreSQL**.

## Project Structure
- `CheckIn.Api.App/` - Entry point for the ASP.NET Core API.
- `CheckIn.Api.Bl/` - Business Logic layer.
- `CheckIn.Api.Dal/` - Data Access layer (Entity Framework Core).
- `checkin_frontend/` - Flutter Web application.
- `deployment/` - Nginx and Linux deployment templates.
- `docker-compose.yml` - Infrastructure for local development (Database).

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
The application requires several configuration keys to function correctly. For local development, these should be stored securely using the **.NET Secret Manager**.

**Required Keys:**
- **ConnectionStrings:DefaultConnection**: PostgreSQL connection string (points to the Docker container).
- **ClientUrl**: Root URL of the frontend application (used for generating links, e.g., in emails).
- **Jwt:Key**: A secret string used to sign JWT tokens (minimum 32 characters).
- **Authentication:Google:ClientId / ClientSecret**: Credentials for Google OAuth 2.0.
- **FirebaseAdmin:ServiceAccountJson**: The entire content of your Firebase Service Account JSON file as a single string.

**Configuration Commands:**
Navigate to the `CheckIn.Api.App/` directory and run the following commands to set up your environment:

```bash
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=checkin_local_db;Username=checkin_admin;Password=moje_silne_heslo123"
dotnet user-secrets set "ClientUrl" "http://localhost:5000/checkin/p/"
dotnet user-secrets set "Jwt:Key" "YOUR_VERY_LONG_SECRET_KEY_FOR_LOCAL_DEV"
dotnet user-secrets set "Authentication:Google:ClientId" "YOUR_GOOGLE_ID.apps.googleusercontent.com"
dotnet user-secrets set "Authentication:Google:ClientSecret" "YOUR_GOOGLE_SECRET"
dotnet user-secrets set "FirebaseAdmin:ServiceAccountJson" "{ \"type\": \"service_account\", ... }"
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
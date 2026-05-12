


Rozumiem, pri toľkých informáciách sa to môže ľahko pomiešať. Tvoj návrh mal navyše zlé číslovanie a neuzavretý blok kódu (to by ti rozbilo formátovanie na Githube).

Aby v tom bol úplný poriadok, odpoviem ti najprv na otázku ohľadom **User Secrets vs. .json**:
Pravidlo je takéto: **Všetky heslá a kľúče idú do User Secrets**. Do `appsettings.Development.json` nechaj iba prázdne texty (napr. `"project_id": "REPLACE_ME"`), aby tam ten kľúč existoval, ale nebol v ňom tvoj skutočný údaj. V README to teraz vysvetľujem veľmi jasne, aby to pochopil aj ten, kto si to stiahne.

Tu je **kompletný, opravený a finálny `README.md`**. Obsahuje už aj vyriešené formátovanie, vysvetlenie konfigurácie, poznámku o CORS aj opravený Nginx.

Môžeš ho celý zobrať a skopírovať (od `# CheckIn System` až po koniec):


# CheckIn System

A web-based attendance and task management system built with **ASP.NET Core 9** (Backend), **Flutter Web** (Frontend), and **PostgreSQL**.

## Project Structure
- `CheckIn.Api.App/` - Entry point for the ASP.NET Core API.
- `CheckIn.Api.Bl/` - Business Logic layer.
- `CheckIn.Api.Dal/` - Data Access layer (Entity Framework Core).
- `checkin_frontend/` - Flutter Web application.
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
The database will be available at `localhost:5432` with credentials defined in `docker-compose.yml`.

### 3. Backend Configuration (Security Note)
For security reasons, actual passwords, Firebase credentials, and Google Auth secrets are **not included** in the source code. The file `appsettings.Development.json` only contains empty placeholders.

To run the application locally, you must provide your own credentials using the **.NET Secret Manager**. Navigate to `CheckIn.Api.App/` and run:

```bash
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=checkin_local_db;Username=checkin_admin;Password=moje_silne_heslo123"
dotnet user-secrets set "Jwt:Key" "YOUR_STRONG_SECRET_KEY_MIN_32_CHARS"
dotnet user-secrets set "Authentication:Google:ClientId" "YOUR_GOOGLE_CLIENT_ID"
dotnet user-secrets set "Authentication:Google:ClientSecret" "YOUR_GOOGLE_CLIENT_SECRET"
```
*Note for Firebase:* You also need to provide the entire content of your Firebase Service Account JSON file as a single string to the `FirebaseAdmin:ServiceAccountJson` secret.

### 4. Database Migrations
This project uses Entity Framework Core migrations. To apply migrations to the database (especially during first setup or deployment), run the application with the `migrate` argument. This will create the necessary tables and then exit:
```bash
cd CheckIn.Api.App
dotnet run -- migrate
```

### 5. Running the Application
**Backend:**
```bash  
cd CheckIn.Api.App  
dotnet run  
```  

**Frontend:**
```bash  
cd checkin_frontend  
flutter run -d chrome  
```  
  
---  

## Production Deployment

The application is designed to be hosted on a **Linux server (Ubuntu)** using **Nginx** as a reverse proxy.

### Important Note Regarding CORS
By default, the backend API explicitly allows Cross-Origin Resource Sharing (CORS) only for specific domains (like `http://localhost:5000` and the university server). **If you plan to deploy this application to a custom domain**, you must edit the `allowedOrigins` array in `CheckIn.Api.App/Program.cs` before building the backend. Configuration templates for Nginx and the server startup script can be found in the /deployment directory

### 1. Server Requirements
- Ubuntu 22.04 LTS or newer.
- Nginx installed and configured.
- .NET 9 Runtime installed.
- PostgreSQL 17 database.

### 2. Build and Transfer
You can use the provided PowerShell scripts (`b.ps1` for backend, `f.ps1` for frontend) to automate the deployment.
- **Backend (`b.ps1`):** Publishes the app, creates a `.tar.gz` archive, uploads it via SCP, and runs database migrations automatically using `./CheckIn.Api.App migrate` on the server.
- **Frontend (`f.ps1`):** Builds the Flutter web app with the `--base-href "/checkin/"` flag and uploads it to the web server directory.

*Note: You will need to update the SSH alias (`checkin`) and remote paths in these scripts to match your server configuration.*

### 3. Nginx Configuration
To serve both the frontend and backend under the same domain, use the following Nginx logic:
- Map `/checkin/` to the static files of the Flutter build.
- Map `/checkin/api/` as a proxy to the Kestrel server (running by default on port 5005).

Example Nginx snippet:
```nginx  
location /checkin/ {  
    alias /path/to/your/frontend/;
    index index.html;
    try_files $uri $uri/ /checkin/index.html;
}  
  
location /checkin/api/ {  
    rewrite ^/checkin/api/(.*)$ /api/$1 break;
    proxy_pass http://localhost:5005;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection keep-alive;
    proxy_set_header Host $host;
}  
```  

### 4. Environment Variables
On the production server, sensitive configuration is passed via environment variables (e.g., inside a startup script or a `systemd` service file). Ensure `ASPNETCORE_ENVIRONMENT` is set to `Production`.
```bash  
export ConnectionStrings__DefaultConnection='Host=localhost;Port=5432;...'  
export Jwt__Key='YOUR_PRODUCTION_KEY'
export ASPNETCORE_URLS=http://localhost:5005  

# Run the app
dotnet CheckIn.Api.App.dll  
```  
  
---  
**Author:** Jakub Fiľo
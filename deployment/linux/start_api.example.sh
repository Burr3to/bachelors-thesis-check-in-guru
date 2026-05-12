#!/bin/bash

# --- DATABASE CONFIGURATION ---
export ConnectionStrings__DefaultConnection='Host=localhost;Port=5432;Database=checkin_db;Username=postgres;Password=YOUR_PRODUCTION_PASSWORD'

# --- SECURITY & JWT ---
# Use a long random string (min 32 chars) for Jwt__Key
export Jwt__Key='YOUR_VERY_LONG_SECRET_JSON_WEB_TOKEN_KEY'
export Jwt__Issuer='https://checkin.fit.vutbr.cz/checkin/api'
export Jwt__Audience='https://checkin.fit.vutbr.cz/checkin'

# --- FIREBASE CONFIGURATION ---
# Important: This must be the entire content of your Firebase Service Account JSON file.
export FirebaseAdmin__ServiceAccountJson='{
  "type": "service_account",
  "project_id": "YOUR_PROJECT_ID",
  "private_key_id": "YOUR_PRIVATE_KEY_ID",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_KEY_HERE\n-----END PRIVATE KEY-----\n",
  "client_email": "YOUR_CLIENT_EMAIL",
  "client_id": "YOUR_CLIENT_ID",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-email",
  "universe_domain": "googleapis.com"
}'

# --- EMAIL SETTINGS (SMTP) ---
export EmailSettings__Email='your-system-email@gmail.com'
export EmailSettings__Password='your-app-specific-password'
export EmailSettings__Host='smtp.gmail.com'
export EmailSettings__Port='587'

# --- ASP.NET CORE SETTINGS ---
export ASPNETCORE_ENVIRONMENT=Production
export ASPNETCORE_URLS=http://localhost:5005

# --- RUNNING THE APPLICATION ---
# Adjust the path to where your published backend is located
echo "Starting CheckIn API..."
dotnet /home/YOUR_USER/deploy/checkin-app/backend/CheckIn.Api.App.dll
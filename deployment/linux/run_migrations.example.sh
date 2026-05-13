#!/bin/bash
# Load environment variables from the startup script
source ./start_api.sh

echo "Starting database migration..."
# Run the DLL with 'migrate' argument
dotnet /home/YOUR_USER/deploy/checkin-app/backend/CheckIn.Api.App.dll migrate

echo "Migration finished."
#!/bin/bash

# Momentum App - Chrome Development Server
# This script runs the Flutter app in Chrome with port 5000

echo "🚀 Starting Momentum App in Chrome..."
echo "📍 URL: http://localhost:5000"
echo "⏳ Please wait, this may take a few minutes for the first run..."
echo ""

# Check if Chrome is available
if ! command -v google-chrome &> /dev/null && ! command -v chrome &> /dev/null; then
    echo "⚠️  Chrome not found. Make sure Chrome is installed."
    exit 1
fi

# Run Flutter app in Chrome with port 5000
flutter run -d chrome --web-port 5000 --hot

echo ""
echo "✅ App is now running at http://localhost:5000"
echo "🔥 Hot reload is enabled - your changes will be reflected automatically"
echo "🛑 Press Ctrl+C to stop the server"

#!/usr/bin/env python3
"""
Simple HTTP server to serve the Flutter web build
Run this script to serve the app locally
"""

import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

# Configuration
PORT = 8080
DIRECTORY = "build/web"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Add CORS headers for development
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def main():
    # Check if build directory exists
    if not os.path.exists(DIRECTORY):
        print(f"❌ Build directory '{DIRECTORY}' not found!")
        print("Please run 'flutter build web' first.")
        return
    
    # Change to the project directory
    os.chdir(Path(__file__).parent)
    
    # Start server
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"🚀 HabitVerse is running at http://localhost:{PORT}")
        print(f"📁 Serving files from: {DIRECTORY}")
        print("Press Ctrl+C to stop the server")
        
        # Open browser automatically
        webbrowser.open(f"http://localhost:{PORT}")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")

if __name__ == "__main__":
    main()

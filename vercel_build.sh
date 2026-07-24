#!/bin/bash

# Clone Flutter stable branch
echo "Cloning Flutter..."
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to the PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Run flutter doctor to initialize
echo "Initializing Flutter..."
flutter doctor

# Build the web app
echo "Building Flutter Web..."
flutter build web

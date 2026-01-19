#!/bin/bash
# update.sh - One-command update for the streaming setup

set -e  # Exit on error

# Directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "🔄 Checking for updates..."
git fetch origin

HEADHASH=$(git rev-parse HEAD)
UPSTREAMHASH=$(git rev-parse @{u})

if [ "$HEADHASH" != "$UPSTREAMHASH" ]; then
    echo "⚡ Update found! Pulling changes..."
    git pull origin master
    
    echo "🏗️  Rebuilding containers..."
    # --build: Rebuild the image with new code
    # --remove-orphans: Clean up old containers if services changed
    docker-compose up -d --build --remove-orphans
    
    echo "🧹 Cleaning up old images..."
    docker image prune -f
    
    echo "✅ Update complete! System is running the latest version."
else
    echo "✅ System is already up to date."
fi

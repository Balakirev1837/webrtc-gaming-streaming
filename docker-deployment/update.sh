#!/bin/bash
# update.sh - Robust update script for WebRTC Gaming Streaming

set -e  # Exit on error

# Directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Check for flags
FORCE=0
REPAIR=0

for arg in "$@"; do
    if [ "$arg" == "--force" ]; then
        FORCE=1
    fi
    if [ "$arg" == "--repair" ]; then
        REPAIR=1
    fi
done

if [ $REPAIR -eq 1 ]; then
    echo "🛠️  Repair mode enabled: Pruning Docker builder cache..."
    echo "   This fixes 'parent snapshot does not exist' and other cache corruption errors."
    docker builder prune --all --force
fi

echo "🔄 Checking for updates..."
git fetch origin

LOCAL=$(git rev-parse HEAD)
# Assumes we are tracking origin/master. 
# If on a different branch, this might need adjustment, but safe for default deployment.
REMOTE=$(git rev-parse origin/master)

if [ "$LOCAL" != "$REMOTE" ] || [ $FORCE -eq 1 ] || [ $REPAIR -eq 1 ]; then
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "⚡ Code update found!"
        
        # Handle local changes safely
        if [ -n "$(git status --porcelain)" ]; then 
            echo "⚠️  Local changes detected in git tracked files. Stashing them to ensure clean update..."
            git stash
        fi
        
        echo "⬇️  Pulling changes..."
        git pull origin master
    else
        echo "⚡ Force update/repair requested. Proceeding with rebuild..."
    fi
    
    echo "📥 Pulling latest external images (Broadcast Box)..."
    # Essential to ensure the base images and external services are up to date
    docker compose pull
    
    echo "🏗️  Rebuilding and restarting containers..."
    # --build: Rebuild the local streamer image
    # --force-recreate: Stop and recreate containers to ensure no stale state remains
    # --remove-orphans: Remove containers for services that were removed from docker-compose.yml
    if ! docker compose up -d --build --force-recreate --remove-orphans; then
        echo "❌ Error: Service startup failed."
        echo "   If you see 'failed to prepare extraction snapshot' or 'parent snapshot does not exist',"
        echo "   it indicates a corrupted Docker cache."
        echo "   👉 Run './update.sh --repair' to fix this."
        exit 1
    fi
    
    echo "🧹 Cleaning up..."
    # Prune dangling images to save space (important for mini PCs)
    docker image prune -f
    
    echo "✅ Update complete! Services are running the latest version."
else
    echo "✅ System is already up to date."
    echo "   (Run './update.sh --force' to force a rebuild/restart)"
    echo "   (Run './update.sh --repair' to clear cache and rebuild)"
fi

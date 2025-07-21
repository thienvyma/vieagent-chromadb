#!/bin/bash

# 🚂 VIEAgent ChromaDB - Railway Startup Script
# Ensures ChromaDB is fully ready before accepting requests

set -e

echo "🚂 Starting VIEAgent ChromaDB on Railway..."

# 📁 Ensure data directory exists
mkdir -p /app/data
chmod 777 /app/data

# 🎯 Start ChromaDB in background
echo "🚀 Starting ChromaDB server..."
chroma run --host 0.0.0.0 --port 8000 --path /app/data &
CHROMA_PID=$!

# ⏳ Wait for ChromaDB to be fully ready
echo "⏳ Waiting for ChromaDB to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:8000/api/v1 > /dev/null 2>&1; then
        echo "✅ ChromaDB is ready and responding to API requests!"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo "❌ ERROR: ChromaDB failed to start within 30 seconds"
        kill $CHROMA_PID 2>/dev/null || true
        exit 1
    fi
    
    echo "⏳ Waiting... (attempt $i/30)"
    sleep 2
done

# 🔄 Keep the script running
echo "🔄 ChromaDB is running. Monitoring process..."
wait $CHROMA_PID 
#!/bin/bash

# 🚂 VIEAgent ChromaDB - Railway Startup Script
# Ensures proper environment variable handling and validation

set -e

# 🔧 Environment variable validation and defaults
CHROMA_HOST=${CHROMA_HOST:-0.0.0.0}
CHROMA_PORT=${PORT:-8000}
DATA_PATH=${PERSIST_DIRECTORY:-/app/data}

# 📝 Log startup configuration
echo "🚂 Starting VIEAgent ChromaDB on Railway..."
echo "📍 Host: ${CHROMA_HOST}"
echo "🔌 Port: ${CHROMA_PORT}"
echo "💾 Data Path: ${DATA_PATH}"

# 🔍 Validate port is numeric
if ! [[ "$CHROMA_PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ ERROR: PORT must be numeric, got: $CHROMA_PORT"
    exit 1
fi

# 📁 Ensure data directory exists
mkdir -p "$DATA_PATH"
chmod 777 "$DATA_PATH"

# 🎯 Start ChromaDB server with validated parameters
echo "🚀 Executing: chroma run --host $CHROMA_HOST --port $CHROMA_PORT --path $DATA_PATH"
exec chroma run --host "$CHROMA_HOST" --port "$CHROMA_PORT" --path "$DATA_PATH" 
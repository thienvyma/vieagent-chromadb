# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Standalone ChromaDB service for VIEAgent AI Platform

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Create data directory with proper permissions
RUN mkdir -p /app/chromadb_data && \
    chmod -R 777 /app/chromadb_data && \
    chown -R root:root /app/chromadb_data

# Install required packages
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Environment variables for Railway
ENV CHROMA_DB_IMPL=duckdb+parquet
ENV PERSIST_DIRECTORY=/app/chromadb_data
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV ANONYMIZED_TELEMETRY=false
ENV IS_PERSISTENT=1
ENV CHROMA_SERVER_CORS_ALLOW_ORIGINS=["*"]
ENV CHROMA_SERVER_AUTHN_PROVIDER=""
ENV CHROMA_SERVER_AUTHZ_PROVIDER=""

# Create startup script with logging
RUN echo '#!/bin/bash\n\
echo "🚂 Starting VIEAgent ChromaDB on Railway..."\n\
echo "====================================="\n\
echo "📁 Data directory: $PERSIST_DIRECTORY"\n\
echo "🌐 Host: $CHROMA_HOST:$CHROMA_PORT"\n\
echo "💾 Database implementation: $CHROMA_DB_IMPL"\n\
echo "🔒 CORS origins: $CHROMA_SERVER_CORS_ALLOW_ORIGINS"\n\
echo "📊 Telemetry: $ANONYMIZED_TELEMETRY"\n\
echo "====================================="\n\
\n\
# Ensure data directory exists with proper permissions\n\
mkdir -p $PERSIST_DIRECTORY\n\
chmod 777 $PERSIST_DIRECTORY\n\
\n\
# Print system info\n\
echo "🖥️  System info:"\n\
echo "   Memory: $(free -h | head -2 | tail -1)"\n\
echo "   Disk: $(df -h /app | tail -1)"\n\
echo "   User: $(whoami)"\n\
echo "   Working dir: $(pwd)"\n\
echo ""\n\
\n\
# Start ChromaDB with detailed logging\n\
echo "🚀 Starting ChromaDB server..."\n\
chroma run \\\n\
  --host $CHROMA_HOST \\\n\
  --port $CHROMA_PORT \\\n\
  --path $PERSIST_DIRECTORY \\\n\
  --log-config-path /dev/null\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose port
EXPOSE 8000

# Health check for Railway monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/heartbeat || exit 1

# Use startup script
CMD ["/app/start.sh"] 
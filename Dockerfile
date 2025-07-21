# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Complete ChromaDB configuration with CORS and proper health checks

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="3.0.0"

# Set working directory
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Create data directory for persistence
RUN mkdir -p /app/data && \
    chmod -R 777 /app/data

# 🔧 CHROMADB PRODUCTION CONFIGURATION
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV CHROMA_DB_IMPL=duckdb+parquet
ENV CHROMA_API_IMPL=chromadb.api.fastapi.FastAPI
ENV PERSIST_DIRECTORY=/app/data
ENV ANONYMIZED_TELEMETRY=false

# 🌐 CORS CONFIGURATION FOR EXTERNAL ACCESS
ENV CHROMA_SERVER_CORS_ALLOW_ORIGINS=["*"]
ENV CHROMA_SERVER_HOST=0.0.0.0
ENV CHROMA_SERVER_HTTP_PORT=8000
ENV CHROMA_SERVER_SSL_ENABLED=false

# 🔒 SECURITY CONFIGURATION
ENV CHROMA_SERVER_AUTH_PROVIDER=""
ENV CHROMA_SERVER_AUTH_CREDENTIALS=""

# Expose port for Railway
EXPOSE 8000

# 🏥 HEALTH CHECK - CORRECT ENDPOINT
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1 || exit 1

# 🎯 PRODUCTION START COMMAND
CMD ["chroma", "run", "--host", "0.0.0.0", "--port", "8000", "--path", "/app/data"] 
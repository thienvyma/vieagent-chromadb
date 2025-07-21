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

# Install required packages for health checks
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

# Expose port
EXPOSE 8000

# 🔧 FIXED: Use correct ChromaDB health check endpoint
# ChromaDB health check is at /api/v1, not /api/v1/heartbeat
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1 || exit 1

# 🔧 FIXED: Let ChromaDB base image handle startup with its default entrypoint
# The base image knows how to start ChromaDB properly 
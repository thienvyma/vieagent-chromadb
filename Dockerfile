# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Standalone ChromaDB service for VIEAgent AI Platform

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Create data directory for Railway persistent volume
# Railway will mount persistent storage at /data
RUN mkdir -p /data && \
    chmod -R 777 /data && \
    chown -R root:root /data

# Install required packages for health checks
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# 🔧 FIXED: Environment variables for Railway with persistent volume
ENV CHROMA_DB_IMPL=duckdb+parquet
ENV PERSIST_DIRECTORY=/data
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV PORT=8000
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
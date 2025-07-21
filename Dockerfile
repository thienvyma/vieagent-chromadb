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

# 🔧 RAILWAY-SPECIFIC: Environment variables for ChromaDB on Railway
ENV CHROMA_DB_IMPL=duckdb+parquet
ENV PERSIST_DIRECTORY=/data
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV PORT=8000
ENV IS_PERSISTENT=1
ENV ANONYMIZED_TELEMETRY=false
ENV CHROMA_SERVER_CORS_ALLOW_ORIGINS=["*"]
ENV CHROMA_SERVER_AUTHN_PROVIDER=""
ENV CHROMA_SERVER_AUTHZ_PROVIDER=""

# 🔧 RAILWAY-SPECIFIC: Reference variables for networking
ENV CHROMA_PUBLIC_URL=https://vieagent-chromadb-production.up.railway.app
ENV CHROMA_PRIVATE_URL=http://vietagent-chromadb.railway.internal:8000

# Expose port
EXPOSE 8000

# 🔧 RAILWAY-SPECIFIC: Let Railway handle start command with uvicorn
# Railway will use custom start command in deployment settings
# No CMD specified - Railway start command will override 
# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Railway-specific ChromaDB deployment pattern

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="2.0.0"

# Set working directory
WORKDIR /chroma

# Install required packages
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Create data directory for persistence
RUN mkdir -p /chroma/data && \
    chmod -R 777 /chroma/data

# 🔧 RAILWAY CHROMADB: Essential environment variables
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV CHROMA_DB_IMPL=duckdb+parquet
ENV CHROMA_API_IMPL=chromadb.api.fastapi.FastAPI
ENV PERSIST_DIRECTORY=/chroma/data
ENV ANONYMIZED_TELEMETRY=false

# Expose port for Railway
EXPOSE 8000

# 🏥 Health check to ensure ChromaDB is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1/heartbeat || exit 1

# 🎯 RAILWAY PATTERN: Direct ChromaDB start command
CMD ["chroma", "run", "--host", "0.0.0.0", "--port", "8000", "--path", "/chroma/data"] 
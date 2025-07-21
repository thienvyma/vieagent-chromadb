# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Simplified approach for reliable Railway deployment

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="1.0.4"

# Set working directory
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Create data directory for persistence
RUN mkdir -p /app/data && \
    chmod -R 777 /app/data

# Copy startup script and make it executable
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 🔧 RAILWAY CHROMADB: Essential environment variables
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV IS_PERSISTENT=1
ENV PERSIST_DIRECTORY=/app/data
ENV ANONYMIZED_TELEMETRY=false
ENV CHROMA_DB_IMPL=duckdb+parquet

# Expose port for Railway
EXPOSE 8000

# 🏥 Health check to ensure ChromaDB is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1 || exit 1

# 🎯 ENHANCED: Use startup script with health check
CMD ["/app/start.sh"] 
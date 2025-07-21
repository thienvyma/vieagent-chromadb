# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Fixed start command for ChromaDB server

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="1.0.2"

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
ENV PORT=8000
ENV CHROMA_HOST=0.0.0.0
ENV CHROMA_PORT=8000
ENV IS_PERSISTENT=1
ENV PERSIST_DIRECTORY=/app/data
ENV ANONYMIZED_TELEMETRY=false
ENV CHROMA_DB_IMPL=duckdb+parquet

# Expose port for Railway
EXPOSE 8000

# 🎯 FIXED: Use startup script for robust PORT handling
CMD ["/app/start.sh"] 
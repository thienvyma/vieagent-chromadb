# 🚂 VIEAgent ChromaDB - Railway Production Deployment
# Minimal configuration to avoid startup conflicts

FROM chromadb/chroma:latest

# Set metadata
LABEL maintainer="thienvyma@gmail.com"
LABEL description="Production ChromaDB service for VIEAgent Platform"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Install required packages for health checks
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# 🔧 MINIMAL: Only essential environment variables for Railway
ENV PORT=8000
ENV IS_PERSISTENT=1
ENV ANONYMIZED_TELEMETRY=false

# Expose port for Railway
EXPOSE 8000

# Let ChromaDB handle everything else with default settings 
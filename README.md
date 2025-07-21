# 🚂 VIEAgent ChromaDB - Railway Production Service

**Standalone ChromaDB vector database service for VIEAgent AI Platform**

---

## 🏗️ **Architecture Overview**

This is a **microservices separation** from the main VIEAgent platform:
- **Main App**: `ai-agent-platform/` → Vercel (Next.js)
- **Vector DB**: `vietagent-chromadb/` → Railway (ChromaDB)

---

## 🔧 **Railway Deployment**

### **1. Repository Connection**
```bash
# This repo is connected to:
GitHub: https://github.com/thienvyma/vieagent-chromadb.git
Railway: https://railway.com/project/ad7b3b57-800f-4e7f-b50c-fb53201b6ab8
```

### **2. Environment Variables**
No environment variables needed - all configured in Dockerfile.

### **3. 💾 Data Persistence Setup**

#### **⚠️ CRITICAL: Railway Volume Configuration**

ChromaDB stores vector data that **MUST persist** across container restarts. Railway provides **Persistent Volumes** for this:

##### **3.1. Railway Dashboard Steps:**
```bash
1. Go to Railway Project Dashboard
2. Click on your ChromaDB service
3. Navigate to "Settings" tab
4. Scroll to "Volumes" section
5. Click "Add Volume":
   - Volume Name: chromadb-data
   - Mount Path: /data
   - Size: 5GB (recommended minimum)
6. Click "Create Volume"
7. Redeploy the service
```

##### **3.2. Data Storage Structure:**
```bash
# Railway Volume Mount:
/data/                          # Railway persistent volume
├── chroma.sqlite3              # Main database file
├── [collection-uuid-1]/        # Vector collection 1
│   ├── header.bin
│   ├── data_level0.bin
│   └── index_metadata.pickle
├── [collection-uuid-2]/        # Vector collection 2
└── ...                         # More collections
```

##### **3.3. Data Persistence Features:**
- ✅ **Container Restart Safe**: Data survives deployments
- ✅ **Backup Compatible**: Volume can be snapshotted  
- ✅ **Scalable Storage**: Volume size can be increased
- ✅ **High Performance**: SSD-backed storage
- ⚠️  **Single Instance**: Current setup is single-node

---

## 🌍 **API Endpoints**

### **Production URLs**
```bash
Base URL: https://vietagent-chromadb-production.up.railway.app

# Health Checks:
GET /api/v1                     # API info & health
GET /api/v1/version            # ChromaDB version
GET /api/v1/heartbeat          # Simple heartbeat (may not exist)

# Collections:
GET /api/v1/collections        # List all collections
POST /api/v1/collections       # Create collection
GET /api/v1/collections/{id}   # Get collection details

# Vectors:  
POST /api/v1/collections/{id}/add     # Add vectors
POST /api/v1/collections/{id}/query   # Query vectors
POST /api/v1/collections/{id}/delete  # Delete vectors
```

### **Expected Responses**
```json
// GET /api/v1 (Health Check)
{
  "nanosecond heartbeat": 1672531200000000000
}

// GET /api/v1/collections (Empty DB)
[]

// GET /api/v1/version  
{
  "version": "0.5.23"
}
```

---

## 🧪 **Testing & Health Checks**

### **1. Basic Health Check**
```bash
curl https://vietagent-chromadb-production.up.railway.app/api/v1
# Expected: JSON response with nanosecond heartbeat
```

### **2. Version Check**
```bash
curl https://vietagent-chromadb-production.up.railway.app/api/v1/version
# Expected: {"version": "x.x.x"}
```

### **3. Collections Check** 
```bash
curl https://vietagent-chromadb-production.up.railway.app/api/v1/collections
# Expected: [] (empty array for new DB)
```

### **4. Python Client Test**
```python
import chromadb
from chromadb.config import Settings

# Connect to Railway ChromaDB
client = chromadb.HttpClient(
    host="vietagent-chromadb-production.up.railway.app",
    port=443,
    ssl=True,
    settings=Settings(
        chroma_api_impl="rest",
        chroma_server_ssl_enabled=True,
    )
)

# Test connection
print("Collections:", client.list_collections())
print("Version:", client.get_version())
```

---

## 🔐 **Security**

### **Current Configuration**
- **HTTPS**: ✅ Railway provides SSL termination
- **CORS**: ✅ Enabled for all origins (development)
- **Authentication**: ❌ Disabled (internal service)
- **Authorization**: ❌ Disabled (internal service)

### **Production Security Recommendations**
```bash
# For production, consider enabling:
- IP whitelisting (Railway network only)
- Token-based authentication
- Request rate limiting
- Network-level security (VPC)
```

---

## 🔄 **Integration with Main App**

### **Environment Variables for ai-agent-platform**
```bash
# Add to Vercel environment variables:
CHROMADB_HOST=vietagent-chromadb-production.up.railway.app
CHROMADB_PORT=443
CHROMADB_SSL=true
CHROMADB_API_BASE=https://vietagent-chromadb-production.up.railway.app
CHROMADB_MAX_CONNECTIONS=10
CHROMADB_CONNECTION_TIMEOUT=30000
CHROMADB_RETRY_ATTEMPTS=3
```

### **Next.js Connection Example**
```typescript
// lib/chromadb.ts
import { ChromaApi } from 'chromadb';

const chromaClient = new ChromaApi({
  basePath: process.env.CHROMADB_API_BASE!,
  // Add retry logic, timeout handling, etc.
});

export default chromaClient;
```

---

## 📊 **Monitoring & Performance**

### **Railway Metrics**
- CPU Usage
- Memory Usage  
- Disk Usage (/data volume)
- Network I/O
- Response Times

### **ChromaDB Metrics**
```bash
# Check database size:
curl https://vietagent-chromadb-production.up.railway.app/api/v1/collections

# Monitor collection count and sizes
# Add custom monitoring endpoints as needed
```

---

## 🚀 **Performance Considerations**

### **Current Setup**
- **RAM**: 512MB - 1GB (Railway default)
- **Storage**: 5GB SSD (configurable)
- **CPU**: Shared (Railway default)
- **Network**: Global CDN

### **Scaling Options**
```bash
# Railway Scaling:
1. Increase RAM (up to 32GB)
2. Increase volume size (up to 100GB+)  
3. Upgrade to dedicated CPU
4. Consider multiple regions
```

---

## 🔧 **Configuration**

### **Environment Variables (In Dockerfile)**
```dockerfile
ENV CHROMA_DB_IMPL=duckdb+parquet      # Storage backend
ENV PERSIST_DIRECTORY=/data            # Railway volume mount
ENV CHROMA_HOST=0.0.0.0               # Listen on all interfaces  
ENV CHROMA_PORT=8000                  # Internal port
ENV IS_PERSISTENT=1                   # Enable persistence
ENV ANONYMIZED_TELEMETRY=false        # Disable telemetry
```

### **Advanced Configuration**
```bash
# For advanced use cases, consider:
- Custom embedding functions
- Index configuration (HNSW parameters)
- Collection-specific settings
- Batch processing optimizations
```

---

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **1. "Not Found" Error**
```bash
# Wrong endpoint:
❌ /api/v1/heartbeat  
✅ /api/v1

# Wrong URL:
❌ http://vietagent-chromadb-production.up.railway.app
✅ https://vietagent-chromadb-production.up.railway.app
```

#### **2. Data Loss After Restart**
```bash
# Check Railway Volumes:
1. Go to Railway Dashboard
2. Check if /data volume is mounted
3. Verify PERSIST_DIRECTORY=/data
4. Ensure IS_PERSISTENT=1
```

#### **3. Connection Timeouts**
```bash
# Railway may have cold starts:
- First request may be slow (15-30s)
- Consider keep-alive pings
- Add retry logic in client
```

### **Debugging Commands**
```bash
# Check Railway logs:
railway logs --service chromadb

# Test health endpoint:
curl -v https://vietagent-chromadb-production.up.railway.app/api/v1

# Check data directory (if shell access):
ls -la /data/
```

---

## 📋 **Deployment Checklist**

### **✅ Pre-Deployment**
- [ ] Railway project created and connected to GitHub
- [ ] Persistent volume configured (/data, 5GB+)
- [ ] Dockerfile updated with correct PERSIST_DIRECTORY
- [ ] Health check endpoints verified

### **✅ Post-Deployment**  
- [ ] Health check passes: `/api/v1`
- [ ] Version endpoint works: `/api/v1/version`
- [ ] Collections endpoint accessible: `/api/v1/collections`
- [ ] Python client connection test passes
- [ ] Data persists after container restart

### **✅ Integration**
- [ ] Main app environment variables configured
- [ ] Network connectivity tested
- [ ] Error handling implemented
- [ ] Monitoring alerts configured

---

## 🔮 **Future Enhancements**

### **Potential Improvements**
- **Multi-node clustering** (ChromaDB distributed mode)
- **Authentication layer** (token-based auth)
- **Connection pooling** (for high-traffic apps)  
- **Backup automation** (scheduled volume snapshots)
- **Monitoring dashboard** (custom metrics)
- **Regional replicas** (for global performance)

---

## 🆘 **Support & Resources**

### **ChromaDB Documentation**
- [Official Docs](https://docs.trychroma.com/)
- [API Reference](https://docs.trychroma.com/reference/py-client)
- [Performance Tips](https://cookbook.chromadb.dev/running/performance-tips/)

### **Railway Resources**
- [Volume Documentation](https://docs.railway.app/deploy/volumes)
- [Environment Variables](https://docs.railway.app/deploy/variables)
- [Monitoring & Logs](https://docs.railway.app/deploy/logs)

---

**🔧 Service Status**: ✅ **OPERATIONAL**  
**📊 Data Persistence**: ✅ **CONFIGURED**  
**🔗 Integration Ready**: ✅ **READY FOR CONNECTION** 
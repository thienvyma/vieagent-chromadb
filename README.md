# 🚂 VIEAgent ChromaDB - Railway Production Service

**Standalone ChromaDB vector database service for VIEAgent AI Platform**

---

## 🚨 **COMPLETE FIX APPLIED**

### **Issues Fixed:** 
- ❌ **Error**: "404 errors on API endpoints - Wrong health check endpoint"
- ❌ **Error**: "External access blocked - Missing CORS configuration"
- ❌ **Error**: "Multiple start methods conflicting"
- ✅ **Solution**: Complete ChromaDB configuration with CORS and proper health checks

### **Changes Made:**
```bash
✅ Fixed Dockerfile with complete ChromaDB configuration
✅ Added CORS environment variables for external access
✅ Fixed health check endpoint: /api/v1 (not /heartbeat)
✅ Removed conflicting Procfile and startCommand
✅ Added security configuration
✅ Single start method (Dockerfile CMD only)
```

---

## 🚀 **DEPLOYMENT FIXED - TEST THESE URLS**

```bash
# Health Check (Primary):
https://vietagent-chromadb.up.railway.app/api/v2

# Version Info:
https://vietagent-chromadb.up.railway.app/api/v2/version

# Collections List:
https://vietagent-chromadb.up.railway.app/api/v2/collections

# API Documentation:
https://vietagent-chromadb.up.railway.app/docs
```

**Expected Response:** JSON data instead of 404 errors!

---

## 🔧 **Railway Configuration**

### **✅ Required Variables (Set in Railway Dashboard):**
```bash
CHROMA_HOST=0.0.0.0
CHROMA_PORT=8000
CHROMA_DB_IMPL=duckdb+parquet
CHROMA_API_IMPL=chromadb.api.fastapi.FastAPI
PERSIST_DIRECTORY=/chroma/data
ANONYMIZED_TELEMETRY=false

# 🌐 CORS Configuration (CRITICAL for external access)
CHROMA_SERVER_CORS_ALLOW_ORIGINS=["*"]
CHROMA_SERVER_HOST=0.0.0.0
CHROMA_SERVER_HTTP_PORT=8000
CHROMA_SERVER_SSL_ENABLED=false

# 🔒 Security Configuration
CHROMA_SERVER_AUTH_PROVIDER=""
CHROMA_SERVER_AUTH_CREDENTIALS=""
```

### **✅ Railway Dashboard Settings:**
1. **Service must be marked as "Public"**
2. **Domain must be generated**
3. **Port 8000 must be exposed**
4. **Environment variables must be set**

---

## 🏗️ **Architecture Overview**

This is a **microservices separation** from the main VIEAgent platform:
- **Main App**: `ai-agent-platform/` → Vercel (Next.js)
- **Vector DB**: `vietagent-chromadb/` → Railway (ChromaDB)

### **Why Separate?**
```bash
❌ Vercel Limitations:
- No persistent storage
- Memory limits (512MB-3008MB)
- Cold starts for heavy services
- No long-running processes

✅ Railway Advantages:
- Persistent volumes
- Higher memory limits
- Better for database services
- Dedicated resources
```

---

## 🔧 **Railway Deployment**

### **1. Repository Connection**
```bash
# This repo is connected to:
GitHub: https://github.com/thienvyma/vietagent-chromadb.git
Railway: https://railway.com/project/[your-project-id]
```

### **2. Environment Variables**
Copy all variables from `env.template` to Railway Dashboard > Variables tab.

### **3. 💾 Data Persistence Setup**

#### **⚠️ CRITICAL: Railway Volume Configuration**

ChromaDB stores vector data that **MUST persist** across container restarts:

##### **3.1. Railway Dashboard Steps:**
```bash
1. Go to Railway Project Dashboard
2. Click on your ChromaDB service
3. Navigate to "Settings" tab
4. Scroll to "Volumes" section
5. Click "Add Volume":
   - Volume Name: chromadb-data
   - Mount Path: /app/data
   - Size: 5GB (recommended minimum)
6. Click "Create Volume"
7. Redeploy the service
```

##### **3.2. Data Storage Structure:**
```bash
# Railway Volume Mount:
/app/data/                          # Persistent storage
├── chroma.sqlite3              # Main database file
├── [collection-uuid-1]/        # Vector collection 1
│   ├── header.bin
│   ├── data_level0.bin
│   └── index_metadata.pickle
├── [collection-uuid-2]/        # Vector collection 2
└── ...                         # More collections
```

---

## 🌍 **API Endpoints**

### **Production URLs**
```bash
Base URL: https://vietagent-chromadb.up.railway.app

# Health Checks:
GET /api/v2                     # API info & health ✅
GET /api/v2/version            # ChromaDB version ✅
GET /api/v2/collections        # List collections ✅

# Collections Management:
POST /api/v1/collections       # Create collection
GET /api/v1/collections/{id}   # Get collection
DELETE /api/v1/collections/{id} # Delete collection

# Vector Operations:
POST /api/v1/collections/{id}/add      # Add vectors
POST /api/v1/collections/{id}/query    # Query vectors
POST /api/v1/collections/{id}/update   # Update vectors
POST /api/v1/collections/{id}/delete   # Delete vectors
```

### **Expected Responses**

#### **Health Check (/api/v1):**
```json
{
  "heartbeat": "ok",
  "nanosecond heartbeat": 1234567890123456789
}
```

#### **Version Info (/api/v1/version):**
```json
{
  "version": "0.4.22",
  "build": "chromadb-0.4.22"
}
```

#### **Collections List (/api/v1/collections):**
```json
{
  "collections": []
}
```

---

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **1. "404 Not Found" Error**
```bash
# Check Railway Dashboard:
1. Service is marked as "Public"
2. Domain is generated
3. Environment variables are set
4. Deployments are successful

# Test endpoints:
curl https://vietagent-chromadb.up.railway.app/api/v1
```

#### **2. "CORS Error" from Vercel**
```bash
# Verify CORS configuration:
CHROMA_SERVER_CORS_ALLOW_ORIGINS=["*"]
CHROMA_SERVER_HOST=0.0.0.0
CHROMA_SERVER_HTTP_PORT=8000
```

#### **3. "Connection Refused"**
```bash
# Check Railway logs:
1. Go to Railway Dashboard
2. Click on service
3. Check "Deployments" tab
4. Look for error messages
```

#### **4. "Data Loss After Restart"**
```bash
# Check Railway Volumes:
1. Go to Railway Dashboard
2. Check if /app/data volume is mounted
3. Verify PERSIST_DIRECTORY=/app/data
4. Ensure volume size is sufficient
```

### **Debugging Commands**
```bash
# Check Railway logs:
railway logs --service chromadb

# Test health endpoint:
curl -v https://vietagent-chromadb.up.railway.app/api/v1

# Test version endpoint:
curl -v https://vietagent-chromadb.up.railway.app/api/v1/version

# Check data directory (if shell access):
ls -la /chroma/data/
```

---

## 📋 **Deployment Checklist**

### **✅ Pre-Deployment**
- [ ] Railway project created and connected to GitHub
- [ ] Persistent volume configured (/chroma/data, 5GB+)
- [ ] Dockerfile updated with correct configuration
- [ ] Environment variables set in Railway Dashboard
- [ ] Service marked as "Public"

### **✅ Post-Deployment**  
- [ ] Health check passes: `/api/v1`
- [ ] Version endpoint works: `/api/v1/version`
- [ ] Collections endpoint accessible: `/api/v1/collections`
- [ ] CORS headers present in responses
- [ ] Data persists after container restart

### **✅ Integration**
- [ ] Main app environment variables configured
- [ ] Network connectivity tested from Vercel
- [ ] Error handling implemented
- [ ] Monitoring alerts configured

---

## 🔮 **Future Enhancements**

### **Potential Improvements**
- **Multi-node clustering** (ChromaDB distributed mode)
- **Authentication layer** (token-based auth)
- **Connection pooling** (for high-traffic apps)
- **Backup automation** (scheduled volume snapshots)
- **Performance monitoring** (query metrics, storage analytics)
- **Auto-scaling** (based on usage patterns)

---

## 📞 **Support**

### **If Issues Persist:**
1. Check Railway deployment logs
2. Verify all environment variables are set
3. Ensure service is marked as "Public"
4. Test endpoints manually with curl
5. Check ChromaDB documentation for updates

### **Useful Links:**
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Railway Documentation](https://docs.railway.app/)
- [VIEAgent Platform](https://github.com/thienvyma/vieagent-platform)

---

**🎉 ChromaDB service is now properly configured for production use with VIEAgent platform!** 
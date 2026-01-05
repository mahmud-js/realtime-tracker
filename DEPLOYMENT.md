# Deployment Guide 🚀

Deploy Real Time Location Tracker to **devplus.fun**.

## 🚀 Quick Start (5 minutes)

```bash
git clone https://github.com/yourusername/realtime-tracker.git
cd realtime-tracker
docker-compose up -d
curl http://localhost:8080/health
```

## Option 1: Docker Deployment (Recommended)

## Cloud Deployment

### AWS EC2

```bash
# 1. Launch Ubuntu 22.04 instance
# 2. SSH into instance
ssh -i key.pem ubuntu@your-instance-ip

# 3. Install dependencies
sudo apt update
sudo apt install -y golang-go

# 4. Clone and build
git clone https://github.com/yourusername/realtime-tracker.git
cd realtime-tracker
go build -o tracker main.go

# 5. Create systemd service
sudo nano /etc/systemd/system/tracker.service
```

Service file content:
```ini
[Unit]
Description=Real Time Location Tracker
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/realtime-tracker
ExecStart=/home/ubuntu/realtime-tracker/tracker
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable tracker
sudo systemctl start tracker
```

### DigitalOcean App Platform

1. Connect GitHub repository
2. Detect as Go app
3. Configure:
   - Runtime: Go
   - Build: `go build -o tracker main.go`
   - Run: `./tracker`
   - Port: 8080
4. Deploy

### Heroku

```bash
# 1. Create app
heroku create your-app-name

# 2. Create Procfile
echo "web: ./tracker" > Procfile

# 3. Create go.sum (required by Heroku)
go mod tidy

# 4. Deploy
git push heroku main

# 5. View logs
heroku logs --tail
```

### Railway.app

```bash
# 1. Connect GitHub
# 2. Create project from Dockerfile
# 3. Set port variable: PORT=8080
# 4. Deploy automatically
```

## Nginx Reverse Proxy Setup

```nginx
upstream tracker {
    server localhost:8080;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://tracker;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## SSL/TLS with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update Nginx configuration with SSL
sudo nano /etc/nginx/sites-available/tracker
```

Add to Nginx config:
```nginx
listen 443 ssl http2;
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

## Environment Variables

Create `.env` file:
```env
PORT=8080
ENV=production
LOG_LEVEL=info
```

Update `main.go`:
```go
package main

import "os"

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

## Monitoring & Logs

### Systemd Service Logs
```bash
# View service logs
sudo journalctl -u tracker -f

# Check service status
sudo systemctl status tracker
```

### Log Rotation
Create `/etc/logrotate.d/tracker`:
```
/var/log/tracker.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
}
```

## Database Setup (Optional)

For persistence, add PostgreSQL:

```bash
# Install PostgreSQL
sudo apt install postgresql

# Create database
sudo -u postgres createdb tracker_db

# Connect and create tables
psql tracker_db
```

## Performance Tuning

### Go
```go
// Increase file descriptor limit
ulimit -n 65536

// Enable compression
import "github.com/klauspost/compress"
```

### Nginx
```nginx
# Connection pooling
upstream tracker {
    keepalive 32;
}

# Gzip compression
gzip on;
gzip_types text/plain text/css application/json;
```

## Backup & Recovery

```bash
# Backup code
tar -czf tracker-backup-$(date +%Y%m%d).tar.gz /home/ubuntu/realtime-tracker

# Auto-backup to S3
aws s3 sync /home/ubuntu/realtime-tracker s3://your-bucket/
```

## Health Checks

Add health endpoint to `main.go`:
```go
http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
})
```

## Scaling

For high traffic:
- Use load balancer (AWS ALB, Nginx)
- Run multiple server instances
- Use shared session storage
- Consider message queue (Redis) for broadcast

## Troubleshooting

### Port Already in Use
```bash
# Find process
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

### WebSocket Connection Issues
```
# Enable WebSocket in Nginx
proxy_set_header Connection "upgrade";
```

### SSL Certificate Renewal
```bash
# Auto-renew
sudo certbot renew --quiet
sudo systemctl reload nginx
```

---

For detailed support, check README.md or create a GitHub issue!

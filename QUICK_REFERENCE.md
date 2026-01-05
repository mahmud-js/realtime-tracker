# Quick Reference Guide 📋

## Files Created/Modified

### New Files Created ✨
```
.github/workflows/ci-cd.yml          GitHub Actions workflow
.air.toml                            Live reload config
docker-compose.dev.yml               Development environment
CI_CD_SETUP.md                       Implementation guide
SETUP_COMPLETE.md                    Setup summary
```

### Files Modified 📝
```
Docker                               Updated multi-stage build
docker-compose.yml                   Updated production config
README.md                            Added CI/CD section
DEPLOYMENT.md                        Updated deployment guide
```

---

## Quick Commands

### Development
```bash
# Hot reload (recommended for development)
air

# Or with Docker
docker-compose -f docker-compose.dev.yml up

# Direct run
go run main.go
```

### Production
```bash
# Deploy with Docker
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f tracker

# Stop
docker-compose down
```

### Testing
```bash
# Go tests
go test ./...

# Go linting
go vet ./...

# Build binary
go build -o tracker .
```

---

## Environment Setup

### Local Development (Windows/Mac)
1. Install Go 1.24+
2. Install Air: `go install github.com/cosmtrek/air@latest`
3. Run: `air` (from project root)

### Local Development (Docker)
1. Install Docker & Docker Compose
2. Run: `docker-compose -f docker-compose.dev.yml up`

### Production Server (Ubuntu 20.04+)
1. Install Docker: `sudo apt install docker.io docker-compose`
2. Clone repo: `git clone <repo>`
3. Deploy: `docker-compose up -d`
4. Setup SSL: See DEPLOYMENT.md

---

## CI/CD Triggers

| Event | Workflow |
|-------|----------|
| Push to `main` | Run tests, build, push Docker |
| Pull Request | Run tests only |
| Manual trigger | Available in Actions tab |

---

## Key Files Explained

### .github/workflows/ci-cd.yml
Automated testing and building:
- Backend: Tests, vet, build binaries
- Frontend: Flutter analyze, test, build
- Docker: Multi-stage build, push to GHCR
- Security: Gosec scanning

### docker-compose.yml
Production deployment:
- Port mapping: 8080
- Health checks: /health endpoint
- Restart policy: auto-restart on crash
- Ready for reverse proxy (Nginx)

### docker-compose.dev.yml
Development environment:
- Hot reload with Air
- Volume mounts (live edit)
- Debug logging
- Isolated network

### .air.toml
Live reload configuration:
- Auto-restart on Go file changes
- Excludes unnecessary directories
- Builds to `./tmp/main`

---

## Deployment Checklist

### Before Pushing to Production
- [ ] All tests pass locally: `go test ./...`
- [ ] Code lints properly: `go vet ./...`
- [ ] Docker builds successfully: `docker-compose build`
- [ ] App runs on `http://localhost:8080`
- [ ] No secrets in code (API keys, passwords)

### Setting Up Server
- [ ] Ubuntu 20.04+ server ready
- [ ] Domain DNS pointing to server IP
- [ ] SSH access configured
- [ ] Docker & Docker Compose installed

### Deployment Steps
- [ ] Clone repository: `git clone <repo>`
- [ ] Deploy: `docker-compose up -d`
- [ ] Verify: `curl http://localhost:8080/health`
- [ ] Setup Nginx (see DEPLOYMENT.md)
- [ ] Get SSL certificate: `certbot`
- [ ] Access at `https://yourdomain.com`

---

## Troubleshooting Quick Fixes

### Container won't start
```bash
docker-compose logs tracker  # See error
docker-compose down          # Clean up
docker-compose up -d         # Retry
```

### Port 8080 in use
```bash
lsof -i :8080           # Find process
kill -9 <PID>          # Kill it
```

### Hot reload not working
```bash
go install github.com/cosmtrek/air@latest  # Update Air
air                                        # Restart
```

### WebSocket connection fails
- Check Nginx proxy (Connection header)
- Check firewall allows port 8080
- Use HTTPS in production

---

## Next Steps

1. **Setup GitHub**
   - Create GitHub repo
   - Push code: `git push origin main`
   - Verify Actions run

2. **Deploy to Server**
   - SSH to server
   - Follow DEPLOYMENT.md
   - Configure domain

3. **Monitor**
   - Check logs: `docker-compose logs -f`
   - Health: `curl https://devplus.fun/health`
   - Setup monitoring (optional)

---

## Useful Links

- **GitHub Actions Docs**: https://docs.github.com/actions
- **Docker Docs**: https://docs.docker.com
- **Go Docs**: https://golang.org/doc
- **Nginx Docs**: https://nginx.org/en/docs
- **Let's Encrypt**: https://letsencrypt.org

---

## Support

- See [CI_CD_SETUP.md](CI_CD_SETUP.md) for detailed setup
- See [DEPLOYMENT.md](DEPLOYMENT.md) for server deployment
- See [README.md](README.md) for usage
- See [SETUP_COMPLETE.md](SETUP_COMPLETE.md) for overview

---

**Ready to deploy?** Start with: `docker-compose up -d`

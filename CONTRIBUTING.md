# Contributing Guide 🤝

Thank you for your interest in contributing to Real Time Location Tracker!

## How to Contribute

### Bug Reports 🐛
1. Check if the issue already exists
2. Provide a clear description of the bug
3. Include steps to reproduce
4. Specify your environment (OS, browser, Go version)

### Feature Requests 💡
1. Describe the feature clearly
2. Explain the use case
3. Suggest implementation approach if possible

### Code Contributions 👨‍💻

1. **Fork the repository**
   ```bash
   git clone https://github.com/mahmud-js/realtime-tracker.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Keep commits atomic and well-described
   - Follow code style guidelines
   - Add comments for complex logic

4. **Test thoroughly**
   ```bash
   go test ./...
   go run main.go
   ```

5. **Push and create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Code Style Guidelines 📝

### Go
```go
// Use standard Go formatting
gofmt main.go

// Export capitalized identifiers
type LocationData struct {
    ID string
}

// Use meaningful variable names
lat, lng := 51.505, -0.09
```

### JavaScript
```javascript
// Use const by default, let when needed
const CONFIG = { /* ... */ };

// Use camelCase for functions and variables
function updateMarker(data) {
    // code
}

// Add comments for complex logic
// Check if coordinates are valid before updating
if (isNaN(lat) || isNaN(lng)) return;
```

### CSS
```css
/* Use custom properties for colors and values */
:root {
    --primary-color: #4CAF50;
}

/* Follow BEM naming convention */
.info-panel { /* block */ }
.info-panel__content { /* element */ }
.info-panel--active { /* modifier */ }

/* Use meaningful class names */
.status-badge { }
.copy-btn { }
```

## Pull Request Process

1. **Update README.md** if needed
2. **Test on multiple browsers** if frontend changes
3. **Provide clear PR description**
4. **Link related issues** (#issue-number)
5. **Wait for review** and address feedback

## Development Setup

```bash
# Install Go if not present
# https://golang.org/doc/install

# Clone and navigate
git clone <your-fork>
cd realtime-tracker

# Install dependencies
go mod download

# Run server
go run main.go

# Open localhost:8080
```

## Areas for Contribution

- 🎨 UI/UX improvements
- 📱 Mobile optimization
- 🐛 Bug fixes
- 📚 Documentation
- ♿ Accessibility improvements
- 🚀 Performance optimization
- 🧪 Testing
- 🌐 Internationalization (i18n)

## Questions?

Create a GitHub Discussion or check existing issues!

package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"math"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/gorilla/websocket"
)

// LocationData represents user location information
type LocationData struct {
	ID         string    `json:"id"`
	Lat        float64   `json:"lat"`
	Lng        float64   `json:"lng"`
	DeviceType string    `json:"deviceType"`
	Timestamp  time.Time `json:"timestamp"`
}

// ClientManager handles WebSocket connections and broadcasts
type ClientManager struct {
	clients      map[*websocket.Conn]bool
	broadcast    chan LocationData
	register     chan *websocket.Conn
	unregister   chan *websocket.Conn
	mutex        sync.RWMutex
	clientCount  int
	lastLocation map[string]LocationData
}

// Server configuration
type ServerConfig struct {
	Host         string
	Port         string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
	IdleTimeout  time.Duration
}

var (
	manager *ClientManager
	logger  *log.Logger
	config  *ServerConfig
)

func init() {
	// Initialize logger
	logger = log.New(os.Stdout, "[LocationTracker] ", log.LstdFlags|log.Lshortfile)

	// Load configuration from environment or use defaults
	config = &ServerConfig{
		Host:         getEnv("SERVER_HOST", "0.0.0.0"),
		Port:         getEnv("SERVER_PORT", "8080"),
		ReadTimeout:  getDurationEnv("READ_TIMEOUT", 15*time.Second),
		WriteTimeout: getDurationEnv("WRITE_TIMEOUT", 15*time.Second),
		IdleTimeout:  getDurationEnv("IDLE_TIMEOUT", 60*time.Second),
	}

	// Initialize ClientManager
	manager = &ClientManager{
		clients:      make(map[*websocket.Conn]bool),
		broadcast:    make(chan LocationData, 256),
		register:     make(chan *websocket.Conn),
		unregister:   make(chan *websocket.Conn),
		lastLocation: make(map[string]LocationData),
	}
}

// getEnv retrieves environment variable with default fallback
func getEnv(key, defaultVal string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultVal
}

// getDurationEnv retrieves duration from environment variable
func getDurationEnv(key string, defaultVal time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if duration, err := time.ParseDuration(value); err == nil {
			return duration
		}
	}
	return defaultVal
}

func main() {
	logger.Printf("Starting Location Tracker Server (Host: %s, Port: %s)", config.Host, config.Port)

	// HTTP Server setup
	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.Dir("./public")))
	mux.HandleFunc("/ws", handleWebSocket)
	mux.HandleFunc("/health", handleHealth)
	mux.HandleFunc("/stats", handleStats)

	server := &http.Server{
		Addr:         config.Host + ":" + config.Port,
		Handler:      loggingMiddleware(mux),
		ReadTimeout:  config.ReadTimeout,
		WriteTimeout: config.WriteTimeout,
		IdleTimeout:  config.IdleTimeout,
	}

	// Start message broadcaster
	go manager.run()

	// Graceful shutdown handling
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
		<-sigChan

		logger.Println("Shutdown signal received, gracefully stopping server...")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if err := server.Shutdown(ctx); err != nil {
			logger.Printf("Server shutdown error: %v", err)
		}
	}()

	// Start server
	logger.Printf("Server listening on %s", server.Addr)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		logger.Fatalf("Server error: %v", err)
	}
	logger.Println("Server stopped")
}

// loggingMiddleware logs HTTP requests
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		logger.Printf("Request: %s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
		next.ServeHTTP(w, r)
		logger.Printf("Duration: %v", time.Since(start))
	})
}

// handleHealth returns server health status
func handleHealth(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	manager.mutex.RLock()
	clientCount := len(manager.clients)
	manager.mutex.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":       "healthy",
		"timestamp":    time.Now(),
		"connected":    clientCount,
		"uptime_check": true,
	})
}

// handleStats returns current server statistics
func handleStats(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	manager.mutex.RLock()
	clientCount := len(manager.clients)
	locationCount := len(manager.lastLocation)
	manager.mutex.RUnlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"connected_clients": clientCount,
		"tracked_locations": locationCount,
		"broadcast_queue":   len(manager.broadcast),
		"timestamp":         time.Now(),
	})
}

// handleWebSocket handles WebSocket connections
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	upgrader := websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			// In production, validate origin properly
			return true
		},
	}

	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		logger.Printf("WebSocket upgrade error: %v", err)
		http.Error(w, "WebSocket upgrade failed", http.StatusBadRequest)
		return
	}

	ws.SetReadDeadline(time.Now().Add(60 * time.Second))
	ws.SetPongHandler(func(string) error {
		ws.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	logger.Printf("New WebSocket connection from %s", ws.RemoteAddr())
	manager.register <- ws

	go handleClientMessages(ws)
}

// handleClientMessages handles incoming messages from a client
func handleClientMessages(ws *websocket.Conn) {
	defer func() {
		manager.unregister <- ws
		ws.Close()
	}()

	for {
		var msg LocationData
		if err := ws.ReadJSON(&msg); err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				logger.Printf("WebSocket error from %s: %v", ws.RemoteAddr(), err)
			}
			return
		}

		// Validate location data
		if validationErr := validateLocationData(&msg); validationErr != nil {
			logger.Printf("Invalid location data from %s: %v", ws.RemoteAddr(), validationErr)
			continue
		}

		// Add timestamp
		msg.Timestamp = time.Now()

		// Send to broadcast channel
		select {
		case manager.broadcast <- msg:
		default:
			logger.Printf("Broadcast channel full, dropping message from %s", msg.ID)
		}
	}
}

// validateLocationData validates incoming location data
func validateLocationData(data *LocationData) error {
	if data.ID == "" {
		return errors.New("user ID is required")
	}
	if len(data.ID) > 100 {
		return errors.New("user ID is too long")
	}
	if !isValidCoordinate(data.Lat) {
		return errors.New("invalid latitude")
	}
	if !isValidCoordinate(data.Lng) {
		return errors.New("invalid longitude")
	}
	if data.DeviceType == "" {
		data.DeviceType = "Unknown"
	}
	if len(data.DeviceType) > 50 {
		return errors.New("device type is too long")
	}
	return nil
}

// isValidCoordinate validates latitude/longitude values
func isValidCoordinate(coord float64) bool {
	return !math.IsNaN(coord) && !math.IsInf(coord, 0) && coord >= -180 && coord <= 180
}

// ClientManager.run manages client connections and broadcasts
func (cm *ClientManager) run() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case client := <-cm.register:
			cm.mutex.Lock()
			cm.clients[client] = true
			cm.clientCount = len(cm.clients)
			cm.mutex.Unlock()
			logger.Printf("Client registered. Total clients: %d", cm.clientCount)

		case client := <-cm.unregister:
			cm.mutex.Lock()
			if _, ok := cm.clients[client]; ok {
				delete(cm.clients, client)
				cm.clientCount = len(cm.clients)
			}
			cm.mutex.Unlock()
			logger.Printf("Client unregistered. Total clients: %d", cm.clientCount)

		case msg := <-cm.broadcast:
			cm.mutex.Lock()
			// Store last known location
			cm.lastLocation[msg.ID] = msg

			// Broadcast to all connected clients
			deadClients := make([]*websocket.Conn, 0)
			for client := range cm.clients {
				if err := client.WriteJSON(msg); err != nil {
					logger.Printf("Error writing to client: %v", err)
					deadClients = append(deadClients, client)
				}
			}

			// Clean up dead connections
			for _, client := range deadClients {
				delete(cm.clients, client)
				client.Close()
			}
			cm.clientCount = len(cm.clients)
			cm.mutex.Unlock()

		case <-ticker.C:
			cm.mutex.RLock()
			logger.Printf("Stats - Connected clients: %d, Tracked locations: %d, Queue size: %d",
				len(cm.clients), len(cm.lastLocation), len(cm.broadcast))
			cm.mutex.RUnlock()
		}
	}
}

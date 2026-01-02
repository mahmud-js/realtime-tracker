// Configuration
const CONFIG = {
    DEFAULT_LAT: 51.505,
    DEFAULT_LNG: -0.09,
    DEFAULT_ZOOM: 13,
    GEOLOCATION_OPTIONS: {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
    },
    UPDATE_INTERVAL: 5000
};

// State Management
const state = {
    userId: null,
    deviceType: null,
    socket: null,
    markers: {},
    userCount: 0,
    isConnected: false,
    watchId: null
};

// Initialize Leaflet Map
const map = L.map('map').setView([CONFIG.DEFAULT_LAT, CONFIG.DEFAULT_LNG], CONFIG.DEFAULT_ZOOM);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors',
    maxZoom: 19
}).addTo(map);

// --- Utility Functions ---

function generateUserId() {
    return 'User-' + Math.floor(Math.random() * 1000000);
}

function getDeviceType() {
    const ua = navigator.userAgent;
    if (/Android/i.test(ua)) return 'Android 📱';
    if (/iPhone|iPad|iPod/i.test(ua)) return 'iOS 🍎';
    if (/Windows/i.test(ua)) return 'Windows 💻';
    if (/Linux/i.test(ua)) return 'Linux 🐧';
    if (/Mac/i.test(ua)) return 'Mac 🖥️';
    return 'Unknown ❓';
}

// --- UI Update Functions (Tailwind Integrated) ---

function showNotification(message, type = 'info') {
    const notification = document.getElementById('notification');
    notification.innerText = message;
    
    // Reset classes while keeping base Tailwind styles
    notification.className = `fixed bottom-8 right-4 p-4 px-6 text-white rounded-custom shadow-custom z-[2000] max-w-[300px] animate-slideInUp block`;
    
    // Apply type-specific colors from tailwind.config
    const bgColors = {
        'success': 'bg-success',
        'error': 'bg-danger',
        'info': 'bg-info'
    };
    notification.classList.add(bgColors[type] || 'bg-info');
    
    setTimeout(() => {
        notification.classList.replace('block', 'hidden');
    }, 3000);
}

function updateStatus(status, type = 'connecting') {
    const statusEl = document.getElementById('status');
    statusEl.innerText = status;
    
    // Base Tailwind classes
    const baseClasses = "status-badge inline-block px-3 py-1.5 rounded-full text-[0.85rem] font-semibold text-center min-w-[120px]";
    
    // Dynamic State classes
    const stateClasses = {
        'connecting': 'bg-yellow-100 text-yellow-800 animate-pulseSlow',
        'connected': 'bg-green-100 text-green-800 animate-none',
        'error': 'bg-red-100 text-red-800 animate-none'
    };
    
    statusEl.className = `${baseClasses} ${stateClasses[type]}`;
}

function updateUserCount(count) {
    state.userCount = count;
    document.getElementById('user-count').innerText = count;
}

// --- Core Logic ---

function initializeUI() {
    state.userId = generateUserId();
    state.deviceType = getDeviceType();
    
    document.getElementById('my-id').innerText = state.userId;
    document.getElementById('device-type').innerText = state.deviceType;
    
    // Copy to clipboard
    document.getElementById('copy-btn').addEventListener('click', () => {
        navigator.clipboard.writeText(state.userId).then(() => {
            showNotification('User ID copied!', 'success');
        }).catch(() => {
            showNotification('Failed to copy ID', 'error');
        });
    });
    
    updateStatus('Connecting...', 'connecting');
}

function connectWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
    const wsUrl = `${protocol}${window.location.host}/ws`;
    
    state.socket = new WebSocket(wsUrl);
    
    state.socket.onopen = () => {
        state.isConnected = true;
        updateStatus('Connected ✅', 'connected');
        showNotification('Connected to server', 'success');
        startTracking();
    };
    
    state.socket.onmessage = (event) => {
        try {
            const data = JSON.parse(event.data);
            updateMarker(data);
        } catch (error) {
            console.error('Error parsing message:', error);
        }
    };
    
    state.socket.onerror = () => {
        updateStatus('Connection Error ❌', 'error');
    };
    
    state.socket.onclose = () => {
        state.isConnected = false;
        updateStatus('Disconnected', 'error');
        showNotification('Connection lost. Retrying...', 'error');
        setTimeout(connectWebSocket, 3000);
    };
}

function updateMarker(data) {
    const lat = parseFloat(data.lat);
    const lng = parseFloat(data.lng || data.long);
    
    if (isNaN(lat) || isNaN(lng)) return;
    
    if (!state.markers[data.id]) {
        state.markers[data.id] = L.marker([lat, lng]).addTo(map);
        updateUserCount(Object.keys(state.markers).length);
        
        // Don't notify for yourself
        if (data.id !== state.userId) {
            showNotification(`User joined: ${data.id.substring(0, 10)}`, 'info');
        }
    } else {
        state.markers[data.id].setLatLng([lat, lng]);
    }
    
    const popupContent = `
        <div class="text-center p-1">
            <p class="font-bold border-b mb-1">${data.id === state.userId ? "You" : data.id}</p>
            <p class="text-xs text-gray-600">${data.deviceType}</p>
        </div>
    `;
    state.markers[data.id].bindPopup(popupContent);
}

function startTracking() {
    if (!navigator.geolocation) {
        showNotification('Geolocation not supported', 'error');
        return;
    }
    
    state.watchId = navigator.geolocation.watchPosition(
        (position) => {
            const payload = {
                id: state.userId,
                lat: position.coords.latitude,
                lng: position.coords.longitude,
                deviceType: state.deviceType
            };
            
            if (state.socket && state.socket.readyState === WebSocket.OPEN) {
                state.socket.send(JSON.stringify(payload));
            }
        },
        (error) => {
            console.error('Geo error:', error);
            showNotification('Location access required', 'error');
        },
        CONFIG.GEOLOCATION_OPTIONS
    );
}

// Lifecycle management
window.addEventListener('beforeunload', () => {
    if (state.watchId !== null) navigator.geolocation.clearWatch(state.watchId);
    if (state.socket) state.socket.close();
});

document.addEventListener('DOMContentLoaded', () => {
    initializeUI();
    connectWebSocket();
});
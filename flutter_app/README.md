# Realtime Tracker
Golang Backend and Flutter Frontend for Realtime Tracker

## Steps to Run the Project:
##Start the Golang Backend:
```powershell
go run main.go
```
### Navigate to the Flutter App:
```powershell
cd flutter_app
```
### Run the Flutter App:

```powershell
flutter run
```

Note: If you are testing on a physical device, ensure you update the _wsUrl in 
lib/main.dart
 from localhost to your computer's local IP address (e.g., ws://192.168.1.10:8080/ws).

The Flutter project is now fully configured and ready for development or deployment!
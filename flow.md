# Project Flow & History

## Context & Philosophy
**Project**: Smart Trainer Pro
**Goal**: Rehabilitation-focused smart trainer app with physio-prescribed workouts.

## Design System: "Ponce"
Named after Ponce City Market, Atlanta:
- **Orange**: #FF5722 (Primary Actions)
- **Teal**: #1A3C40 (Headers/Secondary)
- **Blue**: #4D8090 (Accents)
- **Background**: #F7F4F0

---

## Phase 1: iOS MVP (Complete)
- [x] Bluetooth (FTMS + Standalone HR)
- [x] Dashboard (Power, Cadence, HR)
- [x] Manual ERG Control
- [x] Safety Limits (Wattage Ceiling, Low Cadence Alert)
- [x] Fix: Cadence parsing resolved (multi-byte flag interpretation)
- [x] Fix: Standalone HR monitor scanning (UUID 180D)

## Phase 2: Local Logging (Complete)
- [x] Ride Recording (Start/Stop)
- [x] History View (JSON persistence)

## Phase 3: Backend & Web Portal (Complete)
### .NET Backend
- [x] SQLite Database + EF Core
- [x] Models: User, Practitioner, Prescription
- [x] REST API Controllers
- [x] CORS Support
- [x] Fix: Automatic signing and permissions in Xcode

### React Web Portal
- [x] Vite + TailwindCSS v3
- [x] Patient Management (CRUD)
- [x] Prescription Creation
- [x] "Ponce" Design Theme (Ponce City Market, Atlanta)

---

## Project Structure

```
SmartTrainerPro/
├── ios/
│   ├── SmartTrainerPro.xcodeproj/   # Open in Xcode
│   └── SmartTrainerPro/
│       ├── Info.plist               # Bluetooth permissions
│       ├── BluetoothManager.swift   # FTMS + HR Logic
│       └── ...
```

---

## How To Run

### iOS App
```bash
open /Users/andrewlawson/Projects/SmartTrainerPro/ios/SmartTrainerPro.xcodeproj
# Then Build & Run in Xcode (⌘R)
```

### Backend
```bash
cd web/SmartTrainerPro.Api && dotnet run
# Runs on http://localhost:5223
```

### Web Portal
```bash
cd web/physio-portal && npm run dev
# Runs on http://localhost:5174
```

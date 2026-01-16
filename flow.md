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
- [x] Bluetooth (FTMS + Heart Rate)
- [x] Dashboard (Power, Cadence, HR)
- [x] Manual ERG Control
- [x] Safety Limits (Wattage Ceiling, Low Cadence Alert)

## Phase 2: Local Logging (Complete)
- [x] Ride Recording (Start/Stop)
- [x] History View (JSON persistence)

## Phase 3: Backend & Web Portal (Complete)
### .NET Backend
- [x] SQLite Database + EF Core
- [x] Models: User, Practitioner, Prescription
- [x] REST API Controllers
- [x] CORS Support

### React Web Portal
- [x] Vite + TailwindCSS v3
- [x] Patient Management (CRUD)
- [x] Prescription Creation
- [x] "Ponce" Design Theme

---

## Project Structure

```
SmartTrainerPro/
├── ios/
│   ├── SmartTrainerPro.xcodeproj/   # ← Open this in Xcode
│   └── SmartTrainerPro/
│       ├── SmartTrainerProApp.swift
│       ├── ContentView.swift
│       ├── BluetoothManager.swift
│       ├── Info.plist
│       ├── SmartTrainerPro.entitlements
│       ├── Models/
│       │   └── WorkoutManager.swift
│       └── Views/
│           └── HistoryView.swift
│
├── web/
│   ├── SmartTrainerPro.Api/         # .NET Backend (port 5223)
│   └── physio-portal/               # React Frontend (port 5174)
│
└── flow.md
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

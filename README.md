# Smart Trainer Pro

A rehabilitation-focused smart bike trainer app for iOS, with a web portal for physios to prescribe workouts.

## Design System: "Ponce"
Named after Ponce City Market, Atlanta.

## Quick Start

### iOS App
```bash
open ios/SmartTrainerPro.xcodeproj
# Build & Run in Xcode (⌘R)
```

### Backend API
```bash
cd web/SmartTrainerPro.Api
dotnet run
# http://localhost:5223
```

### Web Portal
```bash
cd web/physio-portal
npm install
npm run dev
# http://localhost:5174
```

## Project Structure
- `ios/` - Native iOS SwiftUI app
- `web/SmartTrainerPro.Api/` - .NET Web API backend
- `web/physio-portal/` - React web portal for physios

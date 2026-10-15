# FlightDeck

FlightDeck is a Flutter flight-listing application built for a technical machine test.

## Technologies
- **Flutter** & **Dart**
- **BLoC** (`flutter_bloc`) for reactive state management
- **Dio** for HTTP networking
- **SQLite** (`sqflite` & `path`) for local persistent caching
- **flutter_svg** for high-resolution airline SVG logos
- **Clean Architecture** with constructor-based dependency injection

## Architecture
```
Presentation
     ↓
   BLoC
     ↓
  UseCase
     ↓
Repository
     ↓
Data Sources (SQLite / Dio)
```

## Data Flow
- **First Launch**: API → SQLite → UI
- **Later Launches**: SQLite → UI (No network call)

## Features
- Flight API integration with Dio
- SQLite offline persistence
- Dynamic airline filtering
- Price, departure time, and duration sorting
- SVG airline logo loading with fallback
- Clean architecture with manual constructor dependency injection

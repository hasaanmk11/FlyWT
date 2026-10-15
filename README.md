# FlightDeck

FlightDeck is a Flutter flight-listing application built for a technical machine test.

## Technologies
- **Flutter** & **Dart**
- **BLoC** (`flutter_bloc`) for reactive state management
- **Dio** for HTTP networking
- **SQLite** (`sqflite` & `path`) for local persistent caching
- **flutter_svg** for high-resolution airline SVG logos
- **Clean Architecture** with constructor-based dependency injection

---

## Clean Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   └── database/
│       └── database_helper.dart
├── features/
│   └── flights/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── flight_remote_data_source.dart
│       │   │   └── flight_local_data_source.dart
│       │   ├── models/
│       │   │   └── flight_model.dart
│       │   └── repositories/
│       │       └── flight_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── flight.dart
│       │   ├── repositories/
│       │   │   └── flight_repository.dart
│       │   └── usecases/
│       │       └── get_flights.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── flight_bloc.dart
│           │   ├── flight_event.dart
│           │   └── flight_state.dart
│           ├── pages/
│           │   └── flight_page.dart
│           └── widgets/
│               ├── flight_card.dart
│               ├── airline_filter.dart
│               └── sort_button.dart
├── app.dart
└── main.dart
```

### Architecture Flow
```
Presentation (UI & Widgets)
       ↓
     BLoC
       ↓
    UseCase (GetFlights)
       ↓
  Repository (FlightRepository)
       ↓
Local / Remote Data Source
       ↓
SQLite / Dio API
```

---

## Caching Data Flow

### First App Launch
```
App Opens
   ↓
Check SQLite
   ↓
SQLite is Empty
   ↓
Call API using Dio
   ↓
Parse Flights JSON
   ↓
Save Flights into SQLite (Batch Insert)
   ↓
Display Flights in UI
```

### Second and Later Launches (Online or Offline)
```
App Opens
   ↓
Check SQLite
   ↓
SQLite already contains flights
   ↓
DO NOT CALL API
   ↓
Read Flights from SQLite
   ↓
Display Flights in UI
```

---

## Features
- **Live Flight API Integration**: Connects to the results endpoint with timeout configurations and cleartext HTTP support on Android.
- **SQLite Offline Caching**: Persists search results on first launch; subsequent launches read directly from SQLite without network requests.
- **Airline Filtering**: Dynamic filter generated from loaded flights (no hardcoding); filters in-memory without re-querying SQLite or API.
- **Flight Sorting**: Sort by Price (Low → High / High → Low), Departure Time, and Duration.
- **Combined Filtering & Sorting**: Seamlessly filters and sorts simultaneously on in-memory data.
- **Airline SVG Logos**: Loads vector logos from CDN (`https://souqsafaraiweb.caxita.ca/AirlineIcons/{airlineCode}.svg`) with placeholder and flight icon error fallback.
- **Interview-Friendly Code**: Simple, straightforward constructors, zero overcomplicated boilerplate.

---

## Running the Application

```bash
cd app
flutter pub get
flutter run
```

To run all automated verification tests:
```bash
cd app
flutter test
```

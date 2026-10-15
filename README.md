# FlyWT

FlyWT is a Flutter flight-booking application built for a technical machine test, meticulously matching the provided Figma design system.

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
│   │   └── api_constants.dart           # API endpoint & Airline CDN base URL
│   ├── database/
│   │   └── database_helper.dart         # SQLite schema & database lifecycle
│   └── theme/
│       ├── app_colors.dart              # FlyWT color palette
│       └── app_theme.dart               # Theme configuration
├── features/
│   └── flights/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── flight_remote_data_source.dart  # Dio API client
│       │   │   └── flight_local_data_source.dart   # SQLite CRUD & batch insert
│       │   ├── models/
│       │   │   └── flight_model.dart               # JSON parsing & SQLite mapping
│       │   └── repositories/
│       │       └── flight_repository_impl.dart     # Offline-first caching logic
│       ├── domain/
│       │   ├── entities/
│       │   │   └── flight.dart                     # Core domain entity (outbound + return)
│       │   ├── repositories/
│       │   │   └── flight_repository.dart          # Pure abstract contract
│       │   └── usecases/
│       │       └── get_flights.dart                # Simple business use case
│       └── presentation/
│           ├── bloc/
│           │   ├── flight_bloc.dart                # In-memory filter/sort BLoC
│           │   ├── flight_event.dart               # BLoC events & sort enum
│           │   └── flight_state.dart               # Initial, Loading, Loaded, Error
│           ├── pages/
│           │   ├── splash_page.dart                # Full-screen cinematic splash with Continue
│           │   └── flight_page.dart                # Main flight screen & list
│           └── widgets/
│               ├── flight_header.dart              # Blue header banner (Route + Metadata)
│               ├── flight_card.dart                # Ticket card with semi-circle cutouts
│               ├── journey_row.dart                # Flight leg with SVG logo & orange path
│               ├── sort_filter_bar.dart            # Orange floating Sort/Filter pill
│               ├── filter_bottom_sheet.dart        # Multi-airline checkbox filter sheet
│               └── sort_bottom_sheet.dart          # Airline, Duration, Price sort sheet
├── app.dart                                        # MaterialApp with FlyWT theme
└── main.dart                                       # Manual constructor DI & BlocProvider
```

---

## Caching Data Flow

### First App Launch
```
FlyWT Splash Screen (tap CONTINUE)
   ↓
Flight Screen Opens
   ↓
Check SQLite
   ↓
SQLite is Empty
   ↓
Call API using Dio
   ↓
Parse Flights JSON (Outbound + Return legs)
   ↓
Save Flights into SQLite (Batch Insert)
   ↓
Display Flights in UI
```

### Second and Later Launches (Online or Offline)
```
FlyWT Splash Screen (tap CONTINUE)
   ↓
Flight Screen Opens
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

## FlyWT Figma Design System Features
- **Splash Screen**: Full-screen aircraft background with dark gradient overlay, FlyWT branding, bold uppercase headline, and wide orange Continue button.
- **Flight Header**: Navy blue banner featuring route (`DXB ➔ KWI`), decorative airplane divider, date, travellers, and flight count.
- **Flight Ticket Cards**: Rounded white ticket cards with decorative semi-circle cutouts, dotted divider, red "Non Refundable" status, and prominent price.
- **Outbound & Return Legs**: Reusable `JourneyRow` displaying airline SVG logo, timings, airport codes, orange path marker, and duration.
- **Floating Controls**: Orange floating bar at bottom center with `Sort` and `Filter` actions.
- **Filter Bottom Sheet**: Dynamic airline checkboxes, "Clear" shortcut, and "Reset" / "Done" action buttons.
- **Sort Bottom Sheet**: Dual-direction sorting controls (Ascending ▲ / Descending ▼) for Airline, Duration, and Price.

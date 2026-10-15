# FlyWT

FlyWT is a Flutter flight-booking application built for a technical machine test, adhering to Clean Architecture, BLoC state management, and the provided Figma design.

## Features
- Full-screen Splash Screen with dark overlay and FlyWT branding
- Blue flight header banner with route and flight count
- Flight ticket cards with semi-circular cutouts and dotted divider
- Reusable `JourneyRow` for outbound and return legs with SVG airline logos
- Floating orange `[ Sort | Filter ]` control bar
- Multi-airline filter bottom sheet with checkboxes
- Sort bottom sheet for Airline, Duration, and Price (Ascending/Descending)
- Offline-first SQLite persistence with Dio API integration
- Clean Architecture with manual constructor dependency injection

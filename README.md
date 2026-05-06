# Echoes

An offline-first Flutter journaling and memory mapping application designed to capture moments, locations, and experiences in a simple and immersive way.

## Features

* Offline-first local storage
* Memory timeline and journal system
* Interactive memory map using OpenStreetMap
* Add text and images memories
* GPS location tagging
* Clean Flutter UI with Riverpod state management
* Fast embedded local database
* Android support

## Tech Stack

| Technology             | Purpose                      |
| ---------------------- | ---------------------------- |
| Flutter                | Cross-platform app framework |
| Riverpod               | State management             |
| Go Router              | Navigation and routing       |
| Drift / SQLite         | Local database               |
| Flutter Map            | Interactive maps             |
| Geolocator             | GPS and location services    |
| Image Picker           | Image importing              |

## Screens

### Memories Screen

Displays all saved memories in a clean timeline interface.

### Add Memory Screen

Create a new memory with:

* Title
* Description
* Images
* GPS location

### Map Screen

Visualize memories on an interactive map.

## Getting Started

### Prerequisites

* Flutter SDK
* Android Studio
* Dart SDK
* Android Emulator or Physical Device

## Installation

Clone the repository:

```bash
git clone https://github.com/Rudaina220/Echoes.git
cd Echoes
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Build APK

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/
```

## Permissions

The application may require:

* Location permission
* Storage permission
* Camera permission

## Future Improvements

* Cloud synchronization
* AI-powered memory summarization
* Search and filtering system
* Mood analysis
* Multi-device sync
* Memory sharing
* Timeline analytics
* Offline map tile caching

## Contributors

* Rudaina Haitham

## License

This project is for educational and personal development purposes.

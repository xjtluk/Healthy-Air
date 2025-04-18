# Healthy Air
<img src="healthyair/assets/logo.png" alt="Healthy Air Logo" width="200">
A real‑time air quality monitoring application built with Flutter, providing current AQI data, pollutant breakdowns, and actionable health advice.

---

## Table of Contents

1. [Stroyboard](#stroyboard)  
2. [Features](#features)
3. [Install The App](#install-the-app)
4. [Project Tech Stack](#project-tech-stack)  
5. [Project Structure](#project-structure)
6. [Data Collection & Management](#data-collection--management)  
7. [Interactivity](#interactivity)  
8. [Technical Integration](#technical-integration) 
9. [Install The Project](#install-the-project)  
10. [Contact Details](#contact-details)  

---

## Stroyboard

1.**Prototype Design**

2.**Use Cases**
- Ideal for users who care about air quality, especially sensitive groups (children, elderly, respiratory patients).  
- Provides timely health advice to help users take protective measures when air quality worsens.


---


## Features

- **Real‑Time AQI**: Live updates of air quality index and pollutant levels.  
- **Auto & Manual Location**: GPS‑based or city‑name look‑up.  
- **Health Advice**: Tailored protection tips per AQI thresholds.  
- **Shake‑to‑Refresh**: Shake the device for an instant data refresh.  
- **Favorites & Settings**: Manage preferred cities, notification toggles, units, and update frequency—persisted in Firestore.  
- **Pollutant Details**: In‑app guides on pollutant sources, risks, and mitigation.  
- **About/Privacy**: App overview, data sources, privacy policy, and support contact.


---

## Install The App
---
## Project Tech Stack

- **Frontend**: Flutter  
- **State Management**: Provider  
- **Backend**:  
  - Firebase Auth & Firestore  
  - AQICN API  
- **Location**: Geolocator & Geocoding  
- **Sensors**: sensors_plus  

## Project Structure
```plaintext
lib/
├── main.dart # App entry point and route setup
├── screens/ # UI pages (Home, Settings, Details, About)
├── providers/ # State management (AirQualityProvider)
├── services/ # API and location services
├── models/ # Data models (AirQualityData, Pollutant)
└── widgets/ # Reusable UI components
```

---

## Data Collection & Management

### Data Collection

- **Air Quality Data**  
  Fetched from the AQICN API: AQI values, pollutant concentrations (PM2.5, PM10, O₃, NO₂, CO, etc.), plus the dominant pollutant.  
- **Location Data**  
  Device GPS determines current coordinates; reverse geocoding converts them into city names.  
- **User Preferences**  
  Notification settings, favorite cities, and update frequency are collected and stored per user.

### Data Handling

- **LocationService**  
  Manages permissions, obtains coordinates, and reverse‑geocodes to city names.  
- **ApiService**  
  Interfaces with AQICN API to fetch data by city name or geo‑coordinates.  
- **Error Handling**  
  Catches API failures or permission issues, showing user‑friendly messages.

### Data Management

- **State Management**  
  `AirQualityProvider` (via Provider) tracks data, user prefs, loading, and errors.  
- **Persistent Storage**  
  User settings and favorites are saved in Firebase Firestore, ensuring cross‑session persistence.

---

## Interactivity

### User Interaction

- **Shake to Refresh**  
  Shake the device to reload air quality data.  
- **Manual Refresh**  
  Tap the refresh icon in the app bar.  
- **My Location**  
  A button fetches AQI for the current GPS location.  
- **Favorites**  
  Add, view, and remove favorite cities for quick access.

### Dynamic UI

- **Live Updates**  
  The UI automatically reflects the latest data.  
- **Pollutant Details**  
  Tap any pollutant to see health effects and protective measures.  
- **Settings**  
  Customize notifications, units, and frequencies on the fly.

### Feedback Mechanisms

- **Snackbars**  
  Notify users of actions (e.g., “Data refreshed,” “City added”).  
- **Error Messages**  
  Display failures (e.g., “Failed to fetch data”) with retry options.

---

## Technical Integration

### AQICN API

- Uses HTTP requests to pull live AQI data.  
- Data is mapped into the `AirQualityData` model.

### Firebase

- **Authentication**  
  Email/password sign‑in, registration, and password reset via Firebase Auth.  
- **Firestore**  
  Stores user settings (`user_settings/{uid}`) and favorites in structured documents.

### Device Features

- **Location**  
  Geolocator & Geocoding for GPS and city name resolution.  
- **Sensors**  
  sensors_plus detects shake events to trigger refresh.

### State & Error Resilience

- Provider ensures UI stays in sync with backend.  
- Catches and handles network, API, and permission errors gracefully.


---


## Install The Project

1. **Clone**  
   ```bash
   git clone https://github.com/YourUsername/healthy_air.git
   cd healthy_air
   ```
2. **Dependencies**
   ```bash
   flutter pub get
   ```
3. **Usage**
   ```bash
   flutter run
   ```

---

## Contact Details








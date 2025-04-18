# Healthy Air

A real‑time air quality monitoring application built with Flutter, providing current AQI data, pollutant breakdowns, and actionable health advice.

---

## Table of Contents

1. [Stroyboard](#stroyboard)  
2. [Features](#features)
3. [Install The App](#install-the-app)
4. [Project Tech Stack](#project-tech-stack)  
5. [Project Structure](#project-structure)  
6. [Install The Project](#install-the-project)  
7. [Contact Details](#contact-details)  

---

## Stroyboard

**Healthy Air** is a cross‑platform Flutter app that fetches real‑time AQI and pollutant concentrations (PM2.5, PM10, O₃, NO₂, etc.) via the AQICN API. It auto‑detects user location, allows city look‑up, offers “shake to refresh,” and delivers personalized health recommendations. User settings and favorites are stored in Firebase Firestore.

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








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

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/1.jpg" alt="Healthy Air Preview" width="33%">
<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/2.jpg" alt="Healthy Air Preview" width="30%">
<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/3.jpg" alt="Healthy Air Preview" width="30%">

2.**Use Cases**
- Ideal for users who care about air quality, especially sensitive groups (children, elderly, respiratory patients).  
- Provides timely health advice to help users take protective measures when air quality worsens.

<div style="display: flex; align-items: flex-start;">
  <div style="margin-right: 20px; text-align: center;">
    <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/story1.jpg" alt="Story 1" width="180">
    <p><strong>1. Father plans an outing but finds poor air quality</strong><br>🌀 "What was supposed to be a sunny outing turned into a gloomy sight outside the window. Father frowned, concerned about the family's health and safety."</p>
  </div>
  <div style="text-align: center;">
    <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/story2.jpg" alt="Story 2" width="180">
    <p><strong>2. Father checks his phone for air quality information</strong><br>📱 "The air quality warning flashed red, and Father stared at the phone screen, quickly assessing the situation."</p>
  </div>
</div>

<div style="display: flex; align-items: flex-start; margin-top: 20px;">
  <div style="margin-right: 20px; text-align: center;">
    <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/story3.jpg" alt="Story 3" width="180">
    <p><strong>3. Father searches for a city with better air quality</strong><br>🗺️ "Hope appeared at his fingertips as he scrolled through the map, searching for the bluest skies suitable for breathing."</p>
  </div>
  <div style="text-align: center;">
    <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/story4.jpg" alt="Story 4" width="180">
    <p><strong>4. The whole family plays on a fresh-air lawn</strong><br>🌿 "Sunshine bathed the grassy field, and laughter echoed through the fresh air. The family found true relaxation and joy in nature."</p>
  </div>
</div>

---


## Features

- **Real‑Time AQI**: Live updates of air quality index and pollutant levels.  
- **Auto & Manual Location**: GPS‑based or city‑name look‑up.  
- **Health Advice**: Tailored protection tips per AQI thresholds.  
- **Shake‑to‑Refresh**: Shake the device for an instant data refresh.  
- **Favorites & Settings**: Manage preferred cities, notification toggles, units, and update frequency—persisted in Firestore.  
- **Pollutant Details**: In‑app guides on pollutant sources, risks, and mitigation.  
- **About/Privacy**: App overview, data sources, privacy policy, and support contact.

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen1.png" alt="Healthy Air Preview" width="15%">
1. Boot animation.

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen2.png" alt="Healthy Air Preview" width="15%">

2.The top left is the soft glue slogan, and the right three buttons are used to refresh the data, relocate to the current city, and jump to the Settings page. The middle shows the name of the city, the time of data acquisition, and the overall air quality assessment. At the bottom is the pollutant card.

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen3.png" alt="Healthy Air Preview" width="15%"> <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen4.png" alt="Healthy Air Preview" width="15%">

3. The pollutant card contains the data of PM2.5, PM10, O3, NO2, SO2 and CO, respectively. Also use colors to highlight status: blue is very good, green is good, yellow is medium, orange is slightly polluted, red is unhealthy, and purple is dangerous.
   When the user clicks on the pollutant card, the software will make a prompt based on the current data. In addition, you can continue to click to jump to the contaminant details page.

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen5.png" alt="Healthy Air Preview" width="15%"> <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen6.png" alt="Healthy Air Preview" width="15%"> <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen7.png" alt="Healthy Air Preview" width="15%">

4. The Contaminant detail page describes the definition, sources, hazards and protection measures of each contaminant in detail. At the same time, it will also popularize the harm degree of different data corresponding to different pollutants.

<img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen8.png" alt="Healthy Air Preview" width="15%">

5. In the Settings page, users can manage their personal Settings. First, you need to log into your account to set up your personal Settings. Log in and you'll see your saved personality Settings. Including whether to prompt, data units, data refresh frequency. In addition, the following search box can be used to learn about the air quality data of other cities, and each time you log in to the account, you can find your preferred city. Select your preferences and click the upper right corner to save.


 <img src="https://github.com/xjtluk/Healthy-Air/blob/main/Resources/screen9.png" alt="Healthy Air Preview" width="15%">
6. These are a few introductions about the software including product descriptions, user privacy, etc.

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
   git clone https://github.com/xjtluk/Healthy-Air.git
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








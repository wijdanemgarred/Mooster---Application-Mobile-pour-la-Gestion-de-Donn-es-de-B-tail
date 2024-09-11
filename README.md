# Mooster
Mooster is a Flutter-based mobile application designed for efficient livestock management. This app helps owners and veterinarians monitor and manage the health of their cattle in real-time, utilizing IoT devices (ESP8236) for temperature tracking and health status alerts.

## Features

- **Livestock Monitoring**: View detailed profiles for each cow, including health status and checkup history.
- **Health Alerts**: Automatically receive notifications when a cow's health is compromised.
- **Veterinary Tools**: Add consultations, medications, and track pregnancy status.
- **Admin Dashboard**: Manage users and have an overview of all cattle health across multiple farms.
- **IoT Integration**: The app integrates with ESP8236 temperature sensors to track cow health in real-time.

## User Roles

- **Admin**: Oversees the system and manages accounts.
- **Owner**: Manages their farm and monitors cattle health.
- **Veterinarian**: Tracks cow health, records consultations, and changes health statuses.

## Getting Started

To run the project locally, you will need Flutter installed. For installation instructions, follow the official [Flutter documentation](https://flutter.dev/docs/get-started/install).

### Prerequisites

- Flutter SDK
- Firebase Account (Firestore for data management)
- ESP8236 devices for IoT integration

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/wijdanemgarred/Mooster-livestock-management-app
   cd mooster

   
Here’s a comprehensive README.md for your Mooster app, which should serve as a clear introduction and guide to anyone using or contributing to the project:

markdown
Copy code
# Mooster
**Mooster** is a mobile application developed in **Flutter** for managing livestock health and wellbeing. The app integrates with IoT devices (ESP8236) and Firebase to provide real-time health monitoring and facilitate veterinary interventions, ensuring optimal care for cattle.

## Project Overview

Mooster helps **owners** and **veterinarians** manage their cattle by providing:
- **Real-time health status** based on temperature sensors integrated with IoT devices.
- **Notifications** when cattle health conditions change (e.g., sickness detection).
- **Consultation tracking** for veterinarians to record treatments and observations.
- **Admin control** for managing user roles and system access.
- **Dashboard views** for accessing and managing cattle information easily.

---

## Features

### Cattle Health Monitoring
- **Real-time Temperature Tracking**: Using ESP8236  sensors, the app monitors the temperature of each cow to detect potential health issues.
- **Health Status Updates**: Each cow is color-coded by health status (Red = Sick, Yellow = Under Treatment, Green = Healthy).

### Veterinary Management
- **Consultations and Observations**: Veterinarians can add notes on medications, treatments, and vaccinations.
- **Pregnancy Tracking**: Track the pregnancy status of cows, including due dates and health during pregnancy.
- **Health Status Modifications**: Only veterinarians can update the cow's status (e.g., from sick to healthy).

### User Roles
- **Admin**: Manages users and has a global overview of all cattle in the system.
- **Owner**: Views cattle details, adds new cows, and checks health status.
- **Veterinarian**: In addition to owner privileges, veterinarians can add consultations and update health statuses.

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following:

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Firebase Account**: Set up Firebase for database management (Firestore)
- **ESP8236  Devices**: Required for temperature monitoring

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/mooster.git
   cd mooster

2. **Install Dependencies**:
   Run the following command to install all necessary Flutter packages:
      flutter pub get
   
3. **Set Up Firebase**:
   Follow the official Firebase setup instructions for Flutter.
   Add google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the respective platforms.

4. **Run the App**:
   To launch the app on your device or emulator, use the command:
      flutter run

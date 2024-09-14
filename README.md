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

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/wijdanemgarred/Mooster-livestock-management-app
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

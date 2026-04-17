# Corevia Mobile

Application mobile Corevia développée avec Flutter.

## Prérequis

- Flutter 3.6.1+
- Dart 3.6.1+

## Installation

```bash
flutter pub get
```

## Lancer l'application

```bash
flutter run
```

## Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Dépendances principales

- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **HTTP Client**: dio
- **Notifications**: flutter_local_notifications
- **Chat**: flutter_chat_ui, flutter_chat_core
- **Stockage sécurisé**: flutter_secure_storage
- **Variables d'environnement**: flutter_dotenv

## Configuration

Copier `.env.template` vers `.env` et configurer les variables d'environnement.
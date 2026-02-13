import 'package:flutter/foundation.dart';

/// Notifier pour l'état de l'onboarding
class OnboardingNotifier extends ValueNotifier<bool> {
  OnboardingNotifier(super.value);
}

/// Notifier pour l'état d'authentification
class AuthNotifier extends ValueNotifier<bool> {
  AuthNotifier(super.value);
}
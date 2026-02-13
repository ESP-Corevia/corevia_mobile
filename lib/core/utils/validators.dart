class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _digitRegex = RegExp(r'\d');
  static final RegExp _specialCharRegex =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]`~+=;]');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre adresse email';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer une adresse email valide';
    }

    return null;
  }

  static String? validateRequired(
    String? value, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  static String? validateUsername(
    String? value, {
    String fieldName = "Nom d'utilisateur",
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }

    final normalized = value.trim();
    if (normalized.length < 2) {
      return '$fieldName doit contenir au moins 2 caracteres';
    }

    if (normalized.length > 100) {
      return '$fieldName ne peut pas depasser 100 caracteres';
    }

    return null;
  }

  static String? validatePassword(
    String? value, {
    bool requireStrongRules = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caracteres';
    }

    if (value.length > 100) {
      return 'Le mot de passe ne peut pas depasser 100 caracteres';
    }

    if (requireStrongRules && !_lowercaseRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (requireStrongRules && !_uppercaseRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (requireStrongRules && !_digitRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    if (requireStrongRules && !_specialCharRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un caractere special';
    }

    return null;
  }
}

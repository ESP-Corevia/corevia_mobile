class RegisterModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  }) {
    if (firstName.isEmpty) throw ArgumentError('Le prénom ne peut pas être vide');
    if (lastName.isEmpty) throw ArgumentError('Le nom ne peut pas être vide');
    if (!_isValidEmail(email)) throw ArgumentError('Email invalide');
    if (password.length < 8) throw ArgumentError('Le mot de passe doit contenir au moins 8 caractères');
    if (password != confirmPassword) throw ArgumentError('Les mots de passe ne correspondent pas');
  }

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterModel &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.password == password &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode => Object.hash(
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
      );

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

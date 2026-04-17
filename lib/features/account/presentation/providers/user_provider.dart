import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _repository;

  static const _userKey = 'cached_user_data';

  bool _isLoading = false;
  String? _error;
  User? _user;

  UserProvider(this._repository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  /// Definir le user directement depuis les donnees de login
  Future<void> setUserFromLoginData(Map<String, dynamic> data) async {
    _user = User(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      image: data['image']?.toString(),
      phone: data['phoneNumber']?.toString() ?? data['phone']?.toString(),
    );
    await _persistUser();
    notifyListeners();
  }

  /// Charger depuis l'API (si disponible) ou depuis le cache
  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.fetchCurrentUser();
      await _persistUser();
    } catch (e) {
      // Fallback: lire depuis le cache SharedPreferences
      await _loadFromCache();
      if (_user == null) {
        _error = 'Erreur lors du chargement du profil';
      }
      if (kDebugMode) {
        print('UserProvider.loadUser: $e (fallback cache: ${_user != null})');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.updateUser(_user!.id, data);
      await _persistUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise a jour du profil';
      if (kDebugMode) {
        print('UserProvider.updateUser: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> clear() async {
    _user = null;
    _error = null;
    _isLoading = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> _persistUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_userKey);
    if (cached != null) {
      try {
        _user = User.fromJson(jsonDecode(cached));
      } catch (_) {}
    }
  }
}

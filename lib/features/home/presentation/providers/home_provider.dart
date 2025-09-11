import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';

class HomeProvider with ChangeNotifier {
  final HomeRepository _repository;
  
  bool _isLoading = false;
  String? _error;
  HomeData? _homeData;

  HomeProvider(this._repository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  HomeData? get homeData => _homeData;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _homeData = await _repository.getHomeData();
    } catch (e) {
      _error = 'Erreur lors du chargement des données';
      if (kDebugMode) {
        print('Erreur: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

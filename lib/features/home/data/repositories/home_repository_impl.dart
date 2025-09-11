import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeData> getHomeData() async {
    // Ici, vous pourriez faire un appel API ou récupérer des données locales
    // Pour l'instant, on retourne des données factices
    await Future.delayed(const Duration(seconds: 1)); // Simulation d'un appel réseau
    return HomeData(
      title: 'Bienvenue sur CoreVia',
      description: 'Votre application de gestion CoreVia',
    );
  }
}

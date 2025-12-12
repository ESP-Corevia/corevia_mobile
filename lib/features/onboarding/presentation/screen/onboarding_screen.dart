import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  // PageController pour le slider
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation "floating"
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  // Données des pages
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Suivez vos médicaments',
      'subtitle': 'Ne manquez plus jamais une dose',
      'icon': Icons.medication_rounded,
      'color': const Color(0xFF34C759),
      'gradient': [const Color(0xFF34C759), const Color(0xFF30D158)],
    },
    {
      'title': 'Rappels intelligents',
      'subtitle': 'Notifications personnalisées pour vous',
      'icon': Icons.notifications_active_rounded,
      'color': const Color(0xFF5856D6),
      'gradient': [const Color(0xFF5856D6), const Color(0xFF7B79FF)],
    },
    {
      'title': 'DocAI à votre service',
      'subtitle': 'Assistant médical intelligent 24/7',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFFFF9500),
      'gradient': [const Color(0xFFFF9500), const Color(0xFFFFB340)],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Animation
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Quand l'utilisateur termine l'onboarding
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool('onboarding_done', true);

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : impossible de sauvegarder.')),
      );
      return;
    }

    if (!mounted) return;

    // 🔥 Met à jour le notifier que GoRouter écoute
    context.read<ValueNotifier<bool>>().value = false;

    // Déplace l'utilisateur vers le login
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SLIDER
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (_, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            // INDICATEURS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.black
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOUTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _finishOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  "Commencer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// WIDGET pour une page d'onboarding
  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: List<Color>.from(data['gradient']),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (data['color'] as Color).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    data['icon'],
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D1D1F),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['subtitle'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

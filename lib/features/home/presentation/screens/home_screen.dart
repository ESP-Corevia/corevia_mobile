import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../widgets/pill_shadow.dart';
import '../../../../widgets/medication_detail_modal.dart';
import '../../../../widgets/navigation_bar.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getStartOfWeek(DateTime.now());
    selectedDate = DateTime.now();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(currentLocation: '/home'),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopCard(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeeklyCalendar(),
                    const SizedBox(height: 40),
                    _buildMedicationSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo de profil à gauche
              GestureDetector(
                onTap: () {
                  _showSnackBar('Profil cliqué');
                },
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/150?img=32',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Hello Georges et Pro member
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello, Georges',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2C1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFFBE0A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pro member',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFBE0A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barre de recherche
          GestureDetector(
            onTap: () {
              _showDocAIDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Start a chat with DocAI',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate days of the current week
  List<Map<String, dynamic>> getDaysOfWeek() {
    final now = DateTime.now();
    // Get the first day of the week (Monday)
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = firstDayOfWeek.add(Duration(days: index));
      final dayName = _getDayName(date.weekday);
      return {
        'letter': dayName[0],
        'status': _getDayStatus(date),
        'fullName': dayName,
        'date': date,
      };
    });
  }

  // Get the French name of the day
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        return '';
    }
  }

  // Get status for a specific day (you can modify this to get from your data source)
  String _getDayStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(date.year, date.month, date.day);

    // Si c'est un jour futur, pas de statut
    if (currentDate.isAfter(today)) return 'future';

    // Si c'est aujourd'hui
    if (currentDate.isAtSameMomentAs(today)) return 'today';

    // Pour le mercredi, toujours retourner 'missed' pour afficher une croix
    if (date.weekday == DateTime.wednesday) return 'missed';

    // Pour les autres jours passés, on détermine un statut aléatoire
    final random = date.day * date.month;
    if (random % 10 < 4) return 'completed';
    if (random % 10 < 7) return 'missed';
    return 'normal';
  }

  // Get the index of the current day (0-6 where 0 is Monday)
  int get selectedDayIndex => DateTime.now().weekday % 7;

  Widget _buildWeeklyCalendar() {
    final daysOfWeek = getDaysOfWeek();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: daysOfWeek.map<Widget>((day) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildDayCircle(day, daysOfWeek.indexOf(day)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDayCircle(Map<String, dynamic> day, int index) {
    final now = DateTime.now();
    final isToday = day['date'].year == now.year &&
        day['date'].month == now.month &&
        day['date'].day == now.day;
    final isSelected = isToday; // Selected state is the same as today for now

    // Determine status (in a real app, this would come from your data)
    final status = _getDayStatus(day['date'] as DateTime);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = day['date'] as DateTime;
        });
        _showSnackBar('${day['fullName']} ${day['date'].day}/${day['date'].month} sélectionné');
      },
      child: Container(
        width: 36,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Coins légèrement arrondis
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5DF394) // Vert pour le jour sélectionné
                : const Color(0xFFF0F0F0), // Gris clair pour les autres jours
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none, // Permet aux enfants de déborderer
          children: [
            // Lettre du jour
            Center(
              child: Text(
                day['letter'],
                style: TextStyle(
                  fontSize: 20, // Taille de police augmentée
                  color: isSelected ? Colors.black : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),

            // Indicateur de statut uniquement pour les jours passés
            if (status == 'completed' || status == 'missed' || status == 'normal')
              Positioned(
                top: -10, // Ajusté pour le nouveau cercle plus grand
                right: -10, // Ajusté pour le nouveau cercle plus grand
                child: Container(
                  width: 20, // Taille augmentée
                  height: 20, // Taille augmentée
                  decoration: BoxDecoration(
                    color: status == 'completed'
                        ? const Color(0xFF34C759) // Vert pour validé
                        : status == 'missed'
                            ? const Color(0xFFFF3B30) // Rouge pour manqué
                            : Colors.transparent, // Transparent pour 'normal'
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status == 'normal'
                          ? const Color(0xFFD1D1D6) // Gris pour normal
                          : Colors.white, // Blanc pour les autres états
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (status != 'normal')
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: status == 'normal'
                      ? null // Pas d'icône pour l'état normal
                      : Icon(
                          status == 'completed' ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 10,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationSection() {
    final medications = [
      {
        'name': 'Ibuprofen',
        'dosage': '200mg',
        'frequency': '3 times a day',
        'time': '08:00 AM',
        'description':
        'Anti-inflammatory medication used to reduce fever and treat pain or inflammation.',
        'prescribedBy': 'Dr. Sarah Johnson',
        'startDate': '15/11/2024',
        'endDate': '30/11/2024',
        'instructions':
        'Take with food to avoid stomach upset. Do not exceed 6 tablets per day.'
      },
      {
        'name': 'Doliprane',
        'dosage': '500mg',
        'frequency': '2 times a day',
        'time': '09:00 AM',
        'description': 'Pain relief and fever reduction medication.',
        'prescribedBy': 'Dr. Paul Martin',
        'startDate': '12/11/2024',
        'endDate': '22/11/2024',
        'instructions': 'Can be taken without food.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 12, top: 10),
          child: Text(
            'Medication Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
              letterSpacing: -0.5,
            ),
          ),
        ),

        // 👉 On enlève le scroll + Row
        Column(
          children: medications.map((med) {
            return _buildMedicationCardTest(context, med);
          }).toList(),
        )
      ],
    );
  }

  Widget _buildMedicationCardTest(BuildContext context, Map<String, String> med) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => MedicationDetailModal(
            medicationName: med['name']!,
            dosage: med['dosage']!,
            frequency: med['frequency']!,
            time: med['time']!,
            description: med['description']!,
            prescribedBy: med['prescribedBy']!,
            startDate: med['startDate']!,
            endDate: med['endDate']!,
            instructions: med['instructions']!,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, // Changez selon vos besoins
                  children: [
                    Text(
                      med['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                        '${med['time']} . ${med['dosage']}',
                        style: TextStyle(color: Colors.black)
                    ),
                  ],
                ),
                PillShadow(assetPath: 'assets/pill2.png', widthValue: 50, heightValue: 50),

              ]
            ),

            // Text(
            //   med['dosage']!,
            //   style: const TextStyle(color: Colors.grey),
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Icon(LucideIcons.clock3, size: 16, color: Colors.grey.shade600),
            //     const SizedBox(width: 4),
            //     Text(med['time']!,
            //         style: TextStyle(color: Colors.grey.shade700)),
            //   ],
            // ),
            // const SizedBox(height: 4),
            // Row(
            //   children: [
            //     Icon(LucideIcons.repeat, size: 16, color: Colors.grey.shade600),
            //     const SizedBox(width: 4),
            //     Text(med['frequency']!,
            //         style: TextStyle(color: Colors.grey.shade700)),
            //   ],
            // ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 40, // Définissez la largeur du cercle
                height: 40, // Définissez la hauteur du cercle pour le rendre plus petit
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightGreen[100], // Fond vert léger
                ),
                padding: EdgeInsets.all(0), // Ajustez ce padding pour la taille du cercle
                child: Center( // Centrer l'icône dans le cercle
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.check,
                      color: Colors.green,
                      size: 20, // Ajustez la taille de l'icône
                    ),
                    padding: EdgeInsets.zero, // Aucune marge autour de l'icône
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${med['name']} marked as taken!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showDocAIDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('DocAI Chat'),
        content: const Text('Bienvenue dans DocAI!\nComment puis-je vous aider aujourd\'hui?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Démarrage du chat...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );
  }

  container({required Axis scrollDirection, required EdgeInsets padding, required Row child}) {}
}
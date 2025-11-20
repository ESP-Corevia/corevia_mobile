import 'package:flutter/material.dart';



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
                    const SizedBox(height: 40),
                    _buildAppointmentsSection(),
                    const SizedBox(height: 80),
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

  Widget _buildMedicationCard(
    String name,
    String dosage,
    String frequency,
    String time,
    Color color, {
    required bool isLiquid,
  }) {
    return GestureDetector(
      onTap: () => _showMedicationDialog(name, dosage, frequency, time),
      child: Container(
        width: 180,
        height: 200,
        margin: const EdgeInsets.only(right: 12, bottom: 10, left: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne avec le nom du médicament et le dosage
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• $dosage',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ligne avec l'image et la fréquence
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du comprimé et fréquence
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image du comprimé - 50% de largeur
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isLiquid ? _buildLiquidMedicine(color) : _buildPillMedicine(color),
                            ),
                          ),
                        ),
                      ),
                      
                      // Fréquence - 50% de largeur
                      Expanded(
                        flex: 1,
                        child: Text(
                          frequency,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Espacement avant l'heure
                  const Spacer(),
                  
                  // Ligne avec l'heure et la cloche
                  Row(
                    children: [
                      // Heure
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Espacement
                      const Spacer(),
                      
                      // Icône de cloche
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF34C759),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidMedicine(Color color) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Container(
          width: 40,
          height: 35,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillMedicine(Color color) {
    return Container(
      width: 50,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection() {
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 4),
          child: Row(
            children: [
              _buildMedicationCard(
                'Ibuprofen',
                '200mg',
                '3 times a day',
                '08:00 AM',
                const Color(0xFFFFF2E5),
                isLiquid: false,
              ),
              const SizedBox(width: 12),
              _buildMedicationCard(
                'Amoxicillin',
                '500mg',
                '2 times a day',
                '01:00 PM',
                const Color(0xFFE8F5E9),
                isLiquid: true,
              ),
              const SizedBox(width: 12),
              _buildMedicationCard(
                'Paracetamol',
                '500mg',
                '6h',
                '10:00 AM',
                const Color(0xFFE3F2FD),
                isLiquid: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Appointments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            _showAppointmentsDialog();
          },
          child: Container(
            padding: const EdgeInsets.all(25),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '3+',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      Text(
                        'Upcomming Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showAddAppointmentDialog();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showMedicationDialog(String name, String dosage, String frequency, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosage: $dosage'),
            const SizedBox(height: 8),
            Text('Fréquence: $frequency'),
            const SizedBox(height: 8),
            Text('Heure: $time'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Médicament pris ✓');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Marquer comme pris'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Rendez-vous à venir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppointmentItem('Dr. Martin', '2 Nov, 14:00', Icons.medical_services),
            const Divider(),
            _buildAppointmentItem('Dr. Dupont', '5 Nov, 10:30', Icons.favorite),
            const Divider(),
            _buildAppointmentItem('Dr. Bernard', '8 Nov, 16:00', Icons.psychology),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String doctor, String datetime, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF34C759)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  datetime,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Ajouter un rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nom du médecin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date et heure',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Rendez-vous ajouté avec succès!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
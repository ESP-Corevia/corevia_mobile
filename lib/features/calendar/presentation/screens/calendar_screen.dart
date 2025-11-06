import 'package:corevia_mobile/widgets/headerToggle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../assets/color/color.dart';

// PAGE MY APPOINTMENTS
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _selectedTab = 'Schedule'; // 'Schedule' ou 'Lists'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header avec toggle
          HeaderToggle(
            onBackPressed: () {
              context.pop(); // Gestion du retour
            },
            pageTitle: 'Calendar', // Titre de la page
            toggleItems: ['Schedule', 'Lists'], // Items du toggle
            selectedTab: _selectedTab,
            onToggleSelected: (selected) {
              setState(() {
                _selectedTab = selected; // Mise à jour de l'onglet sélectionné
              });
            },
          ),

          // Contenu
          Expanded(
            child: Container(
              child: _selectedTab == 'Schedule'
                  ? _buildScheduleView() // Fonction à définir
                  : _buildListsView(),   // Fonction à définir
            ),
          ),
        ],
      ),
    );
  }

  // VUE SCHEDULE (Timeline)
  Widget _buildScheduleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedules',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Timeline avec rendez-vous
          _buildTimelineItem(
            time: '09:00',
            child: _buildMedicationCard(
              name: 'Probiotic',
              dosage: '250 mg',
              instruction: 'After eating',
              color: Colors.pink.shade100,
            ),
          ),

          _buildTimelineItem(
            time: '',
            showTime: false,
            child: _buildMedicationCard(
              name: 'Doliprane',
              dosage: '500 mg',
              instruction: 'After eating',
              color: Colors.pink.shade100,
            ),
          ),

          _buildTimelineItem(
            time: '10:00',
            isLast: true,
            child: _buildDoctorCard(
              doctorName: 'Dr. Ahmad B.',
              specialty: 'Lung Specialist',
              subSpecialty: 'General Lung Surgeon',
              dateTime: '10:25 - 11:35 AM',
              price: '\$120',
              imageUrl: 'https://via.placeholder.com/150',
            ),
          ),
        ],
      ),
    );
  }

  // VUE LISTS (Liste de tous les rendez-vous)
  Widget _buildListsView() {
    return Column(
      children: [
        // Barre de recherche et filtre
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search appointments...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Colors.black),
              ),
            ],
          ),
        ),

        // Liste des rendez-vous
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Text(
                'All Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildAppointmentListCard(
                doctorName: 'Dr. Ahmed Badaoui',
                specialty: 'Lung Specialist',
                dateTime: 'Today, 10:25 - 11:35 AM',
                imageUrl: 'https://via.placeholder.com/150',
                isOnline: true,
              ),

              const SizedBox(height: 12),

              _buildAppointmentListCard(
                doctorName: 'Dr. Noura Songo',
                specialty: 'General medical checkup',
                dateTime: 'Today, 10:25 - 11:35 AM',
                imageUrl: 'https://via.placeholder.com/150',
                isOnline: true,
              ),

              const SizedBox(height: 12),

              _buildAppointmentListCard(
                doctorName: 'Dr. Sakura Kisuke',
                specialty: 'Surgeon Specialist',
                dateTime: 'Tomorrow, 14:00 - 15:00 PM',
                imageUrl: 'https://via.placeholder.com/150',
                isOnline: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Timeline Item
  Widget _buildTimelineItem({
    required String time,
    required Widget child,
    bool showTime = true,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline avec heure
        SizedBox(
          width: 60,
          child: Column(
            children: [
              if (showTime)
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.clockFading, // Icône que vous voulez afficher
                        color: AppColors.grey, // Couleur de l'icône
                        size: 16, // Taille de l'icône
                      ),
                      const SizedBox(width: 4), // Espacement entre l'icône et le texte
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Contenu
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          ),
        ),
      ],
    );
  }

  // Card pour médicament
  Widget _buildMedicationCard({
    required String name,
    required String dosage,
    required String instruction,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication,
              color: Colors.pink,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$dosage  •  $instruction',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card pour rendez-vous médecin (schedule)
  Widget _buildDoctorCard({
    required String doctorName,
    required String specialty,
    required String subSpecialty,
    required String dateTime,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      specialty,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subSpecialty,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card pour liste de rendez-vous
  Widget _buildAppointmentListCard({
    required String doctorName,
    required String specialty,
    required String dateTime,
    required String imageUrl,
    required bool isOnline,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(imageUrl),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isOnline)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  specialty,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dateTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications, size: 20, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, size: 20, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
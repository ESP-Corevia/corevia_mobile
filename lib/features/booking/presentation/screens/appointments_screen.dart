import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Données de démonstration
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'id': '1',
      'doctorName': 'Dr. Ahmed Badaoui',
      'specialty': 'Pneumologue',
      'address': '123 Rue de la Santé, Paris 75014',
      'date': DateTime.now().add(Duration(days: 2)),
      'time': '10:30',
      'status': 'confirmed',
      'imageUrl': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'id': '2',
      'doctorName': 'Dr. Noura Songo',
      'specialty': 'Médecin généraliste',
      'address': '45 Avenue Victor Hugo, Paris 75016',
      'date': DateTime.now().add(Duration(days: 5)),
      'time': '14:00',
      'status': 'pending',
      'imageUrl': 'https://i.pravatar.cc/150?img=45',
    },
    {
      'id': '3',
      'doctorName': 'Dr. Marie Dubois',
      'specialty': 'Cardiologue',
      'address': '78 Boulevard Saint-Germain, Paris 75005',
      'date': DateTime.now().add(Duration(days: 7)),
      'time': '09:00',
      'status': 'confirmed',
      'imageUrl': 'https://i.pravatar.cc/150?img=28',
    },
  ];

  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'id': '4',
      'doctorName': 'Dr. Sakura Kisuke',
      'specialty': 'Chirurgien',
      'address': '56 Rue du Faubourg, Paris 75008',
      'date': DateTime.now().subtract(Duration(days: 10)),
      'time': '11:00',
      'status': 'completed',
      'imageUrl': 'https://i.pravatar.cc/150?img=32',
    },
    {
      'id': '5',
      'doctorName': 'Dr. Jean Martin',
      'specialty': 'Dermatologue',
      'address': '12 Place de la République, Paris 75011',
      'date': DateTime.now().subtract(Duration(days: 30)),
      'time': '15:30',
      'status': 'completed',
      'imageUrl': 'https://i.pravatar.cc/150?img=15',
    },
  ];

  final List<Map<String, dynamic>> _cancelledAppointments = [
    {
      'id': '6',
      'doctorName': 'Dr. Sophie Laurent',
      'specialty': 'Ophtalmologue',
      'address': '90 Rue de Rivoli, Paris 75001',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'time': '16:00',
      'status': 'cancelled',
      'imageUrl': 'https://i.pravatar.cc/150?img=47',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentsList(_upcomingAppointments, 'upcoming'),
                  _buildAppointmentsList(_pastAppointments, 'past'),
                  _buildAppointmentsList(_cancelledAppointments, 'cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ),
              const Text(
                'Mes rendez-vous',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.search,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34C759), Color(0xFF30D158)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'À venir'),
          Tab(text: 'Passés'),
          Tab(text: 'Annulés'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments, String type) {
    if (appointments.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAppointmentCard(appointment, type),
        );
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, String type) {
    final doctorName = appointment['doctorName'] as String? ?? 'Médecin inconnu';
    final specialty = appointment['specialty'] as String? ?? 'Spécialité non spécifiée';
    final address = appointment['address'] as String? ?? 'Adresse non disponible';
    final date = appointment['date'] as DateTime? ?? DateTime.now();
    final time = appointment['time'] as String? ?? '--:--';
    final status = appointment['status'] as String? ?? 'unknown';
    final imageUrl = appointment['imageUrl'] as String?;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF34C759);
        statusText = 'Confirmé';
        statusIcon = LucideIcons.check;
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9500);
        statusText = 'En attente';
        statusIcon = LucideIcons.clock3;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFFF3B30);
        statusText = 'Annulé';
        statusIcon = LucideIcons.circle;
        break;
      case 'completed':
        statusColor = const Color(0xFF007AFF);
        statusText = 'Terminé';
        statusIcon = LucideIcons.check;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
        statusIcon = LucideIcons.handHelping;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (type == 'upcoming' && status == 'confirmed')
                      Icon(
                        LucideIcons.moveVertical,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Doctor info
                Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl ?? 'https://i.pravatar.cc/150?img=1',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          ),
                        ),
                        if (status == 'confirmed')
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialty,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Date et heure
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        LucideIcons.clock3,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Adresse
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions buttons
          if (type == 'upcoming') _buildActionButtons(appointment),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> appointment) {
    final status = appointment['status'] as String;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (status == 'confirmed') ...[
            Expanded(
              child: InkWell(
                onTap: () {
                  _showCancelDialog(appointment);
                },
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.circle,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  // Reprogrammer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité de reprogrammation à venir'),
                      backgroundColor: Color(0xFF007AFF),
                    ),
                  );
                },
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.calendarClock,
                        size: 18,
                        color: const Color(0xFF34C759),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reprogrammer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34C759),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (status == 'pending') ...[
            Expanded(
              child: InkWell(
                onTap: () {
                  _showCancelDialog(appointment);
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.circle,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Annuler la demande',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'upcoming':
        title = 'Aucun rendez-vous à venir';
        subtitle = 'Prenez rendez-vous avec un médecin';
        icon = LucideIcons.calendarPlus;
        break;
      case 'past':
        title = 'Aucun rendez-vous passé';
        subtitle = 'Vos rendez-vous passés apparaîtront ici';
        icon = LucideIcons.calendarCheck;
        break;
      case 'cancelled':
        title = 'Aucun rendez-vous annulé';
        subtitle = 'Les rendez-vous annulés apparaîtront ici';
        icon = LucideIcons.calendarX;
        break;
      default:
        title = 'Aucun rendez-vous';
        subtitle = '';
        icon = LucideIcons.calendar;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1D1F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (type == 'upcoming') ...[
              const SizedBox(height: 32),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF30D158)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34C759).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/calendar');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendarPlus, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Prendre rendez-vous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Annuler le rendez-vous',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir annuler votre rendez-vous avec ${appointment['doctorName']} ?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Non, garder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(LucideIcons.check, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Rendez-vous avec ${appointment['doctorName']} annulé'),
                        ],
                      ),
                      backgroundColor: const Color(0xFFFF3B30),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Oui, annuler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
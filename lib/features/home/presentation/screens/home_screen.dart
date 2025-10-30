import 'package:flutter/material.dart' hide NavigationBar;
import 'package:corevia_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:corevia_mobile/features/home/presentation/widgets/quick_actions.dart';
import 'package:corevia_mobile/features/home/presentation/widgets/recent_activity.dart';
import 'package:iconsax/iconsax.dart';

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<QuickActionItem> quickActions = [
    QuickActionItem(
      icon: Iconsax.scan,
      label: 'Scan',
      onTap: () {},
      color: Colors.blue,
    ),
    QuickActionItem(
      icon: Iconsax.document_upload,
      label: 'Upload',
      onTap: () {},
      color: Colors.green,
    ),
    QuickActionItem(
      icon: Iconsax.document_download,
      label: 'Download',
      onTap: () {},
      color: Colors.orange,
    ),
  ];

  final List<ActivityItem> recentActivities = [
    ActivityItem(
      id: '1',
      title: 'Document Uploaded',
      description: 'report_q3_2023.pdf',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Iconsax.document_upload,
      color: Colors.green,
    ),
    ActivityItem(
      id: '2',
      title: 'Document Scanned',
      description: 'invoice_001.pdf',
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Iconsax.scan,
      color: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                title: 'Welcome back,',
                subtitle: 'Here\'s what\'s happening today',
                userName: 'John Doe',
                userAvatar: 'https://i.pravatar.cc/150?img=32',
              ),

              const SizedBox(height: 16),
              QuickActions(actions: quickActions),
              _buildHeader(),

              const SizedBox(height: 30),
              _buildSearchBar(),

              const SizedBox(height: 30),
              _buildWeeklyCalendar(),

              const SizedBox(height: 40),
              _buildMedicationSection(),

              const SizedBox(height: 40),
              _buildAppointmentsSection(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Georges',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD60A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Pro member',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
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
    );
  }

  Widget _buildWeeklyCalendar() {
    List<Map<String, dynamic>> days = [
      {'letter': 'L', 'status': 'completed'},
      {'letter': 'M', 'status': 'missed'},
      {'letter': 'M', 'status': 'completed'},
      {'letter': 'J', 'status': 'normal'},
      {'letter': 'V', 'status': 'normal'},
      {'letter': 'S', 'status': 'normal'},
      {'letter': 'D', 'status': 'normal'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((day) => _buildDayCircle(day)).toList(),
      ),
    );
  }

  Widget _buildDayCircle(Map<String, dynamic> day) {
    Color backgroundColor;
    Color textColor = Colors.white;
    Widget? icon;

    switch (day['status']) {
      case 'completed':
        backgroundColor = const Color(0xFF34C759);
        break;
      case 'missed':
        backgroundColor = const Color(0xFFFF3B30);
        icon = const Icon(Icons.close, color: Colors.white, size: 16);
        break;
      default:
        backgroundColor = const Color(0xFFE5E5EA);
        textColor = const Color(0xFF8E8E93);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon ??
            Text(
              day['letter'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
      ),
    );
  }

  Widget _buildMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication Plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildMedicationCard(
                'Probiotic, 250 mg',
                '1 Pill',
                'Once per day',
                '09:00 AM',
                Colors.red[300]!,
                isLiquid: true,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildMedicationCard(
                'Doliprane, 500 mg',
                '2 Pill',
                'Once per day',
                '09:00 AM',
                Colors.pink[200]!,
                isLiquid: false,
              ),
            ),
          ],
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34C759),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: 60,
            height: 60,
            child: isLiquid ? _buildLiquidMedicine(color) : _buildPillMedicine(color),
          ),

          const SizedBox(height: 15),

          Text(
            dosage,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          Text(
            frequency,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34C759),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.notifications, size: 16, color: Color(0xFF34C759)),
            ],
          ),
        ],
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
        Container(
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
              Container(
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
            ],
          ),
        ),
      ],
    );
  }
}

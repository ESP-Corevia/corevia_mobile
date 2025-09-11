import 'package:flutter/material.dart' hide NavigationBar;
import 'package:corevia_mobile/widgets/navigation_bar.dart';
import 'package:corevia_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:corevia_mobile/features/home/presentation/widgets/quick_actions.dart';
import 'package:corevia_mobile/features/home/presentation/widgets/recent_activity.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(MedicalApp());
}

class MedicalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: HomeScreen(),
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
      onTap: () {
        // Handle scan action
      },
      color: Colors.blue,
    ),
    QuickActionItem(
      icon: Iconsax.document_upload,
      label: 'Upload',
      onTap: () {
        // Handle upload action
      },
      color: Colors.green,
    ),
    QuickActionItem(
      icon: Iconsax.document_download,
      label: 'Download',
      onTap: () {
        // Handle download action
      },
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
              // Header with user info
              HomeHeader(
                title: 'Welcome back,',
                subtitle: 'Here\'s what\'s happening today',
                userName: 'John Doe',
                userAvatar: 'https://i.pravatar.cc/150?img=32',
              ),
              
              // Quick Actions
              const SizedBox(height: 16),
              QuickActions(actions: quickActions),
              // Header with greeting
              _buildHeader(),
              
              SizedBox(height: 30),
              
              // Search bar
              _buildSearchBar(),
              
              SizedBox(height: 30),
              
              // Weekly calendar
              _buildWeeklyCalendar(),
              
              SizedBox(height: 40),
              
              // Medication Plan section
              _buildMedicationSection(),
              
              SizedBox(height: 40),
              
              // Next Appointments section
              _buildAppointmentsSection(),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, Georges',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFFFD60A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
        backgroundColor = Color(0xFF34C759);
        break;
      case 'missed':
        backgroundColor = Color(0xFFFF3B30);
        icon = Icon(Icons.close, color: Colors.white, size: 16);
        break;
      default:
        backgroundColor = Color(0xFFE5E5EA);
        textColor = Color(0xFF8E8E93);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon ?? Text(
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
        Text(
          'Medication Plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildMedicationCard(
              'Probiotic, 250 mg',
              '1 Pill',
              'Once per day',
              '09:00 AM',
              Colors.red[300]!,
              isLiquid: true,
            )),
            SizedBox(width: 15),
            Expanded(child: _buildMedicationCard(
              'Doliprane, 500 mg',
              '2 Pill',
              'Once per day',
              '09:00 AM',
              Colors.pink[200]!,
              isLiquid: false,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationCard(String name, String dosage, String frequency, 
      String time, Color color, {required bool isLiquid}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34C759),
            ),
          ),
          SizedBox(height: 15),
          
          // Medication icon
          Container(
            width: 60,
            height: 60,
            child: isLiquid ? _buildLiquidMedicine(color) : _buildPillMedicine(color),
          ),
          
          SizedBox(height: 15),
          
          Text(
            dosage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          
          Text(
            frequency,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
            ),
          ),
          
          SizedBox(height: 15),
          
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF34C759),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.notifications, size: 16, color: Color(0xFF34C759)),
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
            borderRadius: BorderRadius.only(
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
            borderRadius: BorderRadius.only(
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Appointments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1D1F),
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  color: Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Color(0xFF1D1D1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(Icons.home_filled, true),
            _buildNavIcon(Icons.bar_chart, false),
            _buildNavIcon(Icons.chat_bubble_outline, false),
            _buildNavIcon(Icons.calendar_today, false),
            _buildNavIcon(Icons.person_outline, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Color(0xFF34C759) : Color(0xFF8E8E93),
            size: 24,
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/header_toggle.dart';
import '../../../../widgets/pro_member.dart';
import '../../../../assets/color/color.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// PAGE DE CONSULTATION DE COMPTE
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  bool isNotificationsEnabled = true;
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
            pageTitle: 'My Account', // Titre de la page
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  Container(
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
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150',
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  context.push('/edit-account');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Georges',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ProMemberBadge()
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Account Information
                  _buildSection(
                    title: 'Account Information',
                    children: [
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: 'georges@example.com',
                      ),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: '+33 6 12 34 56 78',
                      ),
                      _buildInfoTile(
                        icon: Icons.cake_outlined,
                        title: 'Date of Birth',
                        value: '15/03/1985',
                      ),
                      _buildActionTile(
                        icon: LucideIcons.fileText,
                        title: 'Documents',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Settings
                  _buildSection(
                    title: 'Settings',
                    children: [
                      _buildActionTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        trailing: Switch(
                          value: isNotificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              isNotificationsEnabled = value;
                            });
                          },
                          // activeThumbColor: AppColors.green,
                        ),
                      ),
                      _buildActionTile(
                        icon: Icons.lock_outline,
                        title: 'Privacy & Security',
                      ),
                      _buildActionTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  _buildSection(
                    title: 'Actions',
                    children: [
                      _buildActionTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                      ),
                      _buildActionTile(
                        icon: Icons.info_outline,
                        title: 'About',
                      ),
                      _buildActionTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.green),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.green),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
      onTap: () {},
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:corevia_mobile/core/providers/notifiers.dart';
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/user_routes.dart';
import '../../../../widgets/pro_member.dart';
import 'package:corevia_mobile/core/theme/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../widgets/initials_avatar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isNotificationsEnabled = true;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await ApiService.authGet(UserRoutes.me());
      if (mounted) {
        setState(() {
          _user = res['user'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.signOut();
    if (mounted) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      authNotifier.value = false;
      context.go('/login');
    }
  }

  String get _name => _user?['name'] as String? ?? '—';
  String get _email => _user?['email'] as String? ?? '—';
  String? get _imageUrl => _user?['image'] as String?;

  Map<String, dynamic>? get _patientProfile =>
      _user?['patientProfile'] as Map<String, dynamic>?;

  String get _phone => _patientProfile?['phone'] as String? ?? '—';
  String get _dateOfBirth => _patientProfile?['dateOfBirth'] as String? ?? '—';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildProfileCard(),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: 'Account Information',
                            children: [
                              _buildInfoTile(
                                icon: Icons.email_outlined,
                                title: 'Email',
                                value: _email,
                              ),
                              _buildInfoTile(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                value: _phone,
                              ),
                              _buildInfoTile(
                                icon: Icons.cake_outlined,
                                title: 'Date of Birth',
                                value: _dateOfBirth,
                              ),
                              _buildActionTile(
                                icon: LucideIcons.fileText,
                                title: 'Documents',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: 'Settings',
                            children: [
                              _buildActionTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                trailing: Switch(
                                  value: isNotificationsEnabled,
                                  onChanged: (value) =>
                                      setState(() => isNotificationsEnabled = value),
                                  activeThumbColor: AppColors.green,
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
                                onTap: () => _logout(),
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
      ),
    );
  }

  Widget _buildTopHeader() {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'My Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Stack(
            children: [
              InitialsAvatar(
                name: _name,
                imageUrl: _imageUrl,
                size: 100,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/edit-account'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          const ProMemberBadge(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F),
                letterSpacing: -0.5,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.green, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.green, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF1D1D1F),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}

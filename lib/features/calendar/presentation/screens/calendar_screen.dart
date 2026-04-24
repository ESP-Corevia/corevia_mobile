import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:corevia_mobile/l10n/app_localizations.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

enum CalendarTab { programme, list }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.initialTab = CalendarTab.programme});

  final CalendarTab initialTab;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarTab _selectedTab = CalendarTab.programme;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _selectedTab == CalendarTab.programme ? _buildSchedule() : _buildDoctors(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.calendar,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = CalendarTab.programme),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: _selectedTab == CalendarTab.programme
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.l10n.schedule,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: _selectedTab == CalendarTab.programme
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = CalendarTab.list),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == CalendarTab.list ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.l10n.lists,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: _selectedTab == CalendarTab.list
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Center(
      child: Text(
        context.l10n.consultDoctorsToBook,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDoctors() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final doctors = provider.doctors;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  provider.loadDoctors(search: value.trim().isEmpty ? null : value.trim());
                },
                decoration: InputDecoration(
                  hintText: context.l10n.searchDoctor,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      provider.loadDoctors(
                        search: _searchController.text.trim().isEmpty
                            ? null
                            : _searchController.text.trim(),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoadingDoctors
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF34C759)),
                    )
                  : (provider.error != null && doctors.isEmpty)
                      ? _buildDoctorsError(
                          provider.error!,
                          onRetry: () => provider.loadDoctors(
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          ),
                        )
                  : doctors.isEmpty
                      ? Center(child: Text(context.l10n.noDoctorsAvailable))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = doctors[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    child: Text(
                                      doctor.name.isNotEmpty
                                          ? doctor.name[0].toUpperCase()
                                          : 'M',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF34C759),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          doctor.specialty,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${doctor.city} • ${doctor.address}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      context.push(
                                        '/calendar/booking',
                                        extra: {
                                          'doctorId': doctor.id,
                                          'doctorName': doctor.name,
                                          'specialty': doctor.specialty,
                                          'address': doctor.address,
                                          'imageUrl': '',
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Color(0xFF34C759),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorsError(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFB42318),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

}

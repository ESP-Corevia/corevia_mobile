class HomeData {
  final String title;
  final String description;
  final String userName;
  final String? userImage;
  final int alertsCount;
  final int appointmentsThisMonth;
  final int completedAppointments;
  final int pendingAppointments;
  final int medicationAdherenceRate;

  const HomeData({
    required this.title,
    required this.description,
    required this.userName,
    required this.userImage,
    required this.alertsCount,
    required this.appointmentsThisMonth,
    required this.completedAppointments,
    required this.pendingAppointments,
    required this.medicationAdherenceRate,
  });
}

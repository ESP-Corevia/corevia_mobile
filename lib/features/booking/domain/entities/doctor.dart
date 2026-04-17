class Doctor {
  final String id;
  final String userId;
  final String specialty;
  final String address;
  final String city;
  final String name;

  const Doctor({
    required this.id,
    required this.userId,
    required this.specialty,
    required this.address,
    required this.city,
    required this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

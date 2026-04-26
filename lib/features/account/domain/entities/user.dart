class User {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? address;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      image: json['image']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (image != null) 'image': image,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (address != null) 'address': address,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
    );
  }

  String get firstName {
    final parts = name.split(' ');
    return parts.first;
  }

  String get lastName {
    final parts = name.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }
}

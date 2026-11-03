class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? photoUrl;
  final List<Map<String, dynamic>> vehicles;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.photoUrl,
    this.vehicles = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      vehicles: (map['vehicles'] as List<dynamic>?)
              ?.map((v) => Map<String, dynamic>.from(v as Map))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'vehicles': vehicles,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    List<Map<String, dynamic>>? vehicles,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicles: vehicles ?? this.vehicles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mock user
  static UserModel get mock => UserModel(
        id: 'user_mock_001',
        name: 'Rahul Sharma',
        phone: '+91 9876543210',
        email: 'rahul.sharma@email.com',
        photoUrl: null,
        vehicles: const [
          {
            'make': 'Maruti',
            'model': 'Swift',
            'year': '2020',
            'plate': 'MH 02 AB 1234',
            'color': 'Red',
          }
        ],
        createdAt: DateTime(2024, 1, 15),
      );
}

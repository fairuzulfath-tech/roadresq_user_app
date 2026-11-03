import 'service_request_model.dart';

class MechanicModel {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final GeoPoint? currentLocation;
  final List<String> specialization;
  final String? vehicleNumber;
  final String etaMinutes;

  const MechanicModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    this.currentLocation,
    this.specialization = const [],
    this.vehicleNumber,
    this.etaMinutes = '8',
  });

  factory MechanicModel.fromMap(Map<String, dynamic> map) {
    return MechanicModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      isAvailable: map['isAvailable'] as bool? ?? false,
      currentLocation: map['currentLocation'] != null
          ? GeoPoint.fromMap(Map<String, dynamic>.from(map['currentLocation'] as Map))
          : null,
      specialization: (map['specialization'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      vehicleNumber: map['vehicleNumber'] as String?,
      etaMinutes: map['etaMinutes'] as String? ?? '8',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'isAvailable': isAvailable,
      'currentLocation': currentLocation?.toMap(),
      'specialization': specialization,
      'vehicleNumber': vehicleNumber,
      'etaMinutes': etaMinutes,
    };
  }

  static MechanicModel get mock => const MechanicModel(
        id: 'mechanic_mock_001',
        name: 'Vikram Singh',
        phone: '+91 9123456789',
        photoUrl: null,
        rating: 4.7,
        totalReviews: 128,
        isAvailable: true,
        currentLocation: GeoPoint(19.0820, 72.8850),
        specialization: ['Flat Tyre', 'Battery Jump', 'General Repair'],
        vehicleNumber: 'MH 01 TW 5678',
        etaMinutes: '8',
      );
}

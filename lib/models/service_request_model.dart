class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  factory GeoPoint.fromMap(Map<String, dynamic> map) {
    return GeoPoint(
      (map['latitude'] as num).toDouble(),
      (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class ServiceRequestModel {
  final String id;
  final String userId;
  final String? mechanicId;
  final String serviceType;
  final String status;
  final GeoPoint userLocation;
  final GeoPoint? mechanicLocation;
  final String address;
  final String? description;
  final double fare;
  final String paymentStatus;
  final double? rating;
  final String? vehicleInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceRequestModel({
    required this.id,
    required this.userId,
    this.mechanicId,
    required this.serviceType,
    required this.status,
    required this.userLocation,
    this.mechanicLocation,
    required this.address,
    this.description,
    required this.fare,
    this.paymentStatus = 'pending',
    this.rating,
    this.vehicleInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map) {
    return ServiceRequestModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      mechanicId: map['mechanicId'] as String?,
      serviceType: map['serviceType'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      userLocation: map['userLocation'] != null
          ? GeoPoint.fromMap(Map<String, dynamic>.from(map['userLocation'] as Map))
          : const GeoPoint(19.0760, 72.8777),
      mechanicLocation: map['mechanicLocation'] != null
          ? GeoPoint.fromMap(Map<String, dynamic>.from(map['mechanicLocation'] as Map))
          : null,
      address: map['address'] as String? ?? '',
      description: map['description'] as String?,
      fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] as String? ?? 'pending',
      rating: (map['rating'] as num?)?.toDouble(),
      vehicleInfo: map['vehicleInfo'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mechanicId': mechanicId,
      'serviceType': serviceType,
      'status': status,
      'userLocation': userLocation.toMap(),
      'mechanicLocation': mechanicLocation?.toMap(),
      'address': address,
      'description': description,
      'fare': fare,
      'paymentStatus': paymentStatus,
      'rating': rating,
      'vehicleInfo': vehicleInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ServiceRequestModel copyWith({
    String? status,
    GeoPoint? mechanicLocation,
    double? fare,
    String? paymentStatus,
    double? rating,
    String? mechanicId,
  }) {
    return ServiceRequestModel(
      id: id,
      userId: userId,
      mechanicId: mechanicId ?? this.mechanicId,
      serviceType: serviceType,
      status: status ?? this.status,
      userLocation: userLocation,
      mechanicLocation: mechanicLocation ?? this.mechanicLocation,
      address: address,
      description: description,
      fare: fare ?? this.fare,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      rating: rating ?? this.rating,
      vehicleInfo: vehicleInfo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static List<ServiceRequestModel> get mockHistory => [
        ServiceRequestModel(
          id: 'req_001',
          userId: 'user_mock_001',
          mechanicId: 'mechanic_mock_001',
          serviceType: 'flat_tyre',
          status: 'completed',
          userLocation: const GeoPoint(19.0760, 72.8777),
          address: 'Bandra West, Mumbai, Maharashtra',
          description: 'Front left tyre punctured',
          fare: 399.0,
          paymentStatus: 'paid',
          rating: 4.5,
          vehicleInfo: 'Maruti Swift 2020 • MH 02 AB 1234',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3, hours: -2)),
        ),
        ServiceRequestModel(
          id: 'req_002',
          userId: 'user_mock_001',
          mechanicId: 'mechanic_mock_001',
          serviceType: 'battery_jump',
          status: 'completed',
          userLocation: const GeoPoint(19.0880, 72.8920),
          address: 'Andheri East, Mumbai, Maharashtra',
          description: 'Battery dead, need jump start',
          fare: 249.0,
          paymentStatus: 'paid',
          rating: 5.0,
          vehicleInfo: 'Maruti Swift 2020 • MH 02 AB 1234',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10, hours: -1)),
        ),
        ServiceRequestModel(
          id: 'req_003',
          userId: 'user_mock_001',
          mechanicId: 'mechanic_mock_001',
          serviceType: 'fuel_delivery',
          status: 'completed',
          userLocation: const GeoPoint(19.0500, 72.8500),
          address: 'Dadar, Mumbai, Maharashtra',
          description: 'Ran out of fuel on highway',
          fare: 299.0,
          paymentStatus: 'paid',
          rating: 4.0,
          vehicleInfo: 'Maruti Swift 2020 • MH 02 AB 1234',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20, hours: -1)),
        ),
      ];
}

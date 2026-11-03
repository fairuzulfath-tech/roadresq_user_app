import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPermission => _hasPermission;
  bool get hasLocation => _latitude != null && _longitude != null;

  Future<void> fetchCurrentLocation() async {
    _setLoading(true);
    _error = null;
    try {
      final hasPermission = await _locationService.requestPermission();
      _hasPermission = hasPermission;

      if (!hasPermission) {
        // Use mock location for demo
        _latitude = 19.0760;
        _longitude = 72.8777;
        _address = 'Bandra West, Mumbai, Maharashtra';
        _setLoading(false);
        return;
      }

      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = await _locationService.getAddressFromCoords(
          position.latitude,
          position.longitude,
        );
      } else {
        // Fallback to mock location
        _latitude = 19.0760;
        _longitude = 72.8777;
        _address = 'Bandra West, Mumbai, Maharashtra';
      }
    } catch (e) {
      _error = e.toString();
      // Fallback to mock location
      _latitude = 19.0760;
      _longitude = 72.8777;
      _address = 'Bandra West, Mumbai, Maharashtra';
    } finally {
      _setLoading(false);
    }
  }

  void setManualLocation({
    required double lat,
    required double lng,
    required String address,
  }) {
    _latitude = lat;
    _longitude = lng;
    _address = address;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

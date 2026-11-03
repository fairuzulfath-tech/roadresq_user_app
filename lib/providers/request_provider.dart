import 'package:flutter/foundation.dart';
import '../models/service_request_model.dart';
import '../models/mechanic_model.dart';
import '../services/firestore_service.dart';

class RequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ServiceRequestModel? _activeRequest;
  List<ServiceRequestModel> _history = [];
  MechanicModel? _assignedMechanic;
  bool _isLoading = false;
  String? _error;

  ServiceRequestModel? get activeRequest => _activeRequest;
  List<ServiceRequestModel> get history => _history;
  MechanicModel? get assignedMechanic => _assignedMechanic;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActiveRequest(String userId) async {
    _setLoading(true);
    try {
      _activeRequest = await _firestoreService.getActiveRequest(userId);
      if (_activeRequest?.mechanicId != null) {
        _assignedMechanic = await _firestoreService.getMechanicById(
          _activeRequest!.mechanicId!,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ServiceRequestModel?> createRequest({
    required String userId,
    required String serviceType,
    required GeoPoint userLocation,
    required String address,
    String? description,
    String? vehicleInfo,
    required double fare,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final request = ServiceRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        serviceType: serviceType,
        status: 'pending',
        userLocation: userLocation,
        address: address,
        description: description,
        vehicleInfo: vehicleInfo,
        fare: fare,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _firestoreService.createRequest(request);
      _activeRequest = created;

      // Simulate mechanic assignment after a short delay
      await Future.delayed(const Duration(seconds: 1));
      _activeRequest = created.copyWith(
        status: 'accepted',
        mechanicId: MechanicModel.mock.id,
      );
      _assignedMechanic = MechanicModel.mock;
      _setLoading(false);
      return _activeRequest;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<void> cancelRequest() async {
    if (_activeRequest == null) return;
    _setLoading(true);
    try {
      await _firestoreService.cancelRequest(_activeRequest!.id);
      _activeRequest = _activeRequest!.copyWith(status: 'cancelled');
      await Future.delayed(const Duration(milliseconds: 300));
      _activeRequest = null;
      _assignedMechanic = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHistory(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      _history = await _firestoreService.getRequestHistory(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void updateMechanicLocation(GeoPoint location) {
    if (_activeRequest != null) {
      _activeRequest = _activeRequest!.copyWith(mechanicLocation: location);
      notifyListeners();
    }
  }

  void updateStatus(String status) {
    if (_activeRequest != null) {
      _activeRequest = _activeRequest!.copyWith(status: status);
      notifyListeners();
    }
  }

  void clearActiveRequest() {
    _activeRequest = null;
    _assignedMechanic = null;
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

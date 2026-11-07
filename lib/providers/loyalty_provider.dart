import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoyaltyProvider extends ChangeNotifier {
  int _points = 0;
  final List<_LoyaltyTransaction> _transactions = [];
  bool _isLoading = false;

  int get points => _points;
  bool get isLoading => _isLoading;
  List<_LoyaltyTransaction> get transactions =>
      List.unmodifiable(_transactions);

  // Tier thresholds
  static const int silverThreshold = 500;
  static const int goldThreshold = 1500;
  static const int platinumThreshold = 3000;

  String get tier {
    if (_points >= platinumThreshold) return 'Platinum';
    if (_points >= goldThreshold) return 'Gold';
    if (_points >= silverThreshold) return 'Silver';
    return 'Bronze';
  }

  int get nextTierPoints {
    if (_points < silverThreshold) return silverThreshold;
    if (_points < goldThreshold) return goldThreshold;
    if (_points < platinumThreshold) return platinumThreshold;
    return platinumThreshold;
  }

  double get tierProgress {
    if (_points >= platinumThreshold) return 1.0;
    if (_points >= goldThreshold) {
      return (_points - goldThreshold) /
          (platinumThreshold - goldThreshold);
    }
    if (_points >= silverThreshold) {
      return (_points - silverThreshold) / (goldThreshold - silverThreshold);
    }
    return _points / silverThreshold;
  }

  LoyaltyProvider() {
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt('loyalty_points') ?? 240; // start with some mock points
    // Load mock transaction history
    _transactions.addAll([
      _LoyaltyTransaction(
        description: 'Battery Jump Service',
        points: 50,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _LoyaltyTransaction(
        description: 'Flat Tyre Service',
        points: 60,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      _LoyaltyTransaction(
        description: 'Referral Bonus',
        points: 100,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
      _LoyaltyTransaction(
        description: 'Redeemed for Discount',
        points: -30,
        isEarned: false,
        date: DateTime.now().subtract(const Duration(days: 20)),
      ),
      _LoyaltyTransaction(
        description: 'Fuel Delivery Service',
        points: 40,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 25)),
      ),
      _LoyaltyTransaction(
        description: 'Welcome Bonus',
        points: 20,
        isEarned: true,
        date: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPoints(int pts, String description) async {
    _points += pts;
    _transactions.insert(
      0,
      _LoyaltyTransaction(
        description: description,
        points: pts,
        isEarned: true,
        date: DateTime.now(),
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_points', _points);
    notifyListeners();
  }

  Future<bool> redeemPoints(int pts, String description) async {
    if (_points < pts) return false;
    _points -= pts;
    _transactions.insert(
      0,
      _LoyaltyTransaction(
        description: description,
        points: -pts,
        isEarned: false,
        date: DateTime.now(),
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_points', _points);
    notifyListeners();
    return true;
  }
}

class _LoyaltyTransaction {
  final String description;
  final int points;
  final bool isEarned;
  final DateTime date;

  const _LoyaltyTransaction({
    required this.description,
    required this.points,
    required this.isEarned,
    required this.date,
  });
}

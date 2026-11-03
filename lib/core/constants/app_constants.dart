import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'RoadResQ';
  static const String appTagline = 'Help is always on the way';

  // Service Types
  static const List<Map<String, dynamic>> serviceTypes = [
    {
      'id': 'flat_tyre',
      'title': 'Flat Tyre',
      'subtitle': 'Tyre change & repair',
      'icon': Icons.tire_repair,
      'color': Color(0xFF1565C0),
      'gradientColors': [Color(0xFF1565C0), Color(0xFF42A5F5)],
      'basePrice': 299,
      'eta': '10–15 min',
    },
    {
      'id': 'fuel_delivery',
      'title': 'Fuel Delivery',
      'subtitle': 'Emergency fuel supply',
      'icon': Icons.local_gas_station,
      'color': Color(0xFF2E7D32),
      'gradientColors': [Color(0xFF2E7D32), Color(0xFF66BB6A)],
      'basePrice': 199,
      'eta': '15–20 min',
    },
    {
      'id': 'towing',
      'title': 'Towing',
      'subtitle': 'Vehicle tow service',
      'icon': Icons.local_shipping,
      'color': Color(0xFF6A1B9A),
      'gradientColors': [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
      'basePrice': 599,
      'eta': '20–30 min',
    },
    {
      'id': 'battery_jump',
      'title': 'Battery Jump',
      'subtitle': 'Dead battery start',
      'icon': Icons.battery_charging_full,
      'color': Color(0xFFF57F17),
      'gradientColors': [Color(0xFFF57F17), Color(0xFFFFCA28)],
      'basePrice': 249,
      'eta': '8–12 min',
    },
    {
      'id': 'lockout',
      'title': 'Lockout',
      'subtitle': 'Car door unlock',
      'icon': Icons.lock_open,
      'color': Color(0xFFC62828),
      'gradientColors': [Color(0xFFC62828), Color(0xFFEF5350)],
      'basePrice': 349,
      'eta': '12–18 min',
    },
    {
      'id': 'general_repair',
      'title': 'General Repair',
      'subtitle': 'On-site mechanical help',
      'icon': Icons.build,
      'color': Color(0xFF00695C),
      'gradientColors': [Color(0xFF00695C), Color(0xFF26A69A)],
      'basePrice': 499,
      'eta': '15–25 min',
    },
  ];

  // Status labels
  static const Map<String, String> statusLabels = {
    'pending': 'Pending',
    'accepted': 'Accepted',
    'en_route': 'En Route',
    'arrived': 'Arrived',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  static const Map<String, Color> statusColors = {
    'pending': Color(0xFFF57F17),
    'accepted': Color(0xFF1565C0),
    'en_route': Color(0xFF1976D2),
    'arrived': Color(0xFF2E7D32),
    'completed': Color(0xFF2E7D32),
    'cancelled': Color(0xFFC62828),
  };

  // Mock data
  static const String mockUserId = 'user_mock_001';
  static const String mockMechanicId = 'mechanic_mock_001';

  // SharedPreferences keys
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';
  static const String prefUserPhone = 'user_phone';

  // Safety tips
  static const List<Map<String, dynamic>> safetyTips = [
    {
      'tip': 'Always keep your vehicle documents handy for faster service.',
      'icon': Icons.description_outlined,
    },
    {
      'tip': 'Keep emergency contacts saved on your phone for quick access.',
      'icon': Icons.contacts_outlined,
    },
    {
      'tip': 'Check your tyre pressure at least once a month.',
      'icon': Icons.tire_repair_outlined,
    },
    {
      'tip': 'Keep a basic toolkit in your car boot at all times.',
      'icon': Icons.build_outlined,
    },
    {
      'tip': 'Stay calm and turn on hazard lights if your vehicle breaks down.',
      'icon': Icons.warning_amber_outlined,
    },
  ];

  // Promo banners
  static const List<Map<String, dynamic>> promoBanners = [
    {
      'title': '20% OFF on First Service!',
      'subtitle': 'Use code ROADHELP20 at checkout',
      'color': Color(0xFFFF6F00),
      'icon': Icons.local_offer,
    },
    {
      'title': 'Refer & Earn ₹100',
      'subtitle': 'Invite friends, get rewarded instantly',
      'color': Color(0xFF6A1B9A),
      'icon': Icons.people_alt_outlined,
    },
    {
      'title': 'Annual Membership',
      'subtitle': 'Unlimited services at ₹999/year',
      'color': Color(0xFF2E7D32),
      'icon': Icons.card_membership,
    },
  ];
}

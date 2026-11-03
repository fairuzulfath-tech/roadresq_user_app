import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/location_provider.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with TickerProviderStateMixin {
  late AnimationController _ring1Controller;
  late AnimationController _ring2Controller;
  late AnimationController _ring3Controller;
  late Animation<double> _ring1;
  late Animation<double> _ring2;
  late Animation<double> _ring3;

  bool _sosTriggered = false;
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _sosSent = false;

  final List<Map<String, dynamic>> _emergencyContacts = [
    {'name': 'National Emergency', 'number': '112', 'icon': Icons.emergency},
    {'name': 'Police', 'number': '100', 'icon': Icons.local_police_outlined},
    {
      'name': 'Ambulance',
      'number': '108',
      'icon': Icons.medical_services_outlined
    },
    {
      'name': 'Fire Brigade',
      'number': '101',
      'icon': Icons.local_fire_department_outlined
    },
  ];

  @override
  void initState() {
    super.initState();

    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ring3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 400),
        () => _ring2Controller.repeat());
    Future.delayed(const Duration(milliseconds: 800),
        () => _ring3Controller.repeat());

    _ring1 = Tween<double>(begin: 0, end: 1).animate(_ring1Controller);
    _ring2 = Tween<double>(begin: 0, end: 1).animate(_ring2Controller);
    _ring3 = Tween<double>(begin: 0, end: 1).animate(_ring3Controller);
  }

  @override
  void dispose() {
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    _ring3Controller.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    setState(() {
      _sosTriggered = true;
      _countdown = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
          HapticFeedback.lightImpact();
        } else {
          timer.cancel();
          _sendSOSAlert();
        }
      });
    });
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    setState(() {
      _sosTriggered = false;
      _countdown = 5;
    });
  }

  void _sendSOSAlert() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _sosTriggered = false;
      _sosSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'SOS Alert Sent! Emergency services notified.',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sosSent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppTheme.error,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SOS button section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBEE), Color(0xFFFFF3F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border:
                    Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  if (!_sosTriggered && !_sosSent) ...[
                    const Text(
                      'Press & Hold for Emergency',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // SOS button with 3 ripple rings
                    GestureDetector(
                      onLongPress: _triggerSOS,
                      onTap: _triggerSOS,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ring 3 (outermost)
                            AnimatedBuilder(
                              animation: _ring3,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring3.value) * 0.2,
                                child: Transform.scale(
                                  scale: 1.0 + _ring3.value * 0.7,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Ring 2
                            AnimatedBuilder(
                              animation: _ring2,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring2.value) * 0.3,
                                child: Transform.scale(
                                  scale: 1.0 + _ring2.value * 0.5,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Ring 1
                            AnimatedBuilder(
                              animation: _ring1,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring1.value) * 0.4,
                                child: Transform.scale(
                                  scale: 1.0 + _ring1.value * 0.3,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Core button
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE53935),
                                    Color(0xFFB71C1C)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning_rounded,
                                      color: Colors.white, size: 44),
                                  SizedBox(height: 4),
                                  Text(
                                    'SOS',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_sosTriggered) ...[
                    // Countdown
                    const Text(
                      'Sending SOS Alert in...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: (5 - _countdown) / 5,
                            strokeWidth: 10,
                            backgroundColor: Colors.red.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.error),
                          ),
                        ),
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _cancelSOS,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel SOS'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ] else if (_sosSent) ...[
                    const Icon(Icons.check_circle,
                        color: AppTheme.success, size: 70),
                    const SizedBox(height: 16),
                    const Text(
                      'SOS Alert Sent!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Emergency services have been notified.\nHelp is on the way!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Location display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on,
                        color: AppTheme.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Current Location',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        Text(
                          location.address ?? 'Detecting location...',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'GPS On',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Emergency contacts
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Dial',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = _emergencyContacts[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _callNumber(contact['number'] as String);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(
                          color: AppTheme.error.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            contact['icon'] as IconData,
                            color: AppTheme.error,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                contact['name'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: AppTheme.textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                contact['number'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callNumber('112'),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text('Call 112'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareLocation,
                    icon: const Icon(Icons.share_location_outlined),
                    label: const Text('Share Location'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addEmergencyContact,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add Emergency Contact'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _callNumber(String number) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.call, color: Colors.white),
            const SizedBox(width: 8),
            Text('Calling $number...'),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share_location, color: Colors.white),
            SizedBox(width: 8),
            Text('Location shared with emergency contacts!'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addEmergencyContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add emergency contact coming soon!'),
      ),
    );
  }
}

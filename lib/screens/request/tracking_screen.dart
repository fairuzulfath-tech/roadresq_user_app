import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/service_request_model.dart';
import '../../models/mechanic_model.dart';
import '../../providers/request_provider.dart';
import '../chat/chat_screen.dart';
import '../ratings/rating_screen.dart';
import 'mechanic_detail_screen.dart';

class TrackingScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const TrackingScreen({super.key, required this.request});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  late ServiceRequestModel _request;
  final MechanicModel _mechanic = MechanicModel.mock;
  int _etaMinutes = 8;
  Timer? _statusTimer;
  Timer? _etaTimer;

  late AnimationController _mapMechanicController;
  late Animation<Offset> _mechanicPosition;

  late AnimationController _beaconController;
  late Animation<double> _beaconScale;

  final List<String> _statusFlow = [
    'pending',
    'accepted',
    'en_route',
    'arrived',
    'completed',
  ];

  int get _currentStatusIndex =>
      _statusFlow.indexOf(_request.status).clamp(0, _statusFlow.length - 1);

  @override
  void initState() {
    super.initState();
    _request = widget.request;

    // Mechanic moving animation
    _mapMechanicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: false);

    _mechanicPosition = Tween<Offset>(
      begin: const Offset(0.2, 0.15),
      end: const Offset(0.5, 0.48),
    ).animate(CurvedAnimation(
        parent: _mapMechanicController, curve: Curves.easeInOut));

    // Beacon pulse
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: false);
    _beaconScale = Tween<double>(begin: 1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _beaconController, curve: Curves.easeOut));

    _simulateProgress();
    _startEtaCountdown();
  }

  void _simulateProgress() {
    _statusTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextIndex = _currentStatusIndex + 1;
      if (nextIndex < _statusFlow.length) {
        final newStatus = _statusFlow[nextIndex];
        HapticFeedback.mediumImpact();
        setState(() {
          _request = _request.copyWith(status: newStatus);
        });
        context.read<RequestProvider>().updateStatus(newStatus);

        if (newStatus == 'completed') {
          timer.cancel();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                AppTheme.slideRoute(RatingScreen(
                  mechanic: _mechanic,
                  requestId: _request.id,
                )),
              );
            }
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startEtaCountdown() {
    _etaTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      if (_etaMinutes > 1) {
        setState(() => _etaMinutes--);
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _etaTimer?.cancel();
    _mapMechanicController.dispose();
    _beaconController.dispose();
    super.dispose();
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request?'),
        content: const Text(
            'Are you sure you want to cancel this service request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<RequestProvider>().cancelRequest();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (_request.status != 'completed' &&
              _request.status != 'cancelled')
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelRequest,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: Column(
        children: [
          // Animated Map
          Container(
            height: 230,
            decoration: const BoxDecoration(
              color: Color(0xFFE3EDF9),
            ),
            child: Stack(
              children: [
                // Map grid background
                CustomPaint(
                  size: Size(size.width, 230),
                  painter: _AnimatedMapPainter(),
                ),

                // Dashed route line
                CustomPaint(
                  size: Size(size.width, 230),
                  painter: _RoutePainter(
                    start: Offset(size.width * 0.5, 165),
                    end: Offset(size.width * 0.28, 50),
                  ),
                ),

                // User beacon (pulsing)
                Positioned(
                  left: size.width * 0.5 - 18,
                  top: 143,
                  child: AnimatedBuilder(
                    animation: _beaconController,
                    builder: (_, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: (1 - _beaconController.value) * 0.4,
                            child: Transform.scale(
                              scale: _beaconScale.value,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.error.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          child!,
                        ],
                      );
                    },
                    child: const Icon(
                      Icons.location_pin,
                      color: AppTheme.error,
                      size: 38,
                    ),
                  ),
                ),

                // Mechanic moving pin
                AnimatedBuilder(
                  animation: _mechanicPosition,
                  builder: (_, __) {
                    return Positioned(
                      left: size.width * _mechanicPosition.value.dx - 18,
                      top: 230 * _mechanicPosition.value.dy,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.engineering,
                            color: Colors.white, size: 20),
                      ),
                    );
                  },
                ),

                // Labels
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.floatShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Live GPS Tracking',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status indicator strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppTheme.primary,
            child: _StatusStrip(status: _request.status),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mechanic card
                  _MechanicCard(
                    mechanic: _mechanic,
                    etaMinutes: _etaMinutes,
                    onViewProfile: () {
                      Navigator.push(
                        context,
                        AppTheme.slideRoute(
                            MechanicDetailScreen(mechanic: _mechanic)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status stepper
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Progress',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._buildStatusSteps(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  if (_request.status != 'completed' &&
                      _request.status != 'cancelled')
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Chat',
                            color: AppTheme.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                AppTheme.slideRoute(ChatScreen(
                                  requestId: _request.id,
                                  mechanicName: _mechanic.name,
                                )),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.call_outlined,
                            label: 'Call',
                            color: AppTheme.success,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Calling ${_mechanic.name}...'),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.cancel_outlined,
                            label: 'Cancel',
                            color: AppTheme.error,
                            onTap: _cancelRequest,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusSteps() {
    final steps = [
      ('pending', 'Request Sent', Icons.send_outlined),
      ('accepted', 'Mechanic Assigned', Icons.check_circle_outline),
      ('en_route', 'En Route to You', Icons.directions_bike_outlined),
      ('arrived', 'Mechanic Arrived', Icons.location_on_outlined),
      ('completed', 'Service Completed', Icons.done_all),
    ];

    final currentIdx = _currentStatusIndex;
    final List<Widget> widgets = [];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final isCompleted = i < currentIdx;
      final isCurrent = i == currentIdx;
      final isUpcoming = i > currentIdx;

      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppTheme.primary
                        : AppTheme.divider,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : step.$3,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                if (i < steps.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 2.5,
                    height: 30,
                    color: isCompleted ? AppTheme.primary : AppTheme.divider,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: i < steps.length - 1 ? 30 : 0,
                  top: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.$2,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isUpcoming
                              ? AppTheme.textLight
                              : AppTheme.textDark,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '● Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    if (isCompleted)
                      const Icon(Icons.check_circle,
                          color: AppTheme.success, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return widgets;
  }
}

class _StatusStrip extends StatelessWidget {
  final String status;

  const _StatusStrip({required this.status});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'pending': 'Finding a mechanic nearby...',
      'accepted': 'Mechanic accepted your request!',
      'en_route': 'Mechanic is on the way to you',
      'arrived': 'Mechanic has arrived!',
      'completed': 'Service completed successfully',
    };

    final icons = {
      'pending': Icons.hourglass_empty,
      'accepted': Icons.check_circle,
      'en_route': Icons.directions_bike,
      'arrived': Icons.location_on,
      'completed': Icons.done_all,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icons[status] ?? Icons.info,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          labels[status] ?? status,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _MechanicCard extends StatelessWidget {
  final MechanicModel mechanic;
  final int etaMinutes;
  final VoidCallback onViewProfile;

  const _MechanicCard({
    required this.mechanic,
    required this.etaMinutes,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Mechanic avatar
          GestureDetector(
            onTap: onViewProfile,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.engineering, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mechanic.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      '${mechanic.rating}  (${mechanic.totalReviews} reviews)',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onViewProfile,
                  child: const Text(
                    'View profile →',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ETA badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$etaMinutes',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'min ETA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map painter with better styling
class _AnimatedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFB8D4F0)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.28, 0), Offset(size.width * 0.28, size.height), roadPaint);

    // Road markings (dashes)
    final dashPaint = Paint()
      ..color = const Color(0xFFDDE8F5)
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(size.width * 0.5, y),
          Offset(size.width * 0.5, y + 10), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _RoutePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      start.dx,
      start.dy - 60,
      end.dx,
      end.dy + 60,
      end.dx,
      end.dy,
    );

    // Draw dashed path
    const dashWidth = 10.0;
    const dashSpace = 6.0;
    final pathMetrics = path.computeMetrics();
    for (final pm in pathMetrics) {
      double distance = 0;
      while (distance < pm.length) {
        final segment = pm.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

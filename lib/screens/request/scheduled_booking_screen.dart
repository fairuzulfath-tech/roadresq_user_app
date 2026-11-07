import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';

class ScheduledBookingScreen extends StatefulWidget {
  const ScheduledBookingScreen({super.key});

  @override
  State<ScheduledBookingScreen> createState() => _ScheduledBookingScreenState();
}

class _ScheduledBookingScreenState extends State<ScheduledBookingScreen> {
  Map<String, dynamic>? _selectedService;
  String? _selectedVehicle;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isBooking = false;
  bool _booked = false;

  static const List<String> _timeSlots = [
    '8:00 AM – 10:00 AM',
    '10:00 AM – 12:00 PM',
    '12:00 PM – 2:00 PM',
    '2:00 PM – 4:00 PM',
    '4:00 PM – 6:00 PM',
    '6:00 PM – 8:00 PM',
  ];

  // Slots "unavailable" for demo
  static const Set<String> _unavailableSlots = {
    '12:00 PM – 2:00 PM',
    '4:00 PM – 6:00 PM',
  };

  @override
  void initState() {
    super.initState();
    final location = context.read<LocationProvider>();
    if (location.address != null) {
      _addressController.text = location.address!;
    }
    final auth = context.read<AuthProvider>();
    if (auth.currentUser?.vehicles.isNotEmpty == true) {
      final v = auth.currentUser!.vehicles.first;
      _selectedVehicle =
          '${v['make']} ${v['model']} ${v['year']} • ${v['plate']}';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppTheme.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // reset slot on date change
      });
    }
  }

  Future<void> _book() async {
    if (_selectedService == null) {
      _showError('Please select a service type');
      return;
    }
    if (_addressController.text.isEmpty) {
      _showError('Please enter your address');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }
    if (_selectedTimeSlot == null) {
      _showError('Please select a time slot');
      return;
    }

    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isBooking = false;
      _booked = true;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_booked) return _BookingConfirmation(
      service: _selectedService!,
      date: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      address: _addressController.text,
      onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
    );

    final auth = context.watch<AuthProvider>();
    final vehicles = auth.currentUser?.vehicles ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Schedule a Service'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Book a service for a future date & time. A mechanic will be assigned 30 minutes before your slot.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Service type
            _StepHeader(step: '1', title: 'Select Service Type'),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.serviceTypes.length,
                itemBuilder: (context, i) {
                  final service = AppConstants.serviceTypes[i];
                  final isSelected = _selectedService?['id'] == service['id'];
                  final color = service['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedService = service),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: i < AppConstants.serviceTypes.length - 1 ? 10 : 0),
                      width: 90,
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : AppTheme.divider,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [] : AppTheme.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(service['icon'] as IconData,
                              color: color, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            service['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? color : AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Step 2: Vehicle
            _StepHeader(step: '2', title: 'Vehicle'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.cardShadow,
              ),
              child: vehicles.isEmpty
                  ? ListTile(
                      leading: const Icon(Icons.directions_car, color: AppTheme.primary),
                      title: const Text(
                        'No vehicles added',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      ),
                      subtitle: const Text(
                        'Go to Profile → My Vehicles to add one',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedVehicle,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.directions_car_outlined,
                            color: AppTheme.primary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                      items: vehicles.map((v) {
                        final label =
                            '${v['make']} ${v['model']} ${v['year']} • ${v['plate']}';
                        return DropdownMenuItem(value: label, child: Text(label));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedVehicle = v),
                    ),
            ),
            const SizedBox(height: 20),

            // Step 3: Address
            _StepHeader(step: '3', title: 'Service Address'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.cardShadow,
              ),
              child: TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter full address where service is needed',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppTheme.primary),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Step 4: Date
            _StepHeader(step: '4', title: 'Select Date'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.cardShadow,
                  border: _selectedDate != null
                      ? Border.all(
                          color: AppTheme.primary.withOpacity(0.4), width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today,
                          color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _selectedDate == null
                          ? 'Tap to pick a date'
                          : DateFormat('EEEE, d MMMM yyyy')
                              .format(_selectedDate!),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedDate != null
                            ? AppTheme.textDark
                            : AppTheme.textLight,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppTheme.textLight, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Step 5: Time Slot
            _StepHeader(step: '5', title: 'Select Time Slot'),
            const SizedBox(height: 10),
            if (_selectedDate == null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.divider.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock_outlined,
                        color: AppTheme.textLight, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Please select a date first',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemCount: _timeSlots.length,
                itemBuilder: (context, i) {
                  final slot = _timeSlots[i];
                  final isUnavailable = _unavailableSlots.contains(slot);
                  final isSelected = _selectedTimeSlot == slot;

                  return GestureDetector(
                    onTap: isUnavailable
                        ? null
                        : () => setState(() => _selectedTimeSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isUnavailable
                            ? AppTheme.divider.withOpacity(0.5)
                            : isSelected
                                ? AppTheme.primary
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.divider,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected ? [] : AppTheme.cardShadow,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isUnavailable
                                    ? AppTheme.textLight
                                    : isSelected
                                        ? Colors.white
                                        : AppTheme.textDark,
                              ),
                            ),
                            if (isUnavailable)
                              const Text(
                                'Unavailable',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  color: AppTheme.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Notes
            _StepHeader(step: '6', title: 'Additional Notes (Optional)'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.cardShadow,
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any specific details about the issue...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Book button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String step;
  final String title;

  const _StepHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Booking Confirmation ──────────────────────────────────────────────────

class _BookingConfirmation extends StatelessWidget {
  final Map<String, dynamic> service;
  final DateTime date;
  final String timeSlot;
  final String address;
  final VoidCallback onDone;

  const _BookingConfirmation({
    required this.service,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.check_rounded, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your service has been scheduled. We\'ll send you a reminder 30 mins before.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _ConfirmRow(
                      icon: service['icon'] as IconData,
                      label: 'Service',
                      value: service['title'] as String,
                      color: service['color'] as Color,
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('EEEE, d MMMM yyyy').format(date),
                      color: AppTheme.primary,
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: timeSlot,
                      color: AppTheme.accent,
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: address.length > 45
                          ? '${address.substring(0, 45)}...'
                          : address,
                      color: AppTheme.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.receipt_outlined, color: AppTheme.accent, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Booking ID: SCH-2026-00147',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                value,
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
      ],
    );
  }
}

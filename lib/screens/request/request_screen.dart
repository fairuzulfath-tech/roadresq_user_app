import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/service_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/location_provider.dart';
import 'tracking_screen.dart';

class RequestScreen extends StatefulWidget {
  final Map<String, dynamic> serviceType;

  const RequestScreen({super.key, required this.serviceType});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedVehicle;
  bool _isRequesting = false;

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
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _fareEstimate {
    final base = (widget.serviceType['basePrice'] as int).toDouble();
    return base + 50.0; // base + distance charge
  }

  Future<void> _submitRequest() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your location'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isRequesting = true);
    final requestProvider = context.read<RequestProvider>();
    final location = context.read<LocationProvider>();
    final auth = context.read<AuthProvider>();

    final result = await requestProvider.createRequest(
      userId: auth.currentUser?.id ?? 'user_mock_001',
      serviceType: widget.serviceType['id'] as String,
      userLocation: GeoPoint(
        location.latitude ?? 19.0760,
        location.longitude ?? 72.8777,
      ),
      address: _addressController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      vehicleInfo: _selectedVehicle,
      fare: _fareEstimate,
    );

    setState(() => _isRequesting = false);

    if (result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(request: result),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create request. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final icon = widget.serviceType['icon'] as IconData;
    final color = widget.serviceType['color'] as Color;
    final title = widget.serviceType['title'] as String;
    final subtitle = widget.serviceType['subtitle'] as String;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Request $title'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service info card
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Your Location'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter or confirm your location',
                prefixIcon: const Icon(Icons.location_on, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: AppTheme.primary),
                  onPressed: () {
                    final loc = context.read<LocationProvider>();
                    if (loc.address != null) {
                      _addressController.text = loc.address!;
                    }
                  },
                ),
              ),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 16),

            // Vehicle selector
            if (auth.currentUser?.vehicles.isNotEmpty == true) ...[
              _buildLabel('Select Vehicle'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedVehicle,
                    hint: const Text('Select vehicle'),
                    items: auth.currentUser!.vehicles.map((v) {
                      final label =
                          '${v['make']} ${v['model']} ${v['year']} • ${v['plate']}';
                      return DropdownMenuItem(
                        value: label,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedVehicle = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildLabel('Description / Notes (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your problem in detail...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 20),

            // Fare estimate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fare Estimate',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Icon(Icons.info_outline,
                          size: 16, color: AppTheme.textLight),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FareRow(
                      'Base Charge',
                      '₹${widget.serviceType['basePrice']}'),
                  const SizedBox(height: 6),
                  const _FareRow('Distance Charge', '₹50'),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimate',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '₹${_fareEstimate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Request button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
                child: _isRequesting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.handyman, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Request Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMedium,
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;

  const _FareRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppTheme.textMedium,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

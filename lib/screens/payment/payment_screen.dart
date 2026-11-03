import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String serviceType;
  final String requestId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.serviceType,
    required this.requestId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPayment = 0;
  bool _isPaying = false;
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCVVController = TextEditingController();

  late AnimationController _successController;
  bool _showSuccess = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'UPI',
      'icon': Icons.account_balance,
      'desc': 'Pay via UPI ID or QR',
      'color': const Color(0xFF6A1B9A),
    },
    {
      'name': 'Credit / Debit Card',
      'icon': Icons.credit_card,
      'desc': 'Visa, MasterCard, RuPay',
      'color': const Color(0xFF1565C0),
    },
    {
      'name': 'Cash',
      'icon': Icons.money,
      'desc': 'Pay cash to mechanic',
      'color': const Color(0xFF2E7D32),
    },
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCVVController.dispose();
    _successController.dispose();
    super.dispose();
  }

  double get _tax => widget.amount * 0.18;
  double get _total => widget.amount + _tax;

  Future<void> _pay() async {
    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isPaying = false;
      _showSuccess = true;
    });
    await _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _SuccessScreen(
        amount: _total,
        onDone: () {
          Navigator.of(context).pop();
        },
      );
    }

    final double basePrice = widget.amount - 50;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Payable',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.serviceType.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fare breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bill Summary',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _BillRow(
                      label: 'Service Charge',
                      value: '₹${basePrice.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  const _BillRow(label: 'Distance Charge', value: '₹50'),
                  const SizedBox(height: 8),
                  _BillRow(
                      label: 'GST (18%)',
                      value: '₹${_tax.toStringAsFixed(0)}',
                      isHighlighted: false),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '₹${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Payment methods
            ...List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              final isSelected = _selectedPayment == index;
              final color = method['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedPayment = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : AppTheme.divider,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(method['icon'] as IconData,
                                color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? color
                                        : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  method['desc'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: _selectedPayment,
                            onChanged: (val) =>
                                setState(() => _selectedPayment = val!),
                            activeColor: color,
                          ),
                        ],
                      ),

                      // Expandable input fields
                      if (isSelected && index == 0) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: _upiController,
                          decoration: InputDecoration(
                            hintText: 'Enter UPI ID (e.g. name@upi)',
                            prefixIcon: const Icon(Icons.alternate_email,
                                color: AppTheme.primary),
                            fillColor: AppTheme.background,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: color.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: color, width: 2),
                            ),
                          ),
                        ),
                      ],

                      if (isSelected && index == 1) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          maxLength: 19,
                          decoration: InputDecoration(
                            hintText: 'Card Number',
                            counterText: '',
                            prefixIcon: const Icon(Icons.credit_card,
                                color: AppTheme.primary),
                            fillColor: AppTheme.background,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: color.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: color, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cardExpiryController,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  fillColor: AppTheme.background,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: color.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: color, width: 2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cardCVVController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  hintText: 'CVV',
                                  counterText: '',
                                  fillColor: AppTheme.background,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: color.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: color, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),
            // Security badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline,
                    size: 13, color: AppTheme.textLight),
                const SizedBox(width: 6),
                const Text(
                  'Secured by 256-bit SSL encryption',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isPaying ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
                child: _isPaying
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pay ₹${_total.toStringAsFixed(0)} Securely',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
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
}

class _SuccessScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onDone;

  const _SuccessScreen({required this.amount, required this.onDone});

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _confettiController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  final List<_ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();

    final rng = Random();
    for (int i = 0; i < 20; i++) {
      _confetti.add(_ConfettiPiece(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.5,
        color: [
          AppTheme.primary,
          AppTheme.accent,
          AppTheme.success,
          Colors.amber,
          Colors.pink,
        ][rng.nextInt(5)],
      ));
    }

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.4),
      ),
    );

    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _confettiController.forward());
  }

  @override
  void dispose() {
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Confetti
          ...(_confetti.map((c) => AnimatedBuilder(
                animation: _confettiController,
                builder: (_, __) {
                  final progress =
                      (_confettiController.value - c.delay).clamp(0.0, 1.0);
                  return Positioned(
                    left: MediaQuery.of(context).size.width * c.x,
                    top: -20 +
                        progress *
                            MediaQuery.of(context).size.height *
                            0.7,
                    child: Opacity(
                      opacity: (1 - progress).clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: progress * 3.14 * 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: c.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ))),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _checkController,
                      builder: (_, child) => Opacity(
                        opacity: _checkOpacity.value,
                        child: Transform.scale(
                          scale: _checkScale.value,
                          child: child,
                        ),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
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
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 52),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹${widget.amount.toStringAsFixed(0)} paid successfully.',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thank you for using RoadResQ! 🙏',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: widget.onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final Color color;

  _ConfettiPiece(
      {required this.x, required this.delay, required this.color});
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _BillRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppTheme.accent : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

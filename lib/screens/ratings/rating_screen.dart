import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mechanic_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class RatingScreen extends StatefulWidget {
  final MechanicModel mechanic;
  final String requestId;

  const RatingScreen({
    super.key,
    required this.mechanic,
    required this.requestId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  final _firestoreService = FirestoreService();

  final List<String> _quickFeedbacks = [
    'Great service! 👍',
    'Very professional',
    'Fast response',
    'Friendly mechanic',
    'Fixed quickly',
  ];

  final List<bool> _selectedFeedbacks = [false, false, false, false, false];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    final selectedTags = _quickFeedbacks
        .where((_, ) => _selectedFeedbacks[_quickFeedbacks.indexOf(_)])
        .toList();

    String comment = _commentController.text.trim();
    if (selectedTags.isNotEmpty && comment.isEmpty) {
      comment = selectedTags.join(', ');
    }

    final review = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      userId: auth.currentUser?.id ?? 'user_mock_001',
      mechanicId: widget.mechanic.id,
      requestId: widget.requestId,
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
      createdAt: DateTime.now(),
    );

    await _firestoreService.submitReview(review);
    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your feedback helps us improve our service quality.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mechanic card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering,
                        size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.mechanic.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.mechanic.rating} (${widget.mechanic.totalReviews} reviews)',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'How was your experience?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Star rating
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 44,
                    itemPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_rating > 0)
                    Text(
                      _getRatingLabel(_rating),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick feedback tags
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Feedback',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_quickFeedbacks.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFeedbacks[index] =
                          !_selectedFeedbacks[index];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedFeedbacks[index]
                          ? AppTheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedFeedbacks[index]
                            ? AppTheme.primary
                            : AppTheme.divider,
                      ),
                      boxShadow: _selectedFeedbacks[index]
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      _quickFeedbacks[index],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedFeedbacks[index]
                            ? Colors.white
                            : AppTheme.textDark,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Comment box
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Additional Comments (Optional)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tell us more about your experience...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 12, left: 12),
                  child: Icon(Icons.comment_outlined),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Submit Review',
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
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating <= 1) return '😞 Very Poor';
    if (rating <= 2) return '😕 Poor';
    if (rating <= 3) return '😐 Average';
    if (rating <= 4) return '😊 Good';
    return '😍 Excellent!';
  }
}

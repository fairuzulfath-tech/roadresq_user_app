import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mechanic_model.dart';

class MechanicDetailScreen extends StatelessWidget {
  final MechanicModel mechanic;

  const MechanicDetailScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with mechanic info
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: const Icon(Icons.engineering,
                                size: 44, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            mechanic.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${mechanic.rating} • ${mechanic.totalReviews} reviews',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '✅ Verified Mechanic',
                              style: TextStyle(
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
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                          child: _StatTile(
                              label: 'Jobs Done',
                              value: '248',
                              icon: Icons.build_circle_outlined,
                              color: AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatTile(
                              label: 'Avg Response',
                              value: '6 min',
                              icon: Icons.timer_outlined,
                              color: AppTheme.success)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatTile(
                              label: 'Experience',
                              value: '5 yrs',
                              icon: Icons.workspace_premium_outlined,
                              color: AppTheme.accent)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  _SectionCard(
                    title: 'About',
                    child: const Text(
                      'Ramesh Kumar is a certified automotive mechanic with 5+ years of experience in roadside assistance. Specializes in tyre repairs, battery jumpstarts, and engine diagnostics. Known for his punctuality and professional approach.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppTheme.textMedium,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specializations
                  _SectionCard(
                    title: 'Specializations',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Flat Tyre Repair',
                        'Battery Jumpstart',
                        'Fuel Delivery',
                        'Car Lockout',
                        'Engine Diagnostics',
                        'General Repairs',
                      ]
                          .map((s) => Chip(
                                label: Text(
                                  s,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.1),
                                side: BorderSide(
                                    color: AppTheme.primary.withOpacity(0.3)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating breakdown
                  _SectionCard(
                    title: 'Rating Breakdown',
                    child: Column(
                      children: [
                        _RatingRow(stars: 5, percentage: 0.78),
                        _RatingRow(stars: 4, percentage: 0.15),
                        _RatingRow(stars: 3, percentage: 0.05),
                        _RatingRow(stars: 2, percentage: 0.01),
                        _RatingRow(stars: 1, percentage: 0.01),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Call button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${mechanic.name}...'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.call),
                      label: Text('Call ${mechanic.name}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final int stars;
  final double percentage;

  const _RatingRow({required this.stars, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppTheme.textMedium,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppTheme.divider,
                color: Colors.amber,
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

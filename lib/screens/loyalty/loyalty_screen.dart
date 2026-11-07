import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/loyalty_provider.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Loyalty Rewards'),
        backgroundColor: AppTheme.primary,
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, loyalty, _) {
          if (loyalty.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header card with points
                _PointsHeroCard(loyalty: loyalty),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // How to earn
                      const _SectionTitle('How to Earn Points'),
                      const SizedBox(height: 10),
                      _EarnCard(
                        icon: Icons.build_outlined,
                        title: 'Complete a Service',
                        subtitle:
                            'Earn 10 pts per ₹100 spent on any service',
                        points: '+10–60 pts',
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 10),
                      _EarnCard(
                        icon: Icons.people_outline,
                        title: 'Refer a Friend',
                        subtitle:
                            'Get 100 points when your referral completes first service',
                        points: '+100 pts',
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 10),
                      _EarnCard(
                        icon: Icons.star_outline,
                        title: 'Leave a Review',
                        subtitle: 'Rate your mechanic after service',
                        points: '+20 pts',
                        color: const Color(0xFFF57F17),
                      ),
                      const SizedBox(height: 10),
                      _EarnCard(
                        icon: Icons.cake_outlined,
                        title: 'Birthday Bonus',
                        subtitle: 'Special bonus points on your birthday',
                        points: '+50 pts',
                        color: const Color(0xFF6A1B9A),
                      ),

                      const SizedBox(height: 24),

                      // Redeem section
                      const _SectionTitle('Redeem Points'),
                      const SizedBox(height: 10),
                      _RedeemCard(
                        title: 'Flat ₹30 Off',
                        subtitle: 'On your next service booking',
                        pointsNeeded: 100,
                        currentPoints: loyalty.points,
                        onRedeem: () =>
                            _showRedeemDialog(context, loyalty, 100,
                                'Redeemed for ₹30 off', '₹30 off'),
                      ),
                      const SizedBox(height: 10),
                      _RedeemCard(
                        title: 'Flat ₹75 Off',
                        subtitle: 'On towing or general repair',
                        pointsNeeded: 250,
                        currentPoints: loyalty.points,
                        onRedeem: () =>
                            _showRedeemDialog(context, loyalty, 250,
                                'Redeemed for ₹75 off', '₹75 off'),
                      ),
                      const SizedBox(height: 10),
                      _RedeemCard(
                        title: 'Free Flat Tyre Fix',
                        subtitle: 'One free tyre repair service',
                        pointsNeeded: 500,
                        currentPoints: loyalty.points,
                        onRedeem: () =>
                            _showRedeemDialog(context, loyalty, 500,
                                'Redeemed for Free Tyre Fix', 'Free Tyre Fix'),
                      ),

                      const SizedBox(height: 24),

                      // Transaction history
                      const _SectionTitle('Points History'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children:
                              loyalty.transactions.asMap().entries.map((e) {
                            final isLast =
                                e.key == loyalty.transactions.length - 1;
                            final tx = e.value;
                            return Column(
                              children: [
                                _TransactionTile(transaction: tx),
                                if (!isLast)
                                  const Divider(
                                      height: 1, indent: 16, endIndent: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRedeemDialog(
    BuildContext context,
    LoyaltyProvider loyalty,
    int points,
    String description,
    String reward,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.redeem, color: AppTheme.accent, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Redeem $points Points?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll receive: $reward\nThis will deduct $points points from your balance.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success =
                          await loyalty.redeemPoints(points, description);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? '🎉 $reward applied to your next booking!'
                                : 'Insufficient points'),
                            backgroundColor:
                                success ? AppTheme.success : AppTheme.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent),
                    child: const Text('Redeem'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _PointsHeroCard extends StatelessWidget {
  final LoyaltyProvider loyalty;

  const _PointsHeroCard({required this.loyalty});

  Color get _tierColor {
    switch (loyalty.tier) {
      case 'Platinum':
        return const Color(0xFF4A148C);
      case 'Gold':
        return const Color(0xFFF57F17);
      case 'Silver':
        return const Color(0xFF546E7A);
      default:
        return const Color(0xFF6D4C41);
    }
  }

  IconData get _tierIcon {
    switch (loyalty.tier) {
      case 'Platinum':
        return Icons.diamond;
      case 'Gold':
        return Icons.workspace_premium;
      case 'Silver':
        return Icons.military_tech;
      default:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = loyalty.nextTierPoints - loyalty.points;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          // Tier badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_tierIcon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                '${loyalty.tier} Member',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${loyalty.points}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Text(
            'Reward Points',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          // Progress to next tier
          if (loyalty.points < 3000) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loyalty.tier,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  _nextTierName(loyalty.tier),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: loyalty.tierProgress,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$remaining more points to reach ${_nextTierName(loyalty.tier)}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ] else
            const Text(
              '🏆 You\'ve reached the highest tier!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  String _nextTierName(String tier) {
    switch (tier) {
      case 'Bronze':
        return 'Silver';
      case 'Silver':
        return 'Gold';
      case 'Gold':
        return 'Platinum';
      default:
        return 'Platinum';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _EarnCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String points;
  final Color color;

  const _EarnCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              points,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pointsNeeded;
  final int currentPoints;
  final VoidCallback onRedeem;

  const _RedeemCard({
    required this.title,
    required this.subtitle,
    required this.pointsNeeded,
    required this.currentPoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final canRedeem = currentPoints >= pointsNeeded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
        border: canRedeem
            ? Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (canRedeem ? AppTheme.accent : AppTheme.textLight)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.redeem,
              color: canRedeem ? AppTheme.accent : AppTheme.textLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pointsNeeded points required',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: canRedeem ? AppTheme.accent : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: canRedeem ? onRedeem : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canRedeem ? AppTheme.accent : AppTheme.divider,
              foregroundColor: canRedeem ? Colors.white : AppTheme.textLight,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final dynamic transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.isEarned as bool;
    final points = transaction.points as int;
    final desc = transaction.description as String;
    final date = transaction.date as DateTime;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (isEarned ? AppTheme.success : AppTheme.error)
              .withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isEarned ? Icons.add : Icons.remove,
          color: isEarned ? AppTheme.success : AppTheme.error,
          size: 18,
        ),
      ),
      title: Text(
        desc,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: AppTheme.textLight,
        ),
      ),
      trailing: Text(
        '${isEarned ? '+' : ''}$points pts',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isEarned ? AppTheme.success : AppTheme.error,
        ),
      ),
    );
  }
}

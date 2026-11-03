import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/service_request_model.dart';
import '../request/request_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<RequestProvider>().loadHistory(auth.currentUser!.id);
      }
    });
  }

  List<ServiceRequestModel> _filtered(List<ServiceRequestModel> history) {
    if (_selectedFilter == 'All') return history;
    return history
        .where((r) => r.status == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: AppTheme.primary,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, _) {
          if (requestProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final allHistory = requestProvider.history;
          final filtered = _filtered(allHistory);

          return Column(
            children: [
              // Stats strip
              if (allHistory.isNotEmpty) _StatsStrip(history: allHistory),

              // Filter chips
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: _filters.map((f) {
                    final selected = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.divider,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppTheme.textMedium,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _selectedFilter)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final request = filtered[index];
                          return _HistoryCard(
                            request: request,
                            onTap: () {
                              Navigator.push(
                                context,
                                AppTheme.slideRoute(
                                    RequestDetailScreen(request: request)),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final List<ServiceRequestModel> history;

  const _StatsStrip({required this.history});

  @override
  Widget build(BuildContext context) {
    final completed = history.where((r) => r.status == 'completed').length;
    final totalSpent = history.fold<double>(
        0, (sum, r) => r.status == 'completed' ? sum + r.fare : sum);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(
              label: 'Total Services',
              value: '${history.length}',
              icon: Icons.history),
          Container(width: 1, height: 36, color: Colors.white30),
          _MiniStat(
              label: 'Completed',
              value: '$completed',
              icon: Icons.check_circle_outline),
          Container(width: 1, height: 36, color: Colors.white30),
          _MiniStat(
              label: 'Total Spent',
              value: '₹${totalSpent.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onTap;

  const _HistoryCard({required this.request, required this.onTap});

  Map<String, dynamic>? get _serviceInfo {
    for (final s in AppConstants.serviceTypes) {
      if (s['id'] == request.serviceType) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final service = _serviceInfo;
    final icon = service?['icon'] as IconData? ?? Icons.build;
    final color = service?['color'] as Color? ?? AppTheme.primary;
    final gradientColors =
        service?['gradientColors'] as List<Color>? ?? [AppTheme.primary, AppTheme.primaryLight];
    final title = service?['title'] as String? ?? request.serviceType;
    final statusColor =
        AppConstants.statusColors[request.status] ?? AppTheme.primary;
    final statusLabel =
        AppConstants.statusLabels[request.status] ?? request.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Service icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy • hh:mm a')
                              .format(request.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: AppTheme.textLight),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                request.address.split(',').first,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppTheme.textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom strip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (request.rating != null)
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < request.rating!.floor()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.rating}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'No rating yet',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        '₹${request.fare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textLight, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, size: 50, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            filter == 'All'
                ? 'No Service History Yet'
                : 'No $filter Services',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'All'
                ? 'Your past service requests\nwill appear here.'
                : 'No services with "$filter" status.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

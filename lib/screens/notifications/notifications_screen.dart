import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifications = [
    _NotifItem(
      title: 'Service Completed ✅',
      body: 'Your Flat Tyre service has been completed. Rate your experience!',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      icon: Icons.check_circle,
      color: AppTheme.success,
      isRead: false,
    ),
    _NotifItem(
      title: 'Mechanic En Route 🚗',
      body: 'Ramesh Kumar is on the way. ETA: 8 minutes.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.directions_bike,
      color: AppTheme.primary,
      isRead: false,
    ),
    _NotifItem(
      title: 'Special Offer 🎉',
      body: 'Get 20% off your next service. Use code SAVE20.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.local_offer,
      color: AppTheme.accent,
      isRead: true,
    ),
    _NotifItem(
      title: 'Payment Received',
      body: 'Payment of ₹349 received successfully for Battery Jump service.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.payment,
      color: AppTheme.success,
      isRead: true,
    ),
    _NotifItem(
      title: 'Safety Reminder 🔧',
      body: 'Check your vehicle\'s oil level and tyre pressure this week.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.tips_and_updates,
      color: AppTheme.warning,
      isRead: true,
    ),
    _NotifItem(
      title: 'Request Accepted',
      body: 'A mechanic has accepted your fuel delivery request.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.thumb_up_outlined,
      color: AppTheme.primary,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _notifications) {
                    n.isRead = true;
                  }
                });
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _NotificationTile(
                  notif: notif,
                  onTap: () {
                    setState(() => notif.isRead = true);
                  },
                  onDismiss: () {
                    setState(() => _notifications.removeAt(index));
                  },
                );
              },
            ),
    );
  }
}

class _NotifItem {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
  bool isRead;

  _NotifItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}

class _NotificationTile extends StatelessWidget {
  final _NotifItem notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notif,
    required this.onTap,
    required this.onDismiss,
  });

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.title + notif.time.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : notif.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isRead
                  ? AppTheme.divider
                  : notif.color.withOpacity(0.25),
            ),
            boxShadow: notif.isRead
                ? []
                : [
                    BoxShadow(
                      color: notif.color.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notif.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon, color: notif.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(notif.time),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!notif.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notif.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined,
                size: 44, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(
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

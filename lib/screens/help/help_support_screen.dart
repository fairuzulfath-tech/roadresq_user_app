import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'How can we help?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Search bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: const InputDecoration(
                          hintText: 'Search for help...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.primary, size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'FAQ'),
                Tab(text: 'Contact'),
                Tab(text: 'Tickets'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _FAQTab(searchQuery: _searchQuery),
            const _ContactTab(),
            const _TicketsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── FAQ Tab ───────────────────────────────────────────────────────────────

class _FAQTab extends StatelessWidget {
  final String searchQuery;

  const _FAQTab({required this.searchQuery});

  static const List<Map<String, dynamic>> _categories = [
    {
      'title': 'Service & Booking',
      'icon': Icons.build_circle_outlined,
      'color': AppTheme.primary,
      'faqs': [
        {
          'q': 'How do I request a service?',
          'a':
              'Tap any service card on the Home screen, fill in your location and vehicle details, then tap "Request Now". A nearby mechanic will be assigned within minutes.',
        },
        {
          'q': 'Can I cancel my request?',
          'a':
              'Yes, you can cancel from the Tracking screen before the mechanic arrives. Cancellations after mechanic dispatch may incur a small cancellation fee.',
        },
        {
          'q': 'How are mechanics verified?',
          'a':
              'All mechanics undergo background checks, skill certification, and are rated by users. We only onboard mechanics with a minimum 4.0 rating.',
        },
        {
          'q': 'What if no mechanic is available?',
          'a':
              'If no mechanic is available in your area, we\'ll notify you and you can try again or use the SOS feature for emergency assistance.',
        },
      ],
    },
    {
      'title': 'Payment & Billing',
      'icon': Icons.payment_outlined,
      'color': Color(0xFF2E7D32),
      'faqs': [
        {
          'q': 'What payment methods are accepted?',
          'a':
              'We accept UPI (GPay, PhonePe, Paytm), credit/debit cards (Visa, MasterCard, RuPay), and cash payments.',
        },
        {
          'q': 'How is the fare calculated?',
          'a':
              'Fare = Base service charge + Distance charge + Platform fee (₹20) + GST (18%). You\'ll see a full estimate before confirming.',
        },
        {
          'q': 'Can I get a refund?',
          'a':
              'Refunds are processed within 3–5 business days for digital payments. Contact support with your request ID for cancellation refunds.',
        },
        {
          'q': 'Is GST included in the displayed price?',
          'a':
              'The fare estimate shows the base amount. Final billing includes 18% GST, which is shown in your invoice.',
        },
      ],
    },
    {
      'title': 'Account & Profile',
      'icon': Icons.person_outline,
      'color': AppTheme.accent,
      'faqs': [
        {
          'q': 'How do I update my profile?',
          'a':
              'Go to Profile → tap the edit icon (top right). You can update your name, email, and profile photo.',
        },
        {
          'q': 'Can I add multiple vehicles?',
          'a':
              'Yes! Go to Profile → My Vehicles → "Add Another Vehicle". You can store details for all your cars/bikes.',
        },
        {
          'q': 'How do I change my phone number?',
          'a':
              'Phone number changes require OTP verification. Contact support and we\'ll guide you through the process securely.',
        },
      ],
    },
    {
      'title': 'SOS & Emergency',
      'icon': Icons.emergency_outlined,
      'color': AppTheme.error,
      'faqs': [
        {
          'q': 'How does the SOS feature work?',
          'a':
              'Press and hold the SOS button for 5 seconds. It will alert emergency services and your saved contacts with your live location.',
        },
        {
          'q': 'What numbers are on SOS speed dial?',
          'a':
              'Emergency (112), Police (100), Ambulance (108), and Fire Brigade (101) are pre-loaded for quick access.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _filtered() {
    if (searchQuery.isEmpty) return _categories;
    final q = searchQuery.toLowerCase();
    return _categories.map((cat) {
      final filteredFaqs = (cat['faqs'] as List)
          .where((faq) =>
              (faq['q'] as String).toLowerCase().contains(q) ||
              (faq['a'] as String).toLowerCase().contains(q))
          .toList();
      if (filteredFaqs.isEmpty && !cat['title'].toString().toLowerCase().contains(q)) {
        return null;
      }
      return {...cat, 'faqs': filteredFaqs.isEmpty ? cat['faqs'] : filteredFaqs};
    }).whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filtered();
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: AppTheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        return _FAQCategory(
          title: cat['title'] as String,
          icon: cat['icon'] as IconData,
          color: cat['color'] as Color,
          faqs: cat['faqs'] as List,
        );
      },
    );
  }
}

class _FAQCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List faqs;

  const _FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.faqs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 17),
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
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final isLast = entry.key == faqs.length - 1;
              final faq = entry.value as Map;
              return Column(
                children: [
                  _FAQItem(
                    question: faq['q'] as String,
                    answer: faq['a'] as String,
                    color: color,
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final Color color;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.color,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _expanded ? widget.color : AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _rotate,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: _expanded ? widget.color : AppTheme.textLight,
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: AppTheme.textMedium,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact Tab ────────────────────────────────────────────────────────────

class _ContactTab extends StatelessWidget {
  const _ContactTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact options
        const Text(
          'Get in Touch',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'We\'re here 24/7 to help you',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppTheme.textMedium,
          ),
        ),
        const SizedBox(height: 20),

        _ContactCard(
          icon: Icons.chat_bubble_outline,
          color: AppTheme.primary,
          title: 'Live Chat',
          subtitle: 'Chat with a support agent',
          badge: 'Online',
          badgeColor: AppTheme.success,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live chat coming soon')),
          ),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.call_outlined,
          color: const Color(0xFF2E7D32),
          title: 'Call Support',
          subtitle: '1800-123-7625 (Toll Free)',
          badge: '24/7',
          badgeColor: AppTheme.accent,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calling +91-1800-123-7625')),
          ),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.email_outlined,
          color: const Color(0xFF6A1B9A),
          title: 'Email Us',
          subtitle: 'support@roadresq.in',
          badge: '< 24hr',
          badgeColor: AppTheme.textLight,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening email client...')),
          ),
        ),
        const SizedBox(height: 12),
        _ContactCard(
          icon: Icons.forum_outlined,
          color: const Color(0xFFF57F17),
          title: 'WhatsApp',
          subtitle: '+91 9876 543 210',
          badge: null,
          badgeColor: null,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening WhatsApp...')),
          ),
        ),

        const SizedBox(height: 28),
        // Business hours
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: AppTheme.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Support Hours',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _HoursRow('Live Chat / Phone', '24 hours, 7 days'),
              const SizedBox(height: 6),
              _HoursRow('Email Support', 'Mon–Fri, 9am – 8pm'),
              const SizedBox(height: 6),
              _HoursRow('WhatsApp', 'Mon–Sat, 8am – 10pm'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: AppTheme.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String label;
  final String value;

  const _HoursRow(this.label, this.value);

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
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Tickets Tab ─────────────────────────────────────────────────────────────

class _TicketsTab extends StatefulWidget {
  const _TicketsTab();

  @override
  State<_TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<_TicketsTab> {
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Payment Issue';
  bool _isSubmitting = false;
  bool _submitted = false;

  final _categories = [
    'Payment Issue',
    'Service Quality',
    'Mechanic Behavior',
    'App Bug',
    'Refund Request',
    'Other',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ticket Submitted!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'ll respond within 24 hours.\nTicket ID: #TKT-2026-00847',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => setState(() => _submitted = false),
                child: const Text('Raise Another Ticket'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Raise a Support Ticket',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Describe your issue and we\'ll get back to you',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppTheme.textMedium,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              _FieldLabel('Subject'),
              const SizedBox(height: 8),
              TextField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  hintText: 'Brief title of your issue',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel('Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your issue in detail...',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              // Attachment placeholder
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Attach Screenshot (optional)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Submit Ticket',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
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

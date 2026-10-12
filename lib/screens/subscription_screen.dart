import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';
import '../models/user_session.dart';
import '../models/contact.dart';
import '../widgets/app_header.dart';
import '../widgets/header_menu.dart';
import '../services/payment_service.dart';
import 'phone_entry_screen.dart';
import '../utils/string_utils.dart';

class SubscriptionScreen extends StatefulWidget {
  final ApiClient api;
  final UserSession session;

  const SubscriptionScreen({
    super.key,
    required this.api,
    required this.session,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _payment = PaymentService();
  ProductDetails? _targetProduct;
  bool _productsLoaded = false;

  @override
  void initState() {
    super.initState();
    _payment.initialize();
    _loadStoreProduct();
  }

  Future<void> _loadStoreProduct() async {
    final available = await _payment.loadProducts(['create_profile_499']);
    if (available && _payment.products.isNotEmpty) {
      for (final p in _payment.products) {
        if (p.id == 'create_profile_499') {
          _targetProduct = p;
          break;
        }
      }
    }
    if (mounted) {
      setState(() => _productsLoaded = true);
    }
  }

  String get _displayPrice {
    if (_targetProduct != null && _targetProduct!.price.isNotEmpty) {
      return _targetProduct!.price;
    }
    return '₹500';
  }

  void _showFeatureDetails(String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4C5B8F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star, color: Color(0xFF4C5B8F), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF212529),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF495057),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C5B8F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Got it', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openProfileSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSelectionModal(
        api: widget.api,
        session: widget.session,
        displayPrice: _displayPrice,
        targetProduct: _targetProduct,
        paymentService: _payment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Premium Membership',
              showMenu: true,
              api: widget.api,
              session: widget.session,
              store: SessionStore(),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Pass Card (Outline in 0xFF4C5B8F with Shield Icon)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF4C5B8F), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C5B8F).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4C5B8F).withValues(alpha: 0.12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.verified_user,
                                color: Color(0xFF4C5B8F),
                                size: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'FoneBook Safety Pass',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Premium Membership',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4C5B8F),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Plan Benefits Section Heading
                    const Text(
                      'Plan Benefits',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a feature to learn more',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF6C757D),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Feature Comparison Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                            child: Row(
                              children: const [
                                Spacer(),
                                SizedBox(
                                  width: 75,
                                  child: Text(
                                    'Free',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6C757D),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    'Premium',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4C5B8F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF1F3F5)),

                          // Row 1: Keywords
                          _buildFeatureRow(
                            icon: Icons.label_outline,
                            title: 'Keywords',
                            freeValue: '5',
                            premiumValue: 'Unlimited',
                            onTap: () => _showFeatureDetails(
                              'Keywords',
                              'Basic free profiles are limited to 5 keywords. With Premium, you can add unlimited keywords to match every possible search term your customers type!',
                            ),
                          ),

                          const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF1F3F5)),

                          // Row 2: Verified Badge
                          _buildFeatureRow(
                            icon: Icons.verified_outlined,
                            title: 'Verified Badge',
                            freeValue: 'No',
                            premiumWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/verified.png', width: 16, height: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: Color(0xFF4C5B8F),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showFeatureDetails(
                              'Verified Badge',
                              'Display an official blue checkmark badge on your business profile cards and details, building instant trust and credibility with potential clients.',
                            ),
                          ),

                          const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF1F3F5)),

                          // Row 3: Priority Search Placement
                          _buildFeatureRow(
                            icon: Icons.trending_up,
                            title: 'Search Priority',
                            freeValue: 'Standard',
                            premiumValue: 'Priority',
                            onTap: () => _showFeatureDetails(
                              'Search Priority Placement',
                              'Premium profiles receive Tier 3 priority search placement, appearing higher in search results above all regular basic profiles.',
                            ),
                          ),

                          const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFF1F3F5)),

                          // Row 4: Directory Trust
                          _buildFeatureRow(
                            icon: Icons.visibility_outlined,
                            title: 'Directory Trust',
                            freeValue: 'Basic',
                            premiumValue: 'Trusted',
                            onTap: () => _showFeatureDetails(
                              'Directory Trust',
                              'Highlight your verified legitimacy across city, state, and category listings, giving callers confidence to reach out directly.',
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Unlock All Features Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _openProfileSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C5B8F),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0xFF4C5B8F).withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Unlock All Features',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String freeValue,
    String? premiumValue,
    Widget? premiumWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4C5B8F).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4C5B8F), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            SizedBox(
              width: 75,
              child: Text(
                freeValue,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C757D),
                ),
              ),
            ),
            SizedBox(
              width: 85,
              child: premiumWidget ??
                  Text(
                    premiumValue ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C5B8F),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Unverified Profile Selection Modal
// -------------------------------------------------------------
class _ProfileSelectionModal extends StatefulWidget {
  final ApiClient api;
  final UserSession session;
  final String displayPrice;
  final ProductDetails? targetProduct;
  final PaymentService paymentService;

  const _ProfileSelectionModal({
    required this.api,
    required this.session,
    required this.displayPrice,
    required this.targetProduct,
    required this.paymentService,
  });

  @override
  State<_ProfileSelectionModal> createState() => _ProfileSelectionModalState();
}

class _ProfileSelectionModalState extends State<_ProfileSelectionModal> {
  bool _isLoading = true;
  List<DirectoryContact> _allProfiles = [];
  List<DirectoryContact> _unverifiedProfiles = [];
  DirectoryContact? _selectedProfile;
  bool _isProcessingPayment = false;
  StreamSubscription<PurchaseDetails>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoading = true);
    try {
      final userEmail = widget.session.email ?? (await SessionStore().read()).email ?? '';
      if (userEmail.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final res = await widget.api.get('check_search_type1', {'email': userEmail});
      if (res is List) {
        final profiles = res
            .map((e) => DirectoryContact.fromJson(e))
            .where((p) =>
                p.name.isNotEmpty &&
                p.phone.isNotEmpty &&
                p.publish.toLowerCase() != 'no' &&
                p.publish.toLowerCase() != 'deleted' &&
                p.publish.toLowerCase() != '0')
            .toList();

        final unverified = profiles.where((p) => p.verified != 1).toList();

        if (mounted) {
          setState(() {
            _allProfiles = profiles;
            _unverifiedProfiles = unverified;
            if (unverified.isNotEmpty) {
              _selectedProfile = unverified.first;
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initiateUpgrade() async {
    if (_selectedProfile == null) return;
    final profile = _selectedProfile!;

    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    // 1. Ensure products loaded
    ProductDetails? product = widget.targetProduct;
    if (product == null) {
      final available = await widget.paymentService.loadProducts(['create_profile_499']);
      if (available && widget.paymentService.products.isNotEmpty) {
        product = widget.paymentService.products.firstWhere(
          (p) => p.id == 'create_profile_499',
          orElse: () => widget.paymentService.products.first,
        );
      }
    }

    if (product == null) {
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment store currently unavailable. Please check your network and App Store / Google Play account.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 2. Set up purchase stream listener
    _purchaseSub?.cancel();
    bool handled = false;

    _purchaseSub = widget.paymentService.purchaseStream.listen((purchase) async {
      if (purchase.productID != 'create_profile_499') return;
      if (handled) return;

      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        handled = true;
        _purchaseSub?.cancel();

        final txId = purchase.purchaseID ?? 'tx_${DateTime.now().millisecondsSinceEpoch}';

        // 3. Verify on backend and grant Premium entitlements
        try {
          final res = await widget.api.post('upgrade_subscription', {
            'id': profile.id ?? '',
            'transaction_id': txId,
            'payment_status': 'completed',
            'amount': widget.displayPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
            'owner_email': widget.session.email ?? '',
          });

          if (res is Map && res['status'] == 'success') {
            if (profile.id != null) DirectoryContact.bust(profile.id!);
            DirectoryContact.bust(profile.phone);

            if (mounted) {
              setState(() => _isProcessingPayment = false);
              Navigator.pop(context); // Close sheet

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: Row(
                    children: [
                      Image.asset('assets/images/verified.png', width: 26, height: 26),
                      const SizedBox(width: 10),
                      const Text(
                        'Upgrade Successful!',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  content: Text(
                    'Congratulations! "${profile.name.toTitleCase()}" is now upgraded to Premium. Your Verified badge, unlimited keywords, and priority search ranking are now active!',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.4),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C5B8F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Great!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
          } else {
            throw Exception(res['message'] ?? 'Backend verification error');
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isProcessingPayment = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        handled = true;
        _purchaseSub?.cancel();
        if (mounted) {
          setState(() => _isProcessingPayment = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${purchase.error?.message ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        handled = true;
        _purchaseSub?.cancel();
        if (mounted) {
          setState(() => _isProcessingPayment = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled.')),
          );
        }
      }
    });

    // 4. Trigger purchase flow
    try {
      await widget.paymentService.buyProduct(product, consumable: false);
    } catch (e) {
      handled = true;
      _purchaseSub?.cancel();
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start purchase: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upgrade Business Profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6C757D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (_isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF4C5B8F))),
                )
              else if (_allProfiles.isEmpty) ...[
                // Case: No profiles at all
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4C5B8F).withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.business_center_outlined, size: 48, color: Color(0xFF4C5B8F)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Business Profiles Found',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You haven\'t created any business profiles yet. Create a profile in Directory first to upgrade it to Premium.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF6C757D)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhoneEntryScreen(email: widget.session.email ?? ''),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add Business Profile', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C5B8F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ] else if (_unverifiedProfiles.isEmpty) ...[
                // Case: All profiles already verified
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4C5B8F).withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.verified, size: 48, color: Color(0xFF4C5B8F)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'All Profiles are Verified!',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'All of your business profiles already have Premium Membership and Verified Badges active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF6C757D)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4C5B8F)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Close', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color(0xFF4C5B8F))),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ] else ...[
                // Case: Unverified profiles available
                const Text(
                  'Choose which business profile you want to upgrade with Verified Badge, unlimited keywords, and priority ranking:',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF6C757D)),
                ),
                const SizedBox(height: 14),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _unverifiedProfiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final p = _unverifiedProfiles[idx];
                      final isSelected = _selectedProfile?.id == p.id;

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedProfile = p);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4C5B8F).withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4C5B8F) : const Color(0xFFE9ECEF),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<DirectoryContact>(
                                value: p,
                                groupValue: _selectedProfile,
                                activeColor: const Color(0xFF4C5B8F),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedProfile = val);
                                },
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4C5B8F),
                                ),
                                child: ClipOval(
                                  child: p.imageUrl.isNotEmpty
                                      ? FadeInImage.assetNetwork(
                                          placeholder: 'assets/images/user.png',
                                          image: p.imageUrl,
                                          fit: BoxFit.cover,
                                          imageErrorBuilder: (_, __, ___) => Image.asset('assets/images/user.png', fit: BoxFit.cover),
                                        )
                                      : Image.asset('assets/images/user.png', fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name.toTitleCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212529),
                                      ),
                                    ),
                                    if (p.service.isNotEmpty)
                                      Text(
                                        p.service.toTitleCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12.5,
                                          color: Color(0xFF6C757D),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Basic Plan',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF495057),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Annual Premium Plan',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF212529)),
                          ),
                          Text(
                            _selectedProfile != null ? 'For ${_selectedProfile!.name.toTitleCase()}' : 'Select a profile above',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF6C757D)),
                          ),
                        ],
                      ),
                      Text(
                        '${widget.displayPrice} / 1 Yr',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4C5B8F),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Upgrade Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessingPayment ? null : _initiateUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C5B8F),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isProcessingPayment
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Upgrade to Premium (${widget.displayPrice})',
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

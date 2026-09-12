import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insaafconnect/core/services/lawyers_services.dart';
import 'package:insaafconnect/core/utils/theme.dart';

class SubscriptionRecordsScreen extends StatefulWidget {
  const SubscriptionRecordsScreen({super.key});

  @override
  State<SubscriptionRecordsScreen> createState() =>
      _SubscriptionRecordsScreenState();
}

class _SubscriptionRecordsScreenState extends State<SubscriptionRecordsScreen> {
  final LawyerService _lawyerService = LawyerService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _records = [];
  int? _approvingId;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _lawyerService.fetchSubscriptionRecords();
      if (mounted) {
        setState(() {
          _records = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double get _totalRevenue {
    double total = 0;
    for (final r in _records) {
      if (r['status'] == 'pending') continue; // only count approved/active
      final amt = double.tryParse(r['amount']?.toString() ?? '') ?? 0;
      total += amt;
    }
    return total;
  }

  int get _pendingCount {
    return _records.where((r) => r['status'] == 'pending').length;
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final d = DateTime.tryParse(dateStr.toString());
      if (d == null) return dateStr.toString().split('T')[0];
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr.toString().split('T')[0];
    }
  }

  void _showReceiptDialog(String base64Str) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Payment Screenshot",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.Brown,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.Brown),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(
                      base64Str.contains(',')
                          ? base64Str.split(',')[1]
                          : base64Str,
                    ),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("Failed to display receipt image"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveSubscription(Map<String, dynamic> record) async {
    final lawyerId = record['lawyer_id'];
    if (lawyerId == null) return;

    setState(() => _approvingId = record['id']);
    try {
      await _lawyerService.renewLawyer(lawyerId);
      Get.snackbar(
        "Subscription Approved",
        "Lawyer's subscription has been renewed for 30 days.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      await _loadRecords();
    } catch (e) {
      Get.snackbar(
        "Approval Failed",
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _approvingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.beige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.Brown),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Subscription Records',
          style: TextStyle(
            color: AppColors.Brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.Brown),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load records:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Brown,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.Brown,
      onRefresh: _loadRecords,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary Cards ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.Brown.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Collected',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.labelSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PKR ${_totalRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.Brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.Brown.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Review',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.labelSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '$_pendingCount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _pendingCount > 0
                                  ? Colors.orange.shade800
                                  : AppColors.Brown,
                            ),
                          ),
                          if (_pendingCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Action required',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Payment Submissions',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: 12),

          if (_records.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.iconMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No subscription records found.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.labelSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Records will appear here when lawyers submit renewal proof or subscriptions are renewed.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._records.map((record) {
              final lawyerName = record['lawyer_name'] ?? 'Unknown Lawyer';
              final lawyerEmail = record['lawyer_email'] ?? '-';
              final lawyerPhone = record['lawyer_phone'];
              final amount = record['amount'] ?? '0';
              final method = record['payment_method'] ?? 'JazzCash';
              final paidDate = _formatDate(record['paid_date']);
              final expiryDate = _formatDate(record['expiry_date']);
              final isPending = record['status'] == 'pending';
              final tid = record['transaction_id'];
              final receipt = record['payment_receipt'];
              final isThisApproving = _approvingId == record['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isPending
                      ? Border.all(color: Colors.orange.shade300, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.Brown.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Name + Status Badge + Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.Brown.withOpacity(0.12),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.Brown,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lawyerName,
                                style: AppTextStyles.heading4.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                lawyerEmail,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.labelSecondary,
                                ),
                              ),
                              if (lawyerPhone != null &&
                                  lawyerPhone.toString().isNotEmpty)
                                Text(
                                  lawyerPhone.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.labelSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.orange.shade100
                                    : AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPending ? 'Pending Review' : 'Active / Approved',
                                style: TextStyle(
                                  color: isPending
                                      ? Colors.orange.shade900
                                      : AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PKR $amount',
                              style: const TextStyle(
                                color: AppColors.Brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Middle details: Date, Expiry, Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem('Submitted On', paidDate),
                        _infoItem(
                          isPending ? 'Renewal Period' : 'Valid Until',
                          isPending ? '+30 Days' : expiryDate,
                        ),
                        _infoItem('Method', method.toString()),
                      ],
                    ),

                    // TID & Receipt Proof details
                    if (tid != null && tid.toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.beige.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt,
                                size: 16, color: AppColors.Brown),
                            const SizedBox(width: 6),
                            Text(
                              "TID: $tid",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.Brown,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: tid.toString()));
                                Get.snackbar("Copied", "TID copied to clipboard",
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 1));
                              },
                              child: const Icon(Icons.copy,
                                  size: 15, color: AppColors.Brown),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (receipt != null && receipt.toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showReceiptDialog(receipt.toString()),
                        icon: const Icon(Icons.image_outlined, size: 16),
                        label: const Text("View Receipt Screenshot"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.Brown,
                          side: const BorderSide(color: AppColors.Brown),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],

                    // Action Button: Approve & Renew if pending
                    if (isPending) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isThisApproving
                              ? null
                              : () => _approveSubscription(record),
                          icon: isThisApproving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline,
                                  size: 18, color: Colors.white),
                          label: Text(
                            isThisApproving
                                ? "Approving & Renewing..."
                                : "Approve & Renew (30 Days)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.labelSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.Brown,
          ),
        ),
      ],
    );
  }
}

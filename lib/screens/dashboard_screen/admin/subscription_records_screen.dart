import 'package:flutter/material.dart';
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
      final amt = double.tryParse(r['amount']?.toString() ?? '') ?? 0;
      total += amt;
    }
    return total;
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
                        style: TextStyle(
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
                        'Total Renewals',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.labelSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_records.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.Brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Payment History',
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
                      'Records will appear here when lawyer subscriptions are renewed.',
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
              final amount = record['amount'] ?? '0';
              final method = record['payment_method'] ?? 'JazzCash';
              final paidDate = _formatDate(record['paid_date']);
              final expiryDate = _formatDate(record['expiry_date']);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                    // Top: Name + Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppColors.Brown.withOpacity(0.12),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.Brown,
                                  size: 20,
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PKR $amount',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Details: Paid Date, Expiry Date, Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem('Paid On', paidDate),
                        _infoItem('Valid Until', expiryDate),
                        _infoItem('Method', method.toString()),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insaafconnect/screens/dashboard_screen/admin_profile.dart';
import 'package:insaafconnect/screens/dashboard_screen/manage_cases.dart';
import 'package:insaafconnect/screens/dashboard_screen/managelawyers.dart';

// ── Transaction Data ──────────────────────────────────────────
class _Txn {
  final String id, client, service, method, amount, status, date;
  const _Txn(this.id, this.client, this.service, this.method, this.amount,
      this.status, this.date);
}

const _txns = [
  _Txn('TXN 2026-001', 'Ali Raza', 'Property Dispute Consultation', 'Manual',
      'PKR 5,000', 'Approved', '05/04'),
  _Txn('TXN 2026-002', 'Fatima Khan', 'Contract Review', 'Card', 'PKR 3,500',
      'Verified', '05/04'),
  _Txn('TXN 2026-003', 'Bilal Ahmed', 'Business Registration', 'Manual',
      'PKR 4,500', 'Approved', '05/04'),
  _Txn('TXN 2026-004', 'Sara Ali', 'Family Law Matter', 'Card', 'PKR 6,000',
      'Verified', '05/04'),
  _Txn('TXN 2026-005', 'Hassan Ahmad', 'Employment Dispute', 'Card',
      'PKR 7,500', 'Verified', '05/04'),
  _Txn('TXN 2026-006', 'Ayasha Malik', 'Legal Consultation', 'Manual',
      'PKR 5,000', 'Approved', '05/04'),
  _Txn('TXN 2026-007', 'Ahmad Raza', 'Property Documentation', 'Card',
      'PKR 4,500', 'Verified', '05/04'),
  _Txn('TXN 2026-008', 'Zainab Hussain', 'Civil Litigation', 'Manual',
      'PKR 8,000', 'Approved', '05/04'),
];

// ════════════════════════════════════════════════════════════════
// AdminDashboardScreen
// ════════════════════════════════════════════════════════════════
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final box = GetStorage();
  int currentIndex = 0;

  // Filter state for Payment History
  String _month = 'All Months';
  String _type = 'All Types';

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homePage(),
      const Managelawyers(),
      const ManageCases(),
      const AdminProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown,
        backgroundColor: const Color(0xFFF5EFE6),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user), label: "Manage lawyers"),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: "Manage Cases"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HOME PAGE
  // ══════════════════════════════════════════════════════════════
  Widget _homePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFE6),
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Insaaf Connect",
              style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back, Admin",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Manage your platform easily",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Platform stat cards ────────────────────────────
            SizedBox(
              height: 100,
              child: Row(children: [
                Expanded(child: _statCard("Cases", "120", Icons.folder)),
                const SizedBox(width: 12),
                Expanded(child: _statCard("Clients", "80", Icons.people)),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(children: [
                Expanded(child: _statCard("Lawyers", "45", Icons.gavel)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _statCard("Pending lawyers", "11", Icons.pending)),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Earnings cards ─────────────────────────────────
            Row(children: [
              Expanded(
                  child: _earningsCard('PKR 43,000', 'Total Platform Earnings',
                      Icons.attach_money, const Color(0xFF3A2A1E))),
              const SizedBox(width: 14),
              Expanded(
                  child: _earningsCard('PKR 8,500', 'May 2026 Earnings',
                      Icons.calendar_today_outlined, const Color(0xFF6B7D6B))),
            ]),
            const SizedBox(height: 14),

            // ── Payment count cards ────────────────────────────
            Row(children: [
              Expanded(
                  child: _countCard(
                      Icons.account_balance_wallet_outlined,
                      'Manual Payments',
                      4)),
              const SizedBox(width: 14),
              Expanded(
                  child: _countCard(
                      Icons.credit_card_outlined, 'Card Payments', 4)),
            ]),
            const SizedBox(height: 18),

            // ── Payment History table ──────────────────────────
            _buildTable(),
          ],
        ),
      ),
    );
  }

  // ── Stat card (Cases / Clients / Lawyers) ──────────────────
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.brown),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Earnings card ───────────────────────────────────────────
  Widget _earningsCard(String val, String lbl, IconData ic, Color bg) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(ic, size: 16, color: Colors.white),
            ),
            Icon(Icons.north_east,
                size: 14, color: Colors.white.withOpacity(0.5)),
          ]),
          const SizedBox(height: 14),
          Text(val,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text(lbl,
              style:
                  TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
        ]),
      );

  // ── Payment count card ──────────────────────────────────────
  Widget _countCard(IconData ic, String lbl, int n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: const Color(0xFFF5EFE8),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(ic, size: 18, color: const Color(0xFF8B5E3C)),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$n',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C1F14),
                    letterSpacing: -0.5)),
            Text(lbl,
                style: const TextStyle(
                    fontSize: 11.5, color: Color(0xFF8A7060))),
          ]),
        ]),
      );

  // ── Payment History table ───────────────────────────────────
  Widget _buildTable() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(children: [
              const Text('Payment History',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C1F14))),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4226),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.file_download_outlined, size: 15),
                label: const Text('Export',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          // Filter dropdowns
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Row(children: [
              Expanded(
                  child: _drop(
                      _month,
                      ['All Months', 'May 2026', 'April 2026', 'March 2026'],
                      (v) => setState(() => _month = v))),
              const SizedBox(width: 10),
              Expanded(
                  child: _drop(
                      _type,
                      ['All Types', 'Manual', 'Card'],
                      (v) => setState(() => _type = v))),
            ]),
          ),

          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF0E8DF)),
              dividerThickness: 1,
              headingTextStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A7060)),
              dataTextStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF2C1F14)),
              columnSpacing: 16,
              horizontalMargin: 18,
              columns: const [
                DataColumn(label: Text('Transaction ID')),
                DataColumn(label: Text('Client')),
                DataColumn(label: Text('Case/Service')),
                DataColumn(label: Text('Method')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
              ],
              rows: _filteredTxns().asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                return DataRow(
                  color: WidgetStateProperty.all(
                      i.isOdd ? const Color(0xFFFAF4EE) : Colors.white),
                  cells: [
                    DataCell(Text(p.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5E3C),
                            fontSize: 11.5))),
                    DataCell(Text(p.client)),
                    DataCell(SizedBox(
                        width: 145,
                        child: Text(p.service,
                            overflow: TextOverflow.ellipsis))),
                    DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                          p.method == 'Card'
                              ? Icons.credit_card
                              : Icons.account_balance_wallet_outlined,
                          size: 12,
                          color: const Color(0xFF8A7060)),
                      const SizedBox(width: 4),
                      Text(p.method),
                    ])),
                    DataCell(Text(p.amount,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(_chip(p.status)),
                    DataCell(Text(p.date,
                        style:
                            const TextStyle(color: Color(0xFF8A7060)))),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ]),
      );

  List<_Txn> _filteredTxns() => _txns
      .where((t) => (_type == 'All Types' || t.method == _type))
      .toList();

  Widget _drop(String val, List<String> items, ValueChanged<String> cb) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8DDD4)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF5EFE8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 16, color: Color(0xFF8A7060)),
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF2C1F14)),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              if (v != null) cb(v);
            },
          ),
        ),
      );

  Widget _chip(String s) {
    final ok = s == 'Approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: ok ? const Color(0xFFE8F5E8) : const Color(0xFFE8F0F5),
          borderRadius: BorderRadius.circular(20)),
      child: Text(s,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ok ? const Color(0xFF5A8A5A) : const Color(0xFF4A7A9B))),
    );
  }
}
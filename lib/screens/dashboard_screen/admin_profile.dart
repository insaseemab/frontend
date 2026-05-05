// ============================================================
// admin_profile_page.dart
// Drop into your lib/ folder.
// In your bottom nav "Profile" tab, use: AdminProfilePage()
// ============================================================

import 'package:flutter/material.dart';

// ── Colors ────────────────────────────────────────────────────
class _C {
  static const brown   = Color(0xFF6B4226);
  static const brownDk = Color(0xFF3A2A1E);
  static const brownMd = Color(0xFF8B5E3C);
  static const sage    = Color(0xFF6B7D6B);
  static const cream   = Color(0xFFF5EFE8);
  static const card    = Color(0xFFFFFFFF);
  static const txt1    = Color(0xFF2C1F14);
  static const txt2    = Color(0xFF8A7060);
  static const div     = Color(0xFFE8DDD4);
  static const tblHead = Color(0xFFF0E8DF);
  static const tblAlt  = Color(0xFFFAF4EE);
  static const green   = Color(0xFF5A8A5A);
  static const greenBg = Color(0xFFE8F5E8);
  static const blue    = Color(0xFF4A7A9B);
  static const blueBg  = Color(0xFFE8F0F5);
}

// ── Data ─────────────────────────────────────────────────────
class _Txn {
  final String id, client, service, method, amount, status, date;
  const _Txn(this.id,this.client,this.service,this.method,this.amount,this.status,this.date);
}

const _txns = [
  _Txn('TXN 2026-001','Ali Raza',      'Property Dispute Consultation','Manual','PKR 5,000','Approved','05/04'),
  _Txn('TXN 2026-002','Fatima Khan',   'Contract Review',              'Card',  'PKR 3,500','Verified','05/04'),
  _Txn('TXN 2026-003','Bilal Ahmed',   'Business Registration',        'Manual','PKR 4,500','Approved','05/04'),
  _Txn('TXN 2026-004','Sara Ali',      'Family Law Matter',            'Card',  'PKR 6,000','Verified','05/04'),
  _Txn('TXN 2026-005','Hassan Ahmad',  'Employment Dispute',           'Card',  'PKR 7,500','Verified','05/04'),
  _Txn('TXN 2026-006','Ayasha Malik',  'Legal Consultation',           'Manual','PKR 5,000','Approved','05/04'),
  _Txn('TXN 2026-007','Ahmad Raza',    'Property Documentation',       'Card',  'PKR 4,500','Verified','05/04'),
  _Txn('TXN 2026-008','Zainab Hussain','Civil Litigation',             'Manual','PKR 8,000','Approved','05/04'),
];

// ════════════════════════════════════════════════════════════════
// AdminProfilePage  ← plug into your bottom nav Profile tab
// ════════════════════════════════════════════════════════════════
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});
  @override State<AdminProfilePage> createState() => _State();
}

class _State extends State<AdminProfilePage> {
  String _month = 'All Months';
  String _type  = 'All Types';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 860;
    return Scaffold(
      backgroundColor: _C.cream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Admin Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _C.txt1, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          const Text('Manage your profile and view payment history',
            style: TextStyle(fontSize: 13, color: _C.txt2)),
          const SizedBox(height: 24),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 250, child: _buildProfileCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildRightCol()),
            ])
          else
            Column(children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildRightCol(),
            ]),
        ]),
      ),
    );
  }

  // ── Profile card ────────────────────────────────────────────
  Widget _buildProfileCard() => _Tile(child: Column(children: [
    const SizedBox(height: 6),
    CircleAvatar(radius: 38, backgroundColor: _C.brownMd,
      child: const Icon(Icons.person, size: 40, color: Colors.white)),
    const SizedBox(height: 14),
    const Text('Admin User',
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _C.txt1)),
    const SizedBox(height: 4),
    const Text('System Administrator',
      style: TextStyle(fontSize: 12, color: _C.txt2)),
    const SizedBox(height: 20),
    const Divider(color: _C.div, height: 1),
    const SizedBox(height: 16),
    _row(Icons.email_outlined,       'admin@insaafconnect.com'),
    const SizedBox(height: 12),
    _row(Icons.phone_outlined,       '+92 300 1234567'),
    const SizedBox(height: 12),
    _row(Icons.location_on_outlined, 'Islamabad, Pakistan'),
    const SizedBox(height: 22),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.brown, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0),
        child: const Text('Edit Profile',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    ),
  ]));

  Widget _row(IconData ic, String t) => Row(children: [
    Icon(ic, size: 15, color: _C.brownMd),
    const SizedBox(width: 8),
    Expanded(child: Text(t,
      style: const TextStyle(fontSize: 12.5, color: _C.txt2),
      overflow: TextOverflow.ellipsis)),
  ]);

  // ── Right column ────────────────────────────────────────────
  Widget _buildRightCol() => Column(children: [
    Row(children: [
      Expanded(child: _earningsCard('PKR 43,000','Total Platform Earnings', Icons.attach_money, _C.brownDk)),
      const SizedBox(width: 14),
      Expanded(child: _earningsCard('PKR 8,500','May 2026 Earnings', Icons.calendar_today_outlined, _C.sage)),
    ]),
    const SizedBox(height: 14),
    Row(children: [
      Expanded(child: _countCard(Icons.account_balance_wallet_outlined,'Manual Payments',4)),
      const SizedBox(width: 14),
      Expanded(child: _countCard(Icons.credit_card_outlined,'Card Payments',4)),
    ]),
    const SizedBox(height: 18),
    _buildTable(),
  ]);

  Widget _earningsCard(String val, String lbl, IconData ic, Color bg) =>
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8, offset: const Offset(0,3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
            child: Icon(ic, size: 16, color: Colors.white)),
          Icon(Icons.north_east, size: 14, color: Colors.white.withOpacity(0.5)),
        ]),
        const SizedBox(height: 14),
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 3),
        Text(lbl, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
      ]),
    );

  Widget _countCard(IconData ic, String lbl, int n) => _Tile(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: _C.cream, borderRadius: BorderRadius.circular(10)),
        child: Icon(ic, size: 18, color: _C.brownMd)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$n', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
            color: _C.txt1, letterSpacing: -0.5)),
        Text(lbl, style: const TextStyle(fontSize: 11.5, color: _C.txt2)),
      ]),
    ]),
  );

  // ── Payment history ─────────────────────────────────────────
  Widget _buildTable() => _Tile(
    padding: EdgeInsets.zero,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18,18,18,12),
        child: Row(children: [
          const Text('Payment History',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.txt1)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: _C.brown, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            icon: const Icon(Icons.file_download_outlined, size: 15),
            label: const Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18,0,18,12),
        child: Row(children: [
          Expanded(child: _drop(_month, ['All Months','May 2026','April 2026','March 2026'],
            (v) => setState(() => _month = v))),
          const SizedBox(width: 10),
          Expanded(child: _drop(_type, ['All Types','Manual','Card'],
            (v) => setState(() => _type = v))),
        ]),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(_C.tblHead),
          dividerThickness: 1,
          headingTextStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _C.txt2),
          dataTextStyle: const TextStyle(fontSize: 12, color: _C.txt1),
          columnSpacing: 16, horizontalMargin: 18,
          columns: const [
            DataColumn(label: Text('Transaction ID')),
            DataColumn(label: Text('Client')),
            DataColumn(label: Text('Case/Service')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
          ],
          rows: _filtered().asMap().entries.map((e) {
            final i = e.key; final p = e.value;
            return DataRow(
              color: WidgetStateProperty.all(i.isOdd ? _C.tblAlt : _C.card),
              cells: [
                DataCell(Text(p.id, style: const TextStyle(fontWeight: FontWeight.w600, color: _C.brownMd, fontSize: 11.5))),
                DataCell(Text(p.client)),
                DataCell(SizedBox(width: 145, child: Text(p.service, overflow: TextOverflow.ellipsis))),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(p.method == 'Card' ? Icons.credit_card : Icons.account_balance_wallet_outlined,
                    size: 12, color: _C.txt2),
                  const SizedBox(width: 4),
                  Text(p.method),
                ])),
                DataCell(Text(p.amount, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(_chip(p.status)),
                DataCell(Text(p.date, style: const TextStyle(color: _C.txt2))),
              ],
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 10),
    ]),
  );

  List<_Txn> _filtered() => _txns.where((t) =>
    (_type == 'All Types' || t.method == _type)).toList();

  Widget _drop(String val, List<String> items, ValueChanged<String> cb) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: _C.div), borderRadius: BorderRadius.circular(8), color: _C.cream),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: _C.txt2),
          style: const TextStyle(fontSize: 12.5, color: _C.txt1),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) { if (v != null) cb(v); },
        ),
      ),
    );

  Widget _chip(String s) {
    final ok = s == 'Approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: ok ? _C.greenBg : _C.blueBg, borderRadius: BorderRadius.circular(20)),
      child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: ok ? _C.green : _C.blue)),
    );
  }
}

// ── Card shell ────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Tile({required this.child, this.padding = const EdgeInsets.all(22)});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: _C.card, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0,4))]),
    child: child,
  );
}
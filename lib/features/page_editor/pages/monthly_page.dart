import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/photo_slot.dart';

const _kMonthNames = [
  '1. Ay', '2. Ay', '3. Ay', '4. Ay', '5. Ay', '6. Ay',
  '7. Ay', '8. Ay', '9. Ay', '10. Ay', '11. Ay', '12. Ay',
];

class MonthlyPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MonthlyPage({super.key, required this.t, required this.entry, required this.onChanged});

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  late List<String?> _months;

  @override
  void initState() {
    super.initState();
    final raw = (widget.entry['months'] as List?) ?? [];
    _months = List.generate(12, (i) => i < raw.length ? raw[i] as String? : null);
  }

  void _setOne(int i, String? v) {
    setState(() => _months[i] = v);
    widget.onChanged({'months': _months});
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: 12,
      itemBuilder: (_, i) => Column(
        children: [
          Expanded(
            child: PhotoSlot(
              t: t,
              value: _months[i],
              onSet: (v) => _setOne(i, v),
              label: _kMonthNames[i],
              tape: false,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _kMonthNames[i],
            style: GoogleFonts.cormorantGaramond(fontSize: 14, color: t.soft),
          ),
        ],
      ),
    );
  }
}

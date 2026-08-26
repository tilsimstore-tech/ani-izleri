import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

const kMoods = ['🥰', '😭', '🤍', '😮', '🤩', '😌', '🙏'];

class MoodPicker extends StatelessWidget {
  final AppTheme t;
  final String? value;
  final ValueChanged<String> onPick;

  const MoodPicker({super.key, required this.t, required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O ANKİ HİS',
          style: TextStyle(fontSize: 12.5, letterSpacing: 0.8, color: t.soft),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kMoods.map((m) {
            final sel = value == m;
            return GestureDetector(
              onTap: () => onPick(sel ? '' : m),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: sel ? t.accent : t.panel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? t.accent : t.line),
                ),
                child: Center(child: Text(m, style: const TextStyle(fontSize: 22))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

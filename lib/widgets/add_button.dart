import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AddButton extends StatelessWidget {
  final AppTheme t;
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const AddButton({
    super.key,
    required this.t,
    required this.onTap,
    required this.label,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.goldDeep, width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: t.goldDeep, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: t.goldDeep,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

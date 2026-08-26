import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final AppTheme t;
  final String text;

  const EmptyState({super.key, required this.t, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.cormorantGaramond(
            color: t.soft,
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

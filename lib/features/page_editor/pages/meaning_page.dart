import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class MeaningPage extends StatefulWidget {
  final AppTheme t;
  final String babyName;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MeaningPage({
    super.key,
    required this.t,
    required this.babyName,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<MeaningPage> createState() => _MeaningPageState();
}

class _MeaningPageState extends State<MeaningPage> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.entry['text']?.toString() ?? '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'İsminin anlamı',
                  style: GoogleFonts.pinyonScript(
                    fontSize: 22,
                    color: t.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.babyName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: t.ink,
                    height: 1.1,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  width: 50,
                  height: 2,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: t.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _c,
            onChanged: (v) => widget.onChanged({'text': v}),
            maxLines: 8,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 19,
              color: t.ink,
              height: 1.7,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: t.panel,
              hintText: 'Adının anlamını buraya yaz...',
              hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: t.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: t.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: t.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
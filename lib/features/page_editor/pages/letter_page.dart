import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';

class LetterPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const LetterPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.line),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 22)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sevgili bebeğim,',
            style: GoogleFonts.cormorantGaramond(
              fontStyle: FontStyle.italic,
              fontSize: 18,
              color: t.soft,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _c,
            onChanged: (v) => widget.onChanged({'text': v}),
            maxLines: 11,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 17,
              color: t.ink,
              height: 1.8,
            ),
            decoration: InputDecoration(
              hintText: widget.page.who != null
                  ? '${widget.page.who} senin için bir mektup yazsın...'
                  : 'Mektubunu buraya yaz...',
              hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${widget.page.who ?? ''}',
              style: GoogleFonts.cormorantGaramond(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: t.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

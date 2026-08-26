import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/empty_state.dart';

class LettersPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const LettersPage({super.key, required this.t, required this.entry, required this.onChanged});

  @override
  State<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends State<LettersPage> {
  late List<Map<String, dynamic>> _letters;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['letters'] as List?) ?? [];
    _letters = saved.map((l) => Map<String, dynamic>.from(l as Map)).toList();
  }

  void _emit() => widget.onChanged({'letters': _letters});

  void _update(int i, Map<String, dynamic> patch) {
    _letters[i] = {..._letters[i], ...patch};
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      children: [
        if (_letters.isEmpty) EmptyState(t: t, text: 'Sevdiklerin bebeğe birer mektup yazsın'),
        ...List.generate(_letters.length, (i) => Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          decoration: BoxDecoration(
            color: t.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.line),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 22)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sevgili bebeğim,',
                    style: GoogleFonts.cormorantGaramond(
                      fontStyle: FontStyle.italic, fontSize: 17, color: t.soft,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _letters.removeAt(i));
                      _emit();
                    },
                    child: Icon(Icons.delete_outline, color: t.soft, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: ValueKey('text_$i'),
                initialValue: _letters[i]['text']?.toString() ?? '',
                onChanged: (v) => _update(i, {'text': v}),
                maxLines: 6,
                style: GoogleFonts.cormorantGaramond(fontSize: 16.5, color: t.ink, height: 1.8),
                decoration: InputDecoration(
                  hintText: 'Mektubunu buraya yaz...',
                  hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('— ', style: GoogleFonts.cormorantGaramond(
                    fontStyle: FontStyle.italic, fontSize: 16, color: t.gold,
                  )),
                  SizedBox(
                    width: 170,
                    child: TextFormField(
                      key: ValueKey('who_$i'),
                      initialValue: _letters[i]['who']?.toString() ?? '',
                      onChanged: (v) => _update(i, {'who': v}),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cormorantGaramond(
                        fontStyle: FontStyle.italic, fontSize: 16, color: t.gold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'kimden (ör. Babaannen)',
                        hintStyle: TextStyle(color: t.gold.withOpacity(0.5)),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: t.line)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: t.line)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
        const SizedBox(height: 16),
        AddButton(t: t, onTap: () => setState(() => _letters.add({'who': '', 'text': ''})),
          label: 'Mektup Ekle', icon: Icons.mail_outline),
      ],
    );
  }
}

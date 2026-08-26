import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/round_photo.dart';

class GuestbookPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const GuestbookPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<GuestbookPage> createState() => _GuestbookPageState();
}

class _GuestbookPageState extends State<GuestbookPage> {
  late List<Map<String, dynamic>> _notes;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['notes'] as List?) ?? [];
    _notes = saved.map((n) => Map<String, dynamic>.from(n as Map)).toList();
  }

  void _emit() => widget.onChanged({'notes': _notes});

  void _update(int i, Map<String, dynamic> patch) {
    _notes[i] = {..._notes[i], ...patch};
    _emit();
  }

  InputDecoration _dec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.bg,
        hintText: hint,
        hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.page.note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(widget.page.note!, style: TextStyle(fontSize: 13, color: t.soft)),
          ),
        if (_notes.isEmpty) EmptyState(t: t, text: 'Sevdiklerin sana not bıraksın'),
        ...List.generate(_notes.length, (i) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.line),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  RoundPhoto(
                    t: t,
                    value: _notes[i]['photo'] as String?,
                    onSet: (p) {
                      _update(i, {'photo': p});
                      setState(() {});
                    },
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('who_$i'),
                      initialValue: _notes[i]['who']?.toString() ?? '',
                      onChanged: (v) => _update(i, {'who': v}),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.ink),
                      decoration: _dec(t, 'Kim yazıyor?'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _notes.removeAt(i));
                      _emit();
                    },
                    child: Icon(Icons.delete_outline, color: t.soft, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: ValueKey('text_$i'),
                initialValue: _notes[i]['text']?.toString() ?? '',
                onChanged: (v) => _update(i, {'text': v}),
                maxLines: 3,
                style: GoogleFonts.cormorantGaramond(fontSize: 16, color: t.ink, height: 1.6),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: t.bg,
                  hintText: 'Bebeğe bir not bırak...',
                  hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 14),
        AddButton(
          t: t,
          onTap: () => setState(() => _notes.add({'who': '', 'text': '', 'photo': null})),
          label: 'Not Ekle',
        ),
      ],
    );
  }
}

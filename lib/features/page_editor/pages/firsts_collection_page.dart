import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/photo_slot.dart';

class FirstsCollectionPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FirstsCollectionPage({
    super.key,
    required this.t,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<FirstsCollectionPage> createState() => _FirstsCollectionPageState();
}

class _FirstsCollectionPageState extends State<FirstsCollectionPage> {
  late List<Map<String, dynamic>> _items;
  int? _open;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['items'] as List?) ?? [];
    _items = saved.map((i) => Map<String, dynamic>.from(i as Map)).toList();
  }

  void _emit() => widget.onChanged({'items': _items});

  void _update(int i, Map<String, dynamic> patch) {
    setState(() => _items[i] = {..._items[i], ...patch});
    _emit();
  }

  InputDecoration _inputDec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.panel,
        hintText: hint,
        hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: t.gold)),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    if (_open != null && _open! < _items.length) {
      final it = _items[_open!];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chevron_left, size: 15, color: t.ink),
                const SizedBox(width: 4),
                Text('Listeye dön', style: TextStyle(color: t.ink, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Text('İLK NE?', style: TextStyle(fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
          const SizedBox(height: 7),
          TextFormField(
            key: ValueKey('title_${_open}'),
            initialValue: it['title']?.toString() ?? '',
            onChanged: (v) => _update(_open!, {'title': v}),
            style: GoogleFonts.cormorantGaramond(fontSize: 19, fontWeight: FontWeight.w600, color: t.ink),
            decoration: _inputDec(t, 'ör. İlk Banyon, İlk Tatilin...'),
          ),
          const SizedBox(height: 14),
          Text('TARİH', style: TextStyle(fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
          const SizedBox(height: 7),
          TextFormField(
            key: ValueKey('date_${_open}'),
            initialValue: it['date']?.toString() ?? '',
            onChanged: (v) => _update(_open!, {'date': v}),
            keyboardType: TextInputType.datetime,
            style: TextStyle(fontSize: 15, color: t.ink),
            decoration: _inputDec(t, 'GG.AA.YYYY'),
          ),
          const SizedBox(height: 14),
          PhotoSlot(
            t: t,
            value: it['photo'] as String?,
            onSet: (p) => _update(_open!, {'photo': p}),
            label: 'Fotoğraf ekle',
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: ValueKey('text_${_open}'),
            initialValue: it['text']?.toString() ?? '',
            onChanged: (v) => _update(_open!, {'text': v}),
            maxLines: 4,
            style: TextStyle(fontSize: 15, color: t.ink, height: 1.6),
            decoration: _inputDec(t, 'O an...'),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (_items.isEmpty)
          EmptyState(t: t, text: 'Kendi özel "ilk"lerini ekle — adı otomatik başlık olur'),
        ...List.generate(_items.length, (i) {
          final it = _items[i];
          return GestureDetector(
            onTap: () => setState(() => _open = i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.line),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: t.accent.withOpacity(0.15),
                    ),
                    child: Icon(Icons.auto_awesome, color: t.gold, size: 20),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it['title']?.toString().isNotEmpty == true
                              ? it['title'].toString()
                              : 'İsimsiz ilk',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                        Text(
                          it['date']?.toString().isNotEmpty == true
                              ? it['date'].toString()
                              : 'tarih yok',
                          style: TextStyle(fontSize: 12, color: t.soft),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 17, color: t.soft),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        AddButton(t: t, onTap: () {
          final i = _items.length;
          setState(() => _items.add({'title': '', 'date': '', 'photo': null, 'text': ''}));
          _emit();
          setState(() => _open = i);
        }, label: 'Yeni İlk Ekle'),
      ],
    );
  }
}

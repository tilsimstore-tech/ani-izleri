import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/album_widget.dart';
import '../../../widgets/empty_state.dart';

class Memories2Page extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const Memories2Page({
    super.key,
    required this.t,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<Memories2Page> createState() => _Memories2PageState();
}

class _Memories2PageState extends State<Memories2Page> {
  late List<Map<String, dynamic>> _memories;
  int? _open;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['memories'] as List?) ?? [];
    _memories =
        saved.map((m) => Map<String, dynamic>.from(m as Map)).toList();
  }

  void _emit() => widget.onChanged({'memories': _memories});

  void _update(int i, Map<String, dynamic> patch) {
    setState(() => _memories[i] = {..._memories[i], ...patch});
    _emit();
  }

  Future<void> _pickDate(int i) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: widget.t.goldDeep,
            onPrimary: Colors.white,
            surface: widget.t.panel,
            onSurface: widget.t.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _update(i, {'date': DateFormat('dd MMMM yyyy', 'tr_TR').format(picked)});
    }
  }

  // Anı içindeki yazı bloklarını güncelle
  List<String> _getTexts(Map<String, dynamic> m) {
    final raw = m['texts'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    // eski format: tek 'text' alanı
    final old = m['text']?.toString() ?? '';
    return old.isEmpty ? [''] : [old];
  }

  InputDecoration _dec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.panel,
        hintText: hint,
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
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    // Anı detay ekranı
    if (_open != null && _open! < _memories.length) {
      final idx = _open!;
      final m = _memories[idx];
      final rawMedia = (m['media'] as List?) ?? [];
      final media = rawMedia
          .map((x) =>
              MediaItem.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList();
      final texts = _getTexts(m);
      final dateText = m['date']?.toString() ?? '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => setState(() => _open = null),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chevron_left, size: 15, color: t.ink),
                const SizedBox(width: 4),
                Text('Anılara dön',
                    style: TextStyle(color: t.ink, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık
          TextFormField(
            key: ValueKey('title_$idx'),
            initialValue: m['title']?.toString() ?? '',
            onChanged: (v) => _update(idx, {'title': v}),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
            decoration: _dec(t, 'Anı başlığı (ör. İlk tekme)'),
          ),
          const SizedBox(height: 14),

          // Tarih seçici
          Text('TARİH',
              style: TextStyle(
                  fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: () => _pickDate(idx),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: t.line),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: t.soft),
                  const SizedBox(width: 10),
                  Text(
                    dateText.isEmpty ? 'Tarih seç...' : dateText,
                    style: TextStyle(
                      fontSize: 15,
                      color: dateText.isEmpty
                          ? t.soft.withOpacity(0.5)
                          : t.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Medya albümü
          Text('FOTOĞRAF / VIDEO',
              style: TextStyle(
                  fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
          const SizedBox(height: 8),
          AlbumWidget(
            items: media,
            onChanged: (items) => _update(idx,
                {'media': items.map((mi) => mi.toJson()).toList()}),
            accent: t.accent,
            goldDeep: t.goldDeep,
            panel: t.panel,
            line: t.line,
          ),
          const SizedBox(height: 14),

          // Yazı blokları
          Text('YAZI',
              style: TextStyle(
                  fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
          const SizedBox(height: 8),
          ...List.generate(texts.length, (ti) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Stack(
                children: [
                  TextFormField(
                    key: ValueKey('text_${idx}_$ti'),
                    initialValue: texts[ti],
                    onChanged: (v) {
                      final updated = List<String>.from(texts);
                      updated[ti] = v;
                      _update(idx, {'texts': updated});
                    },
                    maxLines: 5,
                    style: TextStyle(
                        fontSize: 15, color: t.ink, height: 1.6),
                    decoration: _dec(t, 'Anlat...'),
                  ),
                  if (texts.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          final updated = List<String>.from(texts)
                            ..removeAt(ti);
                          _update(idx, {'texts': updated});
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black26,
                          ),
                          child: const Icon(Icons.close,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          // + Yazı ekle (küçük sade buton)
          TextButton.icon(
            onPressed: () {
              final updated = List<String>.from(texts)..add('');
              _update(idx, {'texts': updated});
            },
            icon: Icon(Icons.add, size: 16, color: t.goldDeep),
            label: Text(
              'Yazı ekle',
              style: TextStyle(
                  color: t.goldDeep,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
            ),
          ),
        ],
      );
    }

    // Liste ekranı
    return Column(
      children: [
        if (_memories.isEmpty)
          EmptyState(t: t, text: 'Her anıyı kendi klasöründe sakla'),
        ...List.generate(_memories.length, (i) {
          final m = _memories[i];
          final mediaList = (m['media'] as List?) ?? [];
          final texts = _getTexts(m);
          final hasText = texts.any((t) => t.trim().isNotEmpty);
          return GestureDetector(
            onTap: () => setState(() => _open = i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: t.accent.withOpacity(0.15),
                    ),
                    child:
                        Icon(Icons.favorite, color: t.gold, size: 22),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['title']?.toString().isNotEmpty == true
                              ? m['title'].toString()
                              : 'Anı ${i + 1}',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: t.ink,
                          ),
                        ),
                        Text(
                          '${mediaList.length} medya · ${hasText ? "yazı var" : "yazı yok"}${m['date'] != null && m['date'].toString().isNotEmpty ? " · ${m['date']}" : ""}',
                          style:
                              TextStyle(fontSize: 12, color: t.soft),
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
        AddButton(
          t: t,
          onTap: () {
            final i = _memories.length;
            setState(() => _memories.add({
                  'title': '',
                  'texts': [''],
                  'media': [],
                  'date': '',
                }));
            _emit();
            setState(() => _open = i);
          },
          label: 'Yeni Anı Klasörü',
        ),
      ],
    );
  }
}
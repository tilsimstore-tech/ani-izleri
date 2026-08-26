import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/album_widget.dart';
import '../../../widgets/empty_state.dart';

class ReactionsPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ReactionsPage({
    super.key,
    required this.t,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<ReactionsPage> createState() => _ReactionsPageState();
}

class _ReactionsPageState extends State<ReactionsPage> {
  late List<Map<String, dynamic>> _reactions;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['reactions'] as List?) ?? [];
    _reactions =
        saved.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  void _emit() => widget.onChanged({'reactions': _reactions});

  void _update(int i, Map<String, dynamic> patch) {
    _reactions[i] = {..._reactions[i], ...patch};
    _emit();
  }

  List<MediaItem> _getMedia(int i) {
    final raw = (_reactions[i]['media'] as List?) ?? [];
    return raw
        .map((m) => MediaItem.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  Future<void> _confirmDelete(int i) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.t.panel,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kişiyi Sil',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: widget.t.ink,
          ),
        ),
        content: Text(
          'Bu kişiyi ve eklenen tüm fotoğraf/videoları silmek istediğinize emin misiniz?',
          style: TextStyle(color: widget.t.soft, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Vazgeç',
                style: TextStyle(color: widget.t.soft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sil',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _reactions.removeAt(i));
      _emit();
    }
  }

  InputDecoration _dec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.bg,
        hintText: hint,
        hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
    return Column(
      children: [
        if (_reactions.isEmpty)
          EmptyState(t: t, text: 'Herkesin tepkisini ayrı ayrı ekle'),
        ...List.generate(_reactions.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kim + sil butonu
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('who_$i'),
                        initialValue:
                            _reactions[i]['who']?.toString() ?? '',
                        onChanged: (v) => _update(i, {'who': v}),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: t.ink,
                        ),
                        decoration: _dec(t, 'Kim? (ör. Amcan)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(i),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.bg,
                          border: Border.all(color: t.line),
                        ),
                        child: Icon(Icons.delete_outline,
                            size: 16, color: Colors.red.shade300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                // Tepki yazısı
                TextFormField(
                  key: ValueKey('text_$i'),
                  initialValue:
                      _reactions[i]['text']?.toString() ?? '',
                  onChanged: (v) => _update(i, {'text': v}),
                  maxLines: 2,
                  style: TextStyle(fontSize: 15, color: t.ink),
                  decoration: _dec(t, 'Tepkisi nasıldı?'),
                ),
                const SizedBox(height: 12),
                // Fotoğraf / Video albümü
                Text(
                  'FOTOĞRAF / VIDEO',
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.8,
                    color: t.soft,
                  ),
                ),
                const SizedBox(height: 8),
                AlbumWidget(
                  items: _getMedia(i),
                  onChanged: (items) {
                    _update(i, {
                      'media': items.map((m) => m.toJson()).toList(),
                    });
                    setState(() {});
                  },
                  accent: t.accent,
                  goldDeep: t.goldDeep,
                  panel: t.panel,
                  line: t.line,
                  addLabel: 'Fotoğraf / Video Ekle',
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 13),
        AddButton(
          t: t,
          onTap: () => setState(
              () => _reactions.add({'who': '', 'text': '', 'media': []})),
          label: 'Kişi / Tepki Ekle',
        ),
      ],
    );
  }
}
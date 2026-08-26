import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/album_widget.dart';

class AlbumPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AlbumPage({super.key, required this.t, required this.entry, required this.onChanged});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    final raw = (widget.entry['photos'] as List?) ?? [];
    _items = raw.map((m) => MediaItem.fromJson(Map<String, dynamic>.from(m as Map))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return AlbumWidget(
      items: _items,
      onChanged: (items) {
        setState(() => _items = items);
        widget.onChanged({'photos': items.map((m) => m.toJson()).toList()});
      },
      accent: t.accent,
      goldDeep: t.goldDeep,
      panel: t.panel,
      line: t.line,
    );
  }
}

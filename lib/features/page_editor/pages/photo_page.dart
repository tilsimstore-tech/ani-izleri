import 'package:flutter/material.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/photo_slot.dart';

class PhotoPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PhotoPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.entry['text']?.toString() ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: PhotoSlot(
            t: t,
            value: widget.entry['photo'] as String?,
            onSet: (p) => widget.onChanged({'photo': p, 'text': _noteCtrl.text}),
            label: widget.page.note,
          ),
        ),
        const SizedBox(height: 18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NOT', style: TextStyle(fontSize: 12.5, letterSpacing: 0.8, color: t.soft)),
            const SizedBox(height: 7),
            TextField(
              controller: _noteCtrl,
              onChanged: (v) => widget.onChanged({'photo': widget.entry['photo'], 'text': v}),
              style: TextStyle(fontSize: 15, color: t.ink),
              decoration: InputDecoration(
                filled: true,
                fillColor: t.panel,
                hintText: 'Bir not ekle...',
                hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
      ],
    );
  }
}

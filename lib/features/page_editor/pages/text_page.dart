import 'package:flutter/material.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';

class TextPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TextPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
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
    return TextField(
      controller: _c,
      onChanged: (v) => widget.onChanged({'text': v}),
      maxLines: 9,
      style: TextStyle(fontSize: 15, color: t.ink, height: 1.7),
      decoration: InputDecoration(
        filled: true,
        fillColor: t.panel,
        hintText: widget.page.hint ?? 'Buraya yaz...',
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
    );
  }
}

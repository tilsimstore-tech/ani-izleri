import 'package:flutter/material.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_button.dart';

class QuickPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const QuickPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<QuickPage> createState() => _QuickPageState();
}

class _QuickPageState extends State<QuickPage> {
  late List<Map<String, dynamic>> _answers;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['answers'] as List?) ?? [];
    if (saved.isEmpty) {
      _answers = widget.page.fields
          .map((f) => <String, dynamic>{
                'q': f.label,
                'a': '',
                'preset': true,
              })
          .toList();
    } else {
      _answers = saved
          .map((x) => Map<String, dynamic>.from(x as Map))
          .toList();
    }
  }

  void _emit() => widget.onChanged({'answers': _answers});

  void _update(int i, Map<String, dynamic> patch) {
    _answers[i] = {..._answers[i], ...patch};
    _emit();
  }

  void _remove(int i) {
    setState(() => _answers.removeAt(i));
    _emit();
  }

  void _addCustom() {
    setState(() {
      _answers.add(<String, dynamic>{'q': '', 'a': '', 'preset': false});
    });
    _emit();
  }

  InputDecoration _dec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.panel,
        hintText: hint,
        hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
        ...List.generate(_answers.length, (i) {
          final row = _answers[i];
          final preset = row['preset'] == true;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preset)
                  // Preset başlık — büyük harf label
                  Text(
                    row['q']?.toString().toUpperCase() ?? '',
                    style: TextStyle(
                      fontSize: 12.5,
                      letterSpacing: 0.8,
                      color: t.soft,
                    ),
                  )
                else
                  // Kullanıcının kendi başlığı — aynı font/stil, placeholder "Soru / Başlık"
                  TextFormField(
                    key: ValueKey('q_$i'),
                    initialValue: row['q']?.toString() ?? '',
                    onChanged: (v) => _update(i, {'q': v}),
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontSize: 12.5,
                      letterSpacing: 0.8,
                      color: t.soft,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Soru / Başlık',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.8,
                        color: t.soft.withOpacity(0.5),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: t.line),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: t.line),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: t.gold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 2),
                      isDense: true,
                    ),
                  ),
                const SizedBox(height: 7),
                Stack(
                  children: [
                    TextFormField(
                      key: ValueKey('a_$i'),
                      initialValue: row['a']?.toString() ?? '',
                      onChanged: (v) => _update(i, {'a': v}),
                      style: TextStyle(fontSize: 15, color: t.ink),
                      decoration: _dec(t, 'Cevabın...').copyWith(
                        contentPadding: EdgeInsets.fromLTRB(
                            15, 13, preset ? 15 : 44, 13),
                      ),
                    ),
                    if (!preset)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => _remove(i),
                          child: Icon(Icons.delete_outline,
                              color: t.soft, size: 20),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        if (widget.page.allowAdd)
          AddButton(
            t: t,
            onTap: _addCustom,
            label: 'Kendi notunu ekle',
          ),
      ],
    );
  }
}
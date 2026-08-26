import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PredictionPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PredictionPage({super.key, required this.t, required this.entry, required this.onChanged});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  late List<String> _kiz;
  late List<String> _erkek;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kiz = List<String>.from((widget.entry['kiz'] as List?) ?? []);
    _erkek = List<String>.from((widget.entry['erkek'] as List?) ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged({'kiz': _kiz, 'erkek': _erkek});

  void _add(String gender) {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      if (gender == 'kiz') {
        _kiz = [..._kiz, name];
      } else {
        _erkek = [..._erkek, name];
      }
      _nameCtrl.clear();
    });
    _emit();
  }

  Widget _col(String title, List<String> list, Color color, String key) {
    final t = widget.t;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              Center(
                child: Text('Henüz yok',
                    style: TextStyle(fontSize: 12, color: t.soft.withOpacity(0.6))),
              ),
            ...list.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(e.value,
                            style: TextStyle(fontSize: 13, color: color)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (key == 'kiz') {
                              _kiz = List.from(_kiz)..removeAt(e.key);
                            } else {
                              _erkek = List.from(_erkek)..removeAt(e.key);
                            }
                          });
                          _emit();
                        },
                        child: Icon(Icons.close, size: 13, color: color),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    const kizColor = Color(0xFFC99A90);
    const erkekColor = Color(0xFF7A93A3);

    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          style: TextStyle(fontSize: 15, color: t.ink),
          decoration: InputDecoration(
            filled: true,
            fillColor: t.panel,
            hintText: 'Tahmin eden kişinin adı...',
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
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _add('kiz'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: kizColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '👧 Kız diyor',
                      style: TextStyle(
                          color: kizColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _add('erkek'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: erkekColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '👦 Erkek diyor',
                      style: TextStyle(
                          color: erkekColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _col('Kız Hissedenler', _kiz, kizColor, 'kiz'),
            const SizedBox(width: 12),
            _col('Erkek Hissedenler', _erkek, erkekColor, 'erkek'),
          ],
        ),
      ],
    );
  }
}

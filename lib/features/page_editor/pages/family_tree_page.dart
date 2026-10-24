import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/round_photo.dart';

const _kTreeNodes = [
  {'key': 'anneanne', 'role': 'Anneanne'},
  {'key': 'dedeanne', 'role': 'Dede (Anne)'},
  {'key': 'babaanne', 'role': 'Babaanne'},
  {'key': 'babababa', 'role': 'Dede (Baba)'},
  {'key': 'anne', 'role': 'Anne'},
  {'key': 'baba', 'role': 'Baba'},
];

// Otomatik doldurulan düğümler: anne/baba kendi bilgi sayfalarından,
// büyükanne/büyükbabalar "Ailemizin Diğer Üyeleri" listesinden gelir.
const _kAutoKeys = {
  'anne', 'baba', 'anneanne', 'dedeanne', 'babaanne', 'babababa',
};

class FamilyTreePage extends StatefulWidget {
  final AppTheme t;
  final String babyName;
  final String anneName;
  final String? annePhoto;
  final String babaName;
  final String? babaPhoto;
  final String anneanneName;
  final String? anneannePhoto;
  final String dedeAnneName;
  final String? dedeAnnePhoto;
  final String babaanneName;
  final String? babaannePhoto;
  final String dedeBabaName;
  final String? dedeBabaPhoto;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FamilyTreePage({
    super.key,
    required this.t,
    required this.babyName,
    required this.anneName,
    this.annePhoto,
    required this.babaName,
    this.babaPhoto,
    required this.anneanneName,
    this.anneannePhoto,
    required this.dedeAnneName,
    this.dedeAnnePhoto,
    required this.babaanneName,
    this.babaannePhoto,
    required this.dedeBabaName,
    this.dedeBabaPhoto,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  late Map<String, dynamic> _tree;
  String? _editing;

  @override
  void initState() {
    super.initState();
    _tree = Map<String, dynamic>.from((widget.entry['tree'] as Map?) ?? {});
  }

  // Otomatik kaynaktan gelen ismi döndürür (anne/baba/büyükanne/büyükbaba).
  String? _autoName(String key) {
    switch (key) {
      case 'anne': return widget.anneName;
      case 'baba': return widget.babaName;
      case 'anneanne': return widget.anneanneName;
      case 'dedeanne': return widget.dedeAnneName;
      case 'babaanne': return widget.babaanneName;
      case 'babababa': return widget.dedeBabaName;
      default: return null;
    }
  }

  // Otomatik kaynaktan gelen fotoğrafı döndürür.
  String? _autoPhoto(String key) {
    switch (key) {
      case 'anne': return widget.annePhoto;
      case 'baba': return widget.babaPhoto;
      case 'anneanne': return widget.anneannePhoto;
      case 'dedeanne': return widget.dedeAnnePhoto;
      case 'babaanne': return widget.babaannePhoto;
      case 'babababa': return widget.dedeBabaPhoto;
      default: return null;
    }
  }

  bool _isOverridden(String key) =>
      (_tree[key] as Map?)?['nameOverride'] != null ||
      (_tree[key] as Map?)?['photoOverride'] != null;

  // Bir düğümün gerçek adını döndür (otomatik kaynak + override desteği)
  String _getName(String key) {
    final override = (_tree[key] as Map?)?['nameOverride']?.toString();
    if (override != null && override.isNotEmpty) return override;
    final auto = _autoName(key);
    if (auto != null) return auto;
    return (_tree[key] as Map?)?['name']?.toString() ?? '';
  }

  // Bir düğümün fotoğrafını döndür (otomatik kaynak + override desteği)
  String? _getPhoto(String key) {
    final override = (_tree[key] as Map?)?['photoOverride'] as String?;
    if (override != null) return override;
    if (_kAutoKeys.contains(key)) return _autoPhoto(key);
    return (_tree[key] as Map?)?['photo'] as String?;
  }

  void _update(String key, Map<String, dynamic> patch) {
    setState(() {
      final existing = Map<String, dynamic>.from((_tree[key] as Map?) ?? {});
      existing.addAll(patch);
      _tree[key] = existing;
    });
    widget.onChanged({'tree': _tree});
  }

  Widget _nodeWidget(String? key, String role, {bool isChild = false}) {
    final photo = isChild
        ? ((_tree['cocuk'] as Map?)?['photo'] as String?)
        : (key != null ? _getPhoto(key) : null);
    final name = isChild
        ? widget.babyName
        : (key != null ? _getName(key) : '');
    final size = isChild ? 64.0 : 50.0;
    final t = widget.t;

    return GestureDetector(
      onTap: () => setState(() => _editing = isChild ? 'cocuk' : key),
      child: SizedBox(
        width: isChild ? 84 : 70,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.panel,
                border: Border.all(
                  color: isChild ? t.gold : t.soft,
                  width: 2,
                ),
                boxShadow: isChild
                    ? [BoxShadow(color: t.accent.withOpacity(0.33), blurRadius: 14)]
                    : null,
              ),
              child: ClipOval(
                child: photo != null && photo.isNotEmpty
                    ? (photo.startsWith('/')
                        ? Image.file(File(photo),
                            fit: BoxFit.cover, width: size, height: size)
                        : Image.network(photo,
                            fit: BoxFit.cover, width: size, height: size))
                    : Icon(Icons.person,
                        color: t.soft, size: isChild ? 26 : 20),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role.toUpperCase(),
              style: TextStyle(fontSize: 10, color: t.soft, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            Text(
              name.isEmpty ? '—' : name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: t.ink,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _line() => Center(
        child: Container(width: 2, height: 18, color: widget.t.line),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final editKey = _editing;
    final roleName = editKey == 'cocuk'
        ? 'Bebeğimiz'
        : (_kTreeNodes.firstWhere(
              (x) => x['key'] == editKey,
              orElse: () => {'role': ''},
            )['role'] ??
            '');

    // Otomatik doldurulan bir düğüm elle değiştirilmiş mi?
    final isAutoOverride =
        editKey != null && _kAutoKeys.contains(editKey) && _isOverridden(editKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: t.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.line),
          ),
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    _nodeWidget('anneanne', 'Anneanne'),
                    const SizedBox(width: 2),
                    _nodeWidget('dedeanne', 'Dede'),
                  ]),
                  Row(children: [
                    _nodeWidget('babaanne', 'Babaanne'),
                    const SizedBox(width: 2),
                    _nodeWidget('babababa', 'Dede'),
                  ]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [_line(), _line()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nodeWidget('anne', 'Anne'),
                  Icon(Icons.favorite, color: t.gold, size: 16),
                  _nodeWidget('baba', 'Baba'),
                ],
              ),
              _line(),
              _nodeWidget('cocuk', 'Bebeğimiz', isChild: true),
            ],
          ),
        ),

        // Düzenleme paneli
        if (editKey != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      roleName,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: t.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _editing = null),
                      child: Icon(Icons.close, color: t.soft, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RoundPhoto(
                      t: t,
                      value: editKey == 'cocuk'
                          ? ((_tree['cocuk'] as Map?)?['photo'] as String?)
                          : _getPhoto(editKey!),
                      onSet: (p) {
                        if (_kAutoKeys.contains(editKey)) {
                          _update(editKey, {'photoOverride': p});
                        } else {
                          _update(editKey, {'photo': p});
                        }
                      },
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: editKey == 'cocuk'
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 13),
                              decoration: BoxDecoration(
                                color: t.bg,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: t.line),
                              ),
                              child: Text(
                                '${widget.babyName} (otomatik)',
                                style: TextStyle(color: t.soft),
                              ),
                            )
                          : TextFormField(
                              key: ValueKey('name_$editKey'),
                              initialValue: _kAutoKeys.contains(editKey)
                                  ? ((_tree[editKey] as Map?)?['nameOverride']
                                          ?.toString() ??
                                      _getName(editKey))
                                  : _getName(editKey),
                              onChanged: (v) {
                                if (_kAutoKeys.contains(editKey)) {
                                  _update(editKey, {'nameOverride': v});
                                } else {
                                  _update(editKey, {'name': v});
                                }
                              },
                              style: TextStyle(fontSize: 15, color: t.ink),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: t.bg,
                                hintText: 'İsim',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 13),
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
                    ),
                  ],
                ),
                // Otomatik doldurulan düğümler için "Orijinal bilgiyi kullan" butonu
                if (isAutoOverride) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        final existing = Map<String, dynamic>.from(
                            (_tree[editKey] as Map?) ?? {});
                        existing.remove('nameOverride');
                        existing.remove('photoOverride');
                        _tree[editKey] = existing;
                      });
                      widget.onChanged({'tree': _tree});
                    },
                    icon: Icon(Icons.refresh, size: 16, color: t.soft),
                    label: Text(
                      'Orijinal bilgiyi kullan',
                      style: TextStyle(color: t.soft, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),
        Text(
          'Düzenlemek için bir kişiye dokun',
          style: TextStyle(fontSize: 11.5, color: t.soft.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/round_photo.dart';

const _kRelations = [
  'Anneanne', 'Babaanne', 'Dede', 'Hala', 'Teyze',
  'Amca', 'Dayı', 'Kardeş', 'Kuzen',
];

class MembersPage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MembersPage({
    super.key,
    required this.t,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late List<Map<String, dynamic>> _members;

  bool _formOpen = false;
  int? _editIndex;
  String _formName = '';
  String _formRel = '';
  bool _formCustom = false;
  String? _formPhoto;

  @override
  void initState() {
    super.initState();
    final saved = (widget.entry['members'] as List?) ?? [];
    _members =
        saved.map((m) => Map<String, dynamic>.from(m as Map)).toList();
  }

  void _emit() => widget.onChanged({'members': _members});

  void _openForm({int? editIndex}) {
    setState(() {
      _editIndex = editIndex;
      _formOpen = true;
      if (editIndex != null) {
        final m = _members[editIndex];
        _formName = m['name']?.toString() ?? '';
        _formRel = m['rel']?.toString() ?? '';
        _formCustom = m['custom'] == true;
        _formPhoto = m['photo'] as String?;
      } else {
        _formName = '';
        _formRel = '';
        _formCustom = false;
        _formPhoto = null;
      }
    });
  }

  void _confirm() {
    if (_formName.trim().isEmpty && _formRel.trim().isEmpty) return;
    final member = {
      'name': _formName,
      'rel': _formRel,
      'custom': _formCustom,
      'photo': _formPhoto,
    };
    setState(() {
      if (_editIndex != null) {
        _members[_editIndex!] = member;
      } else {
        _members.add(member);
      }
      _formOpen = false;
      _editIndex = null;
    });
    _emit();
  }

  void _cancelForm() {
    setState(() {
      _formOpen = false;
      _editIndex = null;
    });
  }

  Future<void> _confirmDelete(int i) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.t.panel,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kişiyi Sil',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: widget.t.ink,
          ),
        ),
        content: Text(
          'Bu kişiyi silmek istediğinize emin misiniz?',
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
      setState(() => _members.removeAt(i));
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_members.isEmpty && !_formOpen)
          EmptyState(t: t, text: 'Ailenin diğer üyelerini ekle'),

        // Kart listesi
        ...List.generate(_members.length, (i) {
          final m = _members[i];
          final rel = m['rel']?.toString() ?? '';
          final name = m['name']?.toString() ?? '';
          final photo = m['photo'] as String?;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: t.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                // Profil fotoğrafı — Image.file kullan
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.gold, width: 1.5),
                  ),
                  child: ClipOval(
                    child: photo != null &&
                            photo.isNotEmpty &&
                            File(photo).existsSync()
                        ? Image.file(File(photo),
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52)
                        : Container(
                            color: t.bg,
                            child: Icon(Icons.person,
                                color: t.soft, size: 26),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'İsimsiz' : name,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: t.ink,
                        ),
                      ),
                      if (rel.isNotEmpty)
                        Text(rel,
                            style:
                                TextStyle(fontSize: 13, color: t.soft)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _openForm(editIndex: i),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.bg,
                          border: Border.all(color: t.line),
                        ),
                        child: Icon(Icons.edit_outlined,
                            size: 16, color: t.soft),
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
              ],
            ),
          );
        }),

        // Form
        if (_formOpen) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.gold),
              boxShadow: [
                BoxShadow(
                  color: t.accent.withOpacity(0.15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundPhoto(
                      t: t,
                      value: _formPhoto,
                      onSet: (p) => setState(() => _formPhoto = p),
                      size: 60,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('name_${_editIndex ?? 'new'}'),
                        initialValue: _formName,
                        onChanged: (v) => setState(() => _formName = v),
                        style: TextStyle(fontSize: 15, color: t.ink),
                        decoration: _dec(t, 'Ad Soyad'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'YAKINLIK DERECESİ',
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.8,
                    color: t.soft,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    ..._kRelations.map((r) {
                      final sel = _formRel == r && !_formCustom;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _formRel = r;
                          _formCustom = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: sel
                                ? t.accent.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                                color: sel ? t.gold : t.line),
                          ),
                          child: Text(r,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: sel ? t.goldDeep : t.soft,
                              )),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => setState(() {
                        _formCustom = true;
                        if (_kRelations.contains(_formRel)) {
                          _formRel = '';
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: _formCustom
                              ? t.accent.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                              color: _formCustom ? t.gold : t.line),
                        ),
                        child: Text('Diğer',
                            style: TextStyle(
                              fontSize: 12.5,
                              color:
                                  _formCustom ? t.goldDeep : t.soft,
                            )),
                      ),
                    ),
                  ],
                ),
                if (_formCustom) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey(
                        'rel_custom_${_editIndex ?? 'new'}'),
                    initialValue: !_kRelations.contains(_formRel)
                        ? _formRel
                        : '',
                    autofocus: true,
                    onChanged: (v) => setState(() => _formRel = v),
                    style: TextStyle(fontSize: 15, color: t.ink),
                    decoration:
                        _dec(t, 'Yakınlık derecesini yaz...'),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.soft,
                          side: BorderSide(color: t.line),
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(13)),
                        ),
                        child: const Text('Vazgeç'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.goldDeep,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(13)),
                          elevation: 0,
                        ),
                        child: Text(_editIndex != null
                            ? 'Güncelle'
                            : 'Onayla'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // + Aile Üyesi Ekle butonu
        if (!_formOpen) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _openForm(),
            icon: Icon(Icons.add, color: t.goldDeep),
            label: Text(
              '+ Aile Üyesi Ekle',
              style: TextStyle(
                  color: t.goldDeep, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: t.accent.withOpacity(0.08),
              side: BorderSide(color: t.goldDeep, width: 1.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }
}
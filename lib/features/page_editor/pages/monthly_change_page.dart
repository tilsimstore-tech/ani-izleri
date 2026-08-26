import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/add_button.dart';
import '../../../widgets/empty_state.dart';

class MonthlyChangePage extends StatefulWidget {
  final AppTheme t;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MonthlyChangePage({
    super.key,
    required this.t,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<MonthlyChangePage> createState() => _MonthlyChangePageState();
}

class _MonthlyChangePageState extends State<MonthlyChangePage> {
  late List<Map<String, dynamic>> _items;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    // Eski Map formatından yeni List formatına dönüştür
    final raw = widget.entry['items'];
    if (raw is List) {
      _items = raw.map((x) => Map<String, dynamic>.from(x as Map)).toList();
    } else if (widget.entry['months'] is Map) {
      // eski format varsa dönüştür
      final oldMap = widget.entry['months'] as Map;
      _items = [];
      for (final entry in oldMap.entries) {
        final month = int.tryParse(entry.key.toString()) ?? 1;
        final photos = (entry.value as List?) ?? [];
        for (final p in photos) {
          _items.add({'month': month, 'photo': p.toString()});
        }
      }
    } else {
      _items = [];
    }
  }

  void _emit() => widget.onChanged({'items': _items});

  Future<void> _chooseAndPick(int month) async {
    setState(() => _picking = false);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);
    final id = const Uuid().v4();
    final ext = file.path.split('.').last;
    final dest = '${mediaDir.path}/$id.$ext';
    await File(file.path).copy(dest);
    setState(() => _items = [..._items, {'month': month, 'photo': dest}]);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final presentMonths = _items
        .map((i) => i['month'] as int)
        .toSet()
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddButton(
          t: t,
          onTap: () => setState(() => _picking = !_picking),
          label: 'Fotoğraf Ekle',
        ),
        if (_picking) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hangi aya ait?',
                  style: TextStyle(fontSize: 13, color: t.soft),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.0,
                  children: List.generate(9, (i) {
                    final m = i + 1;
                    return GestureDetector(
                      onTap: () => _chooseAndPick(m),
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.line),
                        ),
                        child: Center(
                          child: Text(
                            '$m. Ay',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.ink,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (_items.isEmpty)
          EmptyState(
            t: t,
            text: 'Ay seç, fotoğrafı ekle — otomatik sıralanır',
          ),
        ...presentMonths.map((m) {
          final monthItems = _items
              .asMap()
              .entries
              .where((e) => e.value['month'] == m)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      '$m. Ay',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: t.goldDeep,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Divider(color: t.line)),
                  ],
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: monthItems.map((e) {
                  final gi = e.key;
                  final photo = e.value['photo'] as String;
                  return Stack(
                    children: [
                      Transform.rotate(
                        angle: (gi % 2 == 0 ? -1.2 : 1.2) * 3.14159 / 180,
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.panel,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: t.line),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(7),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.file(
                                File(photo),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _items.removeAt(gi));
                            _emit();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
            ],
          );
        }),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_theme.dart';

class PhotoSlot extends StatelessWidget {
  final AppTheme t;
  final String? value;
  final ValueChanged<String?> onSet;
  final String? label;
  final bool tape;

  const PhotoSlot({
    super.key,
    required this.t,
    required this.value,
    required this.onSet,
    this.label,
    this.tape = true,
  });

  Future<void> _pick() async {
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
    onSet(dest);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (tape)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.052,
                child: Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: t.tape.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.line),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: value != null
                    ? Image.file(File(value!), fit: BoxFit.cover)
                    : Container(
                        color: t.bg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: t.soft.withOpacity(0.6), size: 26),
                            const SizedBox(height: 6),
                            Text(
                              label ?? 'Fotoğraf ekle',
                              style: TextStyle(color: t.soft, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (value != null)
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: () => onSet(null),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

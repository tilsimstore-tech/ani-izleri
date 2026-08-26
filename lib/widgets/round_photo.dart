import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_theme.dart';

class RoundPhoto extends StatelessWidget {
  final AppTheme t;
  final String? value;
  final ValueChanged<String?> onSet;
  final double size;

  const RoundPhoto({
    super.key,
    required this.t,
    required this.value,
    required this.onSet,
    this.size = 70,
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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pick,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.panel,
                border: Border.all(color: t.gold, width: 2),
                boxShadow: [BoxShadow(color: t.accent.withOpacity(0.3), blurRadius: 14)],
                image: value != null
                    ? DecorationImage(image: FileImage(File(value!)), fit: BoxFit.cover)
                    : null,
              ),
              child: value == null
                  ? Icon(Icons.camera_alt, color: t.soft, size: size * 0.32)
                  : null,
            ),
          ),
          if (value != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => onSet(null),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.ink,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

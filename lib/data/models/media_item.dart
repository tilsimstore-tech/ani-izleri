// lib/data/models/media_item.dart
//
// Medya (foto/video) modeli. Dosyalar cihazın yerel dizinine kopyalanır,
// burada sadece DOSYA YOLU tutulur. (DB'ye blob yazmıyoruz — performans kuralı.)
//
// Hive adapter üretmek için:  flutter pub run build_runner build
import 'package:hive/hive.dart';

part 'media_item.g.dart';

@HiveType(typeId: 2)
class MediaItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'photo' | 'video'

  @HiveField(2)
  String path; // ApplicationDocumentsDirectory altındaki tam yol

  @HiveField(3)
  String? thumbPath; // video için kapak görseli (opsiyonel)

  MediaItem({
    required this.id,
    required this.type,
    required this.path,
    this.thumbPath,
  });

  bool get isVideo => type == 'video';

  Map<String, dynamic> toJson() =>
      {'id': id, 'type': type, 'path': path, 'thumbPath': thumbPath};

  factory MediaItem.fromJson(Map<String, dynamic> j) => MediaItem(
        id: j['id'] as String,
        type: j['type'] as String,
        path: j['path'] as String,
        thumbPath: j['thumbPath'] as String?,
      );
}
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../models/memory_entry.dart';

class AppProvider extends ChangeNotifier {
  late Box<MemoryEntry> _box;
  late Box<String> _settingsBox;
  String _themeKey = 'mavi';

  AppTheme get theme => kThemes[_themeKey]!;
  String get themeKey => _themeKey;

  Future<void> init() async {
    _box = await Hive.openBox<MemoryEntry>('memories');
    _settingsBox = await Hive.openBox<String>('settings');
    _themeKey = _settingsBox.get('theme', defaultValue: 'mavi')!;
  }

  Map<String, dynamic> getEntry(String pageId) {
    final e = _box.get(pageId);
    if (e == null) return {};
    return e.data;
  }

  void saveEntry(String pageId, Map<String, dynamic> patch) {
    var e = _box.get(pageId) ??
        MemoryEntry(pageId: pageId, jsonData: '{}');
    e.merge(patch);
    _box.put(pageId, e);
    notifyListeners();
  }

  void setTheme(String key) {
    _themeKey = key;
    _settingsBox.put('theme', key);
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> get allEntries {
    final result = <String, Map<String, dynamic>>{};
    for (final e in _box.values) {
      result[e.pageId] = e.data;
    }
    return result;
  }

  // ============================================================
  // YEDEKLEME
  // ============================================================
  Future<String?> backup() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();

      // 1. Verileri JSON'a hazırla
      final dataMap = <String, dynamic>{};
      for (final e in _box.values) {
        dataMap[e.pageId] = e.data;
      }
      final jsonStr = jsonEncode({
        'version': 1,
        'theme': _themeKey,
        'entries': dataMap,
      });

      // 2. Archive oluştur
      final archive = Archive();

      // data.json ekle
      final jsonBytes = utf8.encode(jsonStr);
      archive.addFile(
          ArchiveFile('data.json', jsonBytes.length, jsonBytes));

      // Medya dosyalarını ekle
      final mediaDir = Directory('${appDir.path}/media');
      final audioDir = Directory('${appDir.path}/audio');

      Future<void> addDirToArchive(
          Directory dir, String prefix) async {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            final rel =
                '$prefix/${entity.path.replaceFirst('${dir.path}/', '')}';
            archive.addFile(
                ArchiveFile(rel, bytes.length, bytes));
          }
        }
      }

      await addDirToArchive(mediaDir, 'media');
      await addDirToArchive(audioDir, 'audio');

      // 3. ZIP encode
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) return null;

      final zipPath = '${tempDir.path}/tilsim_yedek.tilsim';
      await File(zipPath).writeAsBytes(zipBytes);

      return zipPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _copyDir(Directory src, Directory dest) async {
    if (!await dest.exists()) await dest.create(recursive: true);
    await for (final entity in src.list(recursive: false)) {
      if (entity is File) {
        await entity.copy(
            '${dest.path}/${entity.uri.pathSegments.last}');
      } else if (entity is Directory) {
        await _copyDir(
          entity,
          Directory(
              '${dest.path}/${entity.uri.pathSegments.last}'),
        );
      }
    }
  }

  // ============================================================
  // GERİ YÜKLEME
  // ============================================================
  Future<bool> restore(String zipPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      final restoreDir =
          Directory('${tempDir.path}/tilsim_restore');
      if (await restoreDir.exists()) {
        await restoreDir.delete(recursive: true);
      }
      await restoreDir.create(recursive: true);

      // 1. ZIP'i aç
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filePath = '${restoreDir.path}/${file.name}';
        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile
              .writeAsBytes(file.content as List<int>);
        }
      }

      // 2. data.json'u bul
      File? dataFile;
      await for (final f
          in restoreDir.list(recursive: true)) {
        if (f is File && f.path.endsWith('data.json')) {
          dataFile = f;
          break;
        }
      }
      if (dataFile == null || !await dataFile.exists()) {
        return false;
      }

      final jsonStr = await dataFile.readAsString();
      final json = jsonDecode(jsonStr);
      final entries =
          json['entries'] as Map<String, dynamic>;
      final theme = json['theme'] as String? ?? 'mavi';

      // 3. Medya klasörlerini geri yükle
      final backupRoot = dataFile.parent.path;
      final restoreMedia = Directory('$backupRoot/media');
      final restoreAudio = Directory('$backupRoot/audio');
      if (await restoreMedia.exists()) {
        await _copyDir(
            restoreMedia, Directory('${appDir.path}/media'));
      }
      if (await restoreAudio.exists()) {
        await _copyDir(
            restoreAudio, Directory('${appDir.path}/audio'));
      }

      // 4. Hive'a yaz
      await _box.clear();
      for (final entry in entries.entries) {
        final e = MemoryEntry(
          pageId: entry.key,
          jsonData: jsonEncode(entry.value),
        );
        await _box.put(entry.key, e);
      }

      // 5. Temayı geri yükle
      _themeKey = theme;
      _settingsBox.put('theme', theme);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
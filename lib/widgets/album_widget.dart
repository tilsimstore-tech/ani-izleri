import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../data/models/media_item.dart';
import 'media_viewer_page.dart';

class AlbumWidget extends StatefulWidget {
  final List<MediaItem> items;
  final ValueChanged<List<MediaItem>> onChanged;
  final String addLabel;
  final Color accent;
  final Color goldDeep;
  final Color panel;
  final Color line;

  const AlbumWidget({
    super.key,
    required this.items,
    required this.onChanged,
    required this.accent,
    required this.goldDeep,
    required this.panel,
    required this.line,
    this.addLabel = 'Fotoğraf / Video Ekle',
  });

  @override
  State<AlbumWidget> createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  final Map<String, String?> _thumbCache = {};

  @override
  void initState() {
    super.initState();
    _generateThumbs();
  }

  @override
  void didUpdateWidget(AlbumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _generateThumbs();
    }
  }

  Future<void> _generateThumbs() async {
    for (final m in widget.items) {
      if (m.isVideo && !_thumbCache.containsKey(m.id)) {
        final thumb = await _getThumb(m.path, m.id);
        if (mounted) {
          setState(() => _thumbCache[m.id] = thumb);
        }
      }
    }
  }

  Future<String?> _getThumb(String videoPath, String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory('${dir.path}/thumbs');
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }
      final thumbPath = '${thumbDir.path}/$id.jpg';
      if (await File(thumbPath).exists()) return thumbPath;

      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 75,
        timeMs: 0,
      );
      if (uint8list == null) return null;
      await File(thumbPath).writeAsBytes(uint8list);
      return thumbPath;
    } catch (e) {
      debugPrint('Thumb error: $e');
      return null;
    }
  }

  Future<void> _add(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile> files = await picker.pickMultipleMedia();
    if (files.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);

    final added = <MediaItem>[];
    for (final f in files) {
      final lower = f.path.toLowerCase();
      final isVideo = (f.mimeType?.startsWith('video') ?? false) ||
          lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.m4v');
      final id = const Uuid().v4();
      final ext = f.path.contains('.') ? f.path.split('.').last : 'dat';
      final dest = '${mediaDir.path}/$id.$ext';
      await File(f.path).copy(dest);
      final item = MediaItem(
          id: id, type: isVideo ? 'video' : 'photo', path: dest);
      added.add(item);

      if (isVideo) {
        final thumb = await _getThumb(dest, id);
        if (mounted) setState(() => _thumbCache[id] = thumb);
      }
    }
    widget.onChanged([...widget.items, ...added]);
  }

  void _open(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MediaViewerPage(items: widget.items, initialIndex: index),
      ),
    );
  }

  void _remove(int index) {
    final copy = [...widget.items]..removeAt(index);
    widget.onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.items.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: widget.items.length,
            itemBuilder: (_, i) {
              final m = widget.items[i];
              final angle =
                  (i % 2 == 0 ? -1.3 : 1.3) * 3.1416 / 180;
              final thumbPath = _thumbCache[m.id];

              return Transform.rotate(
                angle: angle,
                child: GestureDetector(
                  onTap: () => _open(context, i),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: widget.panel,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: widget.line),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Hero(
                            tag: m.id,
                            child: m.isVideo
                                ? (thumbPath != null
                                    ? Image.file(
                                        File(thumbPath),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.blueGrey.shade800,
                                              Colors.blueGrey.shade600,
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.videocam,
                                            color: Colors.white70,
                                            size: 32,
                                          ),
                                        ),
                                      ))
                                : Image.file(File(m.path),
                                    fit: BoxFit.cover),
                          ),
                        ),
                        if (m.isVideo)
                          const Center(
                            child: Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 40),
                          ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _remove(i),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        OutlinedButton.icon(
          onPressed: () => _add(context),
          icon: Icon(Icons.add, color: widget.goldDeep),
          label: Text(widget.addLabel,
              style: TextStyle(color: widget.goldDeep)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: widget.accent.withOpacity(0.08),
            side: BorderSide(color: widget.goldDeep, width: 1.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
// lib/widgets/media_viewer_page.dart
//
// Tam ekran medya görüntüleyici:
//  • Fotoğraflar: çift dokun / parmakla yakınlaştır (photo_view)
//  • Albümde sağa-sola kaydırarak geçiş (PageView)
//  • Videolar: VideoPlayerWidget ile oynat/duraklat/sar
//  • Üstte "3 / 8" sayaç ve kapat butonu
//
// Bağımlılıklar: photo_view, video_player
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../data/models/media_item.dart';
import 'video_player_widget.dart';

class MediaViewerPage extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;
  const MediaViewerPage(
      {super.key, required this.items, this.initialIndex = 0});

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final PageController _pc;
  late int _i;

  @override
  void initState() {
    super.initState();
    _i = widget.initialIndex;
    _pc = PageController(initialPage: _i);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: widget.items.length,
            onPageChanged: (v) => setState(() => _i = v),
            itemBuilder: (_, i) {
              final m = widget.items[i];
              if (m.isVideo) {
                return Center(
                    child: VideoPlayerWidget(path: m.path, autoPlay: i == _i));
              }
              return PhotoView(
                imageProvider: FileImage(File(m.path)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: m.id),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.black),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('${_i + 1} / ${widget.items.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
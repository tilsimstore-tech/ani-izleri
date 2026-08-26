// lib/widgets/video_player_widget.dart
//
// Oynat / duraklat, ileri-geri sarma (slider + 10sn butonları),
// konum/süre göstergesi olan, temaya uygun şık video oynatıcı.
// Sadece `video_player` paketine bağlıdır (Android + iOS uyumlu).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  final bool autoPlay;
  const VideoPlayerWidget({super.key, required this.path, this.autoPlay = false});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController _c;
  bool _ready = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.path))
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        if (widget.autoPlay) _c.play();
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  void _seekBy(int seconds) {
    final target = _c.value.position + Duration(seconds: seconds);
    final max = _c.value.duration;
    _c.seekTo(target < Duration.zero
        ? Duration.zero
        : (target > max ? max : target));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final pos = _c.value.position;
    final dur = _c.value.duration;
    final maxMs = dur.inMilliseconds <= 0 ? 1.0 : dur.inMilliseconds.toDouble();

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio:
                  _c.value.aspectRatio == 0 ? 16 / 9 : _c.value.aspectRatio,
              child: VideoPlayer(_c),
            ),
          ),
          if (_showControls)
            Container(color: Colors.black.withOpacity(0.28)),
          if (_showControls)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 38,
                  color: Colors.white,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _seekBy(-10),
                ),
                IconButton(
                  iconSize: 66,
                  color: Colors.white,
                  icon: Icon(_c.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  onPressed: () {
                    setState(() =>
                        _c.value.isPlaying ? _c.pause() : _c.play());
                  },
                ),
                IconButton(
                  iconSize: 38,
                  color: Colors.white,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _seekBy(10),
                ),
              ],
            ),
          if (_showControls)
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: Row(
                children: [
                  Text(_fmt(pos),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14),
                      ),
                      child: Slider(
                        value: pos.inMilliseconds
                            .clamp(0, maxMs.toInt())
                            .toDouble(),
                        max: maxMs,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        onChanged: (v) =>
                            _c.seekTo(Duration(milliseconds: v.toInt())),
                      ),
                    ),
                  ),
                  Text(_fmt(dur),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
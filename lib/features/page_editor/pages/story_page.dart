import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/album_widget.dart';
import '../../../widgets/mood_picker.dart';

class StoryPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const StoryPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late final TextEditingController _textCtrl;
  late String _dateText;
  late List<MediaItem> _media;
  late String? _mood;
  late List<String> _audioPaths;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  // Her ses için ayrı player
  final Map<int, AudioPlayer> _players = {};
  final Map<int, bool> _playing = {};
  final Map<int, Duration> _positions = {};
  final Map<int, Duration> _durations = {};

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(
        text: widget.entry['text']?.toString() ?? '');
    _dateText = widget.entry['date']?.toString() ?? '';
    final rawMedia = (widget.entry['media'] as List?) ?? [];
    _media = rawMedia
        .map((m) => MediaItem.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();
    _mood = widget.entry['mood'] as String?;

    // Eski tekli format + yeni liste format desteği
    final rawPaths = widget.entry['audioPaths'];
    if (rawPaths is List) {
      _audioPaths = rawPaths.map((e) => e.toString()).toList();
    } else {
      final old = widget.entry['audioPath'] as String?;
      _audioPaths = old != null ? [old] : [];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _recorder.dispose();
    for (final p in _players.values) p.dispose();
    super.dispose();
  }

  AudioPlayer _playerFor(int i) {
    if (!_players.containsKey(i)) {
      final p = AudioPlayer();
      _players[i] = p;
      _playing[i] = false;
      _positions[i] = Duration.zero;
      _durations[i] = Duration.zero;
      p.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _playing[i] = s == PlayerState.playing);
      });
      p.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _positions[i] = pos);
      });
      p.onDurationChanged.listen((d) {
        if (mounted && d.inMilliseconds > 0) setState(() => _durations[i] = d);
      });
      p.onPlayerComplete.listen((_) {
        if (mounted) setState(() {
          _playing[i] = false;
          _positions[i] = Duration.zero;
        });
      });
    }
    return _players[i]!;
  }

  Future<void> _loadAll() async {
    for (int i = 0; i < _audioPaths.length; i++) {
      await _loadAudio(i);
    }
  }

  Future<void> _loadAudio(int i) async {
    if (i >= _audioPaths.length) return;
    try {
      final p = _playerFor(i);
      await p.stop();
      await p.setSource(DeviceFileSource(_audioPaths[i]));
      await Future.delayed(const Duration(milliseconds: 200));
      final d = await p.getDuration();
      if (d != null && mounted) setState(() => _durations[i] = d);
    } catch (_) {}
  }

  void _emit() {
    widget.onChanged({
      'date': _dateText,
      'text': _textCtrl.text,
      'media': _media.map((m) => m.toJson()).toList(),
      'mood': _mood ?? '',
      'audioPaths': _audioPaths,
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: widget.t.goldDeep,
            onPrimary: Colors.white,
            surface: widget.t.panel,
            onSurface: widget.t.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
          _dateText = DateFormat('dd MMMM yyyy', 'tr_TR').format(picked));
      _emit();
    }
  }

  Future<String> _audioDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/audio');
    if (!await d.exists()) await d.create(recursive: true);
    return d.path;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    final dir = await _audioDir();
    final path = '$dir/${const Uuid().v4()}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return;
    final i = _audioPaths.length;
    setState(() {
      _isRecording = false;
      _audioPaths = [..._audioPaths, path];
    });
    _emit();
    await _loadAudio(i);
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final src = result.files.first.path;
    if (src == null) return;
    final dir = await _audioDir();
    final ext = src.split('.').last;
    final dest = '$dir/${const Uuid().v4()}.$ext';
    await File(src).copy(dest);
    final i = _audioPaths.length;
    setState(() => _audioPaths = [..._audioPaths, dest]);
    _emit();
    await _loadAudio(i);
  }

  Future<void> _pickVideoForAudio() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    final dir = await _audioDir();
    final ext = video.path.split('.').last;
    final dest = '$dir/${const Uuid().v4()}.$ext';
    await File(video.path).copy(dest);
    final i = _audioPaths.length;
    setState(() => _audioPaths = [..._audioPaths, dest]);
    _emit();
    await _loadAudio(i);
  }

  void _removeAudio(int i) async {
    await _players[i]?.stop();
    _players[i]?.dispose();
    _players.remove(i);
    _playing.remove(i);
    _positions.remove(i);
    _durations.remove(i);
    setState(() {
      _audioPaths = [..._audioPaths]..removeAt(i);
    });
    _emit();
  }

  void _showAudioSheet() {
    final t = widget.t;
    showModalBottomSheet(
      context: context,
      backgroundColor: t.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: t.line, borderRadius: BorderRadius.circular(9)),
            ),
            Text('Sesli Anı Ekle',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: t.ink)),
            const SizedBox(height: 20),
            _sheetOption(ctx, t,
                icon: Icons.mic,
                label: 'Ses Kaydet',
                sub: 'Mikrofonu kullanarak kayıt yap',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _startRecording();
                }),
            const SizedBox(height: 12),
            _sheetOption(ctx, t,
                icon: Icons.audio_file,
                label: 'Ses Dosyası Seç',
                sub: 'Telefonundaki ses dosyasını ekle',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAudioFile();
                }),
            const SizedBox(height: 12),
            _sheetOption(ctx, t,
                icon: Icons.videocam,
                label: 'Videodan Ses Al',
                sub: 'Video seç, sesi sesli anı olarak kaydet',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickVideoForAudio();
                }),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(BuildContext ctx, AppTheme t,
      {required IconData icon,
      required String label,
      required String sub,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.line),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accent.withOpacity(0.2),
              ),
              child: Icon(icon, color: t.goldDeep, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: t.ink)),
                  Text(sub, style: TextStyle(fontSize: 12, color: t.soft)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.soft, size: 18),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildPlayer(AppTheme t, int i) {
    final p = _playerFor(i);
    final isPlaying = _playing[i] ?? false;
    final pos = _positions[i] ?? Duration.zero;
    final dur = _durations[i] ?? Duration.zero;
    final maxMs = dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1.0;
    final posMs = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: t.accent),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isPlaying) {
                await p.pause();
              } else {
                await p.play(DeviceFileSource(_audioPaths[i]));
              }
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: t.goldDeep),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12),
                  ),
                  child: Slider(
                    value: posMs,
                    max: maxMs,
                    activeColor: t.goldDeep,
                    inactiveColor: t.line,
                    onChanged: (v) =>
                        p.seek(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: TextStyle(fontSize: 10, color: t.soft)),
                      Text(
                        dur.inMilliseconds > 0 ? _fmt(dur) : '--:--',
                        style: TextStyle(fontSize: 10, color: t.soft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeAudio(i),
            child: Icon(Icons.delete_outline, color: t.soft, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(t, 'TARİH'),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: t.panel,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: t.line),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: t.soft),
                const SizedBox(width: 10),
                Text(
                  _dateText.isEmpty ? 'Tarih seç...' : _dateText,
                  style: TextStyle(
                    fontSize: 15,
                    color: _dateText.isEmpty
                        ? t.soft.withOpacity(0.5)
                        : t.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (widget.page.mediaField) ...[
          _label(t, 'FOTOĞRAF / VIDEO ALBÜMÜ'),
          const SizedBox(height: 8),
          AlbumWidget(
            items: _media,
            onChanged: (items) {
              setState(() => _media = items);
              _emit();
            },
            accent: t.accent,
            goldDeep: t.goldDeep,
            panel: t.panel,
            line: t.line,
          ),
          const SizedBox(height: 18),
        ],
        if (widget.page.audio) ...[
          _label(t, 'SESLİ ANILAR'),
          const SizedBox(height: 8),
          if (_isRecording)
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade400,
                      ),
                      child: const Icon(Icons.stop,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kayıt devam ediyor...',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.ink)),
                        Text('Durdurmak için dokun',
                            style: TextStyle(fontSize: 12, color: t.soft)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Mevcut sesler
          ...List.generate(_audioPaths.length, (i) => _buildPlayer(t, i)),
          // Yeni ses ekle butonu
          if (!_isRecording)
            GestureDetector(
              onTap: _showAudioSheet,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.panel,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: _audioPaths.isEmpty ? t.line : t.gold,
                      style: _audioPaths.isEmpty
                          ? BorderStyle.solid
                          : BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.accent.withOpacity(0.2),
                      ),
                      child: Icon(Icons.add, color: t.goldDeep, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _audioPaths.isEmpty
                          ? 'Sesli Anı Ekle'
                          : 'Başka Sesli Anı Ekle',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: t.ink),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: t.soft, size: 18),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
        _label(t, 'ANI'),
        const SizedBox(height: 7),
        TextField(
          controller: _textCtrl,
          onChanged: (_) => _emit(),
          maxLines: 6,
          style: TextStyle(fontSize: 15, color: t.ink, height: 1.6),
          decoration: _inputDec(t, widget.page.hint ?? 'Buraya yaz...'),
        ),
        const SizedBox(height: 18),
        MoodPicker(
          t: t,
          value: _mood,
          onPick: (m) {
            setState(() => _mood = m.isEmpty ? null : m);
            _emit();
          },
        ),
      ],
    );
  }

  Widget _label(AppTheme t, String text) => Text(
        text,
        style: TextStyle(fontSize: 12.5, letterSpacing: 0.8, color: t.soft),
      );

  InputDecoration _inputDec(AppTheme t, String hint) => InputDecoration(
        filled: true,
        fillColor: t.panel,
        hintText: hint,
        hintStyle: TextStyle(color: t.soft.withOpacity(0.5)),
        contentPadding: const EdgeInsets.all(15),
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
}
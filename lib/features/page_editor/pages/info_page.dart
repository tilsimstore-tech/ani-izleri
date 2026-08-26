import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/round_photo.dart';

class InfoPage extends StatefulWidget {
  final AppTheme t;
  final PageDef page;
  final Map<String, dynamic> entry;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const InfoPage({
    super.key,
    required this.t,
    required this.page,
    required this.entry,
    required this.onChanged,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late List<TextEditingController> _controllers;
  late String? _avatar;

  @override
  void initState() {
    super.initState();
    final vals = (widget.entry['vals'] as List?) ?? [];
    _controllers = List.generate(
      widget.page.fields.length,
      (i) => TextEditingController(
          text: vals.length > i ? vals[i]?.toString() ?? '' : ''),
    );
    _avatar = widget.entry['avatar'] as String?;
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged({
      'vals': _controllers.map((c) => c.text).toList(),
      'avatar': _avatar,
    });
  }

  Future<void> _pickDate(int i) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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
      _controllers[i].text =
          DateFormat('dd MMMM yyyy', 'tr_TR').format(picked);
      _emit();
    }
  }

  Future<void> _pickTime(int i) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      _controllers[i].text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.page.avatar)
          Align(
            alignment: Alignment.centerRight,
            child: RoundPhoto(
              t: t,
              value: _avatar,
              onSet: (p) {
                setState(() => _avatar = p);
                _emit();
              },
            ),
          ),
        if (widget.page.avatar) const SizedBox(height: 10),
        ...widget.page.fields.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          final isDate = f.type == 'date';
          final isTime = f.type == 'time';
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 0.8,
                    color: t.soft,
                  ),
                ),
                const SizedBox(height: 7),
                if (isDate || isTime)
                  GestureDetector(
                    onTap: () =>
                        isDate ? _pickDate(i) : _pickTime(i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: t.panel,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: t.line),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDate
                                ? Icons.calendar_today_outlined
                                : Icons.access_time,
                            size: 18,
                            color: t.soft,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _controllers[i].text.isEmpty
                                ? (isDate
                                    ? 'Tarih seç...'
                                    : 'Saat seç...')
                                : _controllers[i].text,
                            style: TextStyle(
                              fontSize: 15,
                              color: _controllers[i].text.isEmpty
                                  ? t.soft.withOpacity(0.5)
                                  : t.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: _controllers[i],
                    onChanged: (_) => _emit(),
                    style: TextStyle(fontSize: 15, color: t.ink),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: t.panel,
                      hintText: 'Buraya yaz...',
                      hintStyle: TextStyle(
                          color: t.soft.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 13),
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
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
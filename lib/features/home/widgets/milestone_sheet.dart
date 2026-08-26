import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/milestones.dart';
import '../../../core/constants/sections.dart';
import '../../../core/theme/app_theme.dart';

void showMilestoneSheet(
  BuildContext context,
  AppTheme t,
  MilestoneDef m,
  bool earned,
  Map<String, Map<String, dynamic>> data,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _MilestoneSheet(t: t, m: m, earned: earned, data: data),
  );
}

class _MilestoneSheet extends StatelessWidget {
  final AppTheme t;
  final MilestoneDef m;
  final bool earned;
  final Map<String, Map<String, dynamic>> data;

  const _MilestoneSheet({
    required this.t,
    required this.m,
    required this.earned,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 14, 24,
        MediaQuery.of(context).padding.bottom + 30,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: t.line, borderRadius: BorderRadius.circular(9)),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: earned
                    ? LinearGradient(
                        colors: [t.accent, t.goldDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: earned ? null : t.line,
                boxShadow: earned
                    ? [BoxShadow(color: t.accent.withOpacity(0.4), blurRadius: 22)]
                    : null,
              ),
              child: Icon(
                earned ? m.icon : Icons.lock_outline,
                size: earned ? 30 : 24,
                color: earned ? Colors.white : t.soft,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              m.label,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: t.ink,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: earned
                    ? t.accent.withOpacity(0.15)
                    : t.line.withOpacity(0.6),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                earned ? '🏅  Kazanıldı!' : '🔒  Henüz kilitli',
                style: TextStyle(
                  fontSize: 13,
                  color: earned ? t.goldDeep : t.soft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: t.line),
            const SizedBox(height: 14),
            if (!earned)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NASIL KAZANILIR?',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: t.soft,
                  ),
                ),
              ),
            if (!earned) const SizedBox(height: 12),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (m.id) {
      case 'ilk':
        final filled = filledUnits(data);
        return _simpleHint(
          Icons.edit_note,
          'Herhangi bir sayfayı doldurmaya başla.',
          sub: filled == 0
              ? 'Henüz hiçbir alan doldurulmadı. İlk sayfayı aç ve yazmaya başla!'
              : 'Tebrikler, zaten başladın! Bu rozet kazanıldı.',
        );

      case 'aile':
        return _sectionProgress(
          'aile',
          target: 0.7,
          desc: 'Aileni Tanı bölümünün %70\'ini tamamla.',
        );

      case 'hamile':
        return _sectionProgress(
          'beklerken',
          target: 0.5,
          desc: 'Seni Beklerken bölümünün yarısını tamamla.',
        );

      case 'dogum':
        final done = (data['dogum-hikaye']?['text']?.toString().trim().isNotEmpty ?? false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _simpleHint(
              Icons.menu_book,
              '"Sana Kavuşunca" bölümündeki Doğum Hikayen sayfasını doldur.',
            ),
            const SizedBox(height: 14),
            _pageRow(
              icon: Icons.menu_book,
              title: 'Doğum Hikayen',
              subtitle: 'Sana Kavuşunca bölümü',
              done: done,
            ),
          ],
        );

      case 'foto':
        return _simpleHint(
          Icons.camera_alt,
          'Herhangi bir sayfaya fotoğraf veya video ekle.',
          sub: 'Hikaye sayfaları, albümler, aylık fotoğraflar veya ultrason sayfalarına medya ekleyebilirsin.',
        );

      case 'yarisi':
        return _overallProgress(0.5);

      case 'tamam':
        return _overallProgress(0.9);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _simpleHint(IconData icon, String text, {String? sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accent.withOpacity(0.15),
              ),
              child: Icon(icon, color: t.goldDeep, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14.5, color: t.ink, height: 1.5),
              ),
            ),
          ],
        ),
        if (sub != null) ...[
          const SizedBox(height: 10),
          Text(
            sub,
            style: TextStyle(fontSize: 12.5, color: t.soft, height: 1.5),
          ),
        ],
      ],
    );
  }

  Widget _pageRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool done,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? t.accent.withOpacity(0.08) : t.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? t.gold : t.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? t.accent.withOpacity(0.2) : t.line,
            ),
            child: Icon(
              done ? Icons.check : icon,
              size: 18,
              color: done ? t.goldDeep : t.soft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: t.ink)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: t.soft)),
              ],
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: done ? t.goldDeep : t.line,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _sectionProgress(String sectionId, {required double target, required String desc}) {
    final section = sections.firstWhere((s) => s.id == sectionId);
    final total = sectionTotal(sectionId);
    final filled = sectionFilled(sectionId, data);
    final needed = (total * target).floor();
    final pct = total > 0 ? (filled / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _simpleHint(Icons.flag_outlined, desc),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              section.title,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: t.ink),
            ),
            Text(
              '$filled / $needed alan',
              style: TextStyle(fontSize: 12, color: t.soft),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: t.line,
            valueColor: AlwaysStoppedAnimation(section.color),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '%${(target * 100).round()} gerekli · şu an %${(pct * 100).round()}',
          style: TextStyle(fontSize: 11.5, color: t.soft),
        ),
        const SizedBox(height: 16),
        ...section.pages.map((p) {
          final e = data[p.id] ?? {};
          final u = entryUnits(p, e);
          final pu = pageUnits(p);
          final done = u >= pu && pu > 0;
          final started = u > 0 && !done;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? section.color.withOpacity(0.18)
                        : started
                            ? t.line.withOpacity(0.7)
                            : t.bg,
                    border: Border.all(
                      color: done ? section.color : t.line,
                    ),
                  ),
                  child: Icon(
                    done
                        ? Icons.check
                        : started
                            ? Icons.edit
                            : Icons.circle_outlined,
                    size: 14,
                    color: done ? section.color : t.soft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: done ? t.ink : t.soft,
                      fontWeight: done ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (pu > 1)
                  Text(
                    '$u/$pu',
                    style: TextStyle(fontSize: 11, color: t.soft),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _overallProgress(double target) {
    final total = kTotalUnits;
    final filled = filledUnits(data);
    final needed = (total * target).floor();
    final pct = total > 0 ? (filled / total).clamp(0.0, 1.0) : 0.0;
    final targetPct = (target * 100).round();
    final remaining = (needed - filled).clamp(0, needed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _simpleHint(
          Icons.auto_awesome,
          'Tüm defteri %$targetPct oranında doldur.',
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Genel İlerleme',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: t.ink),
            ),
            Text(
              '$filled / $needed alan',
              style: TextStyle(fontSize: 12, color: t.soft),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: t.line,
            valueColor: AlwaysStoppedAnimation(t.accent),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          remaining > 0
              ? 'Şu an %${(pct * 100).round()} — $remaining alan daha doldurman yeterli'
              : '🎉 Hedefe ulaştın!',
          style: TextStyle(fontSize: 12.5, color: t.soft, height: 1.4),
        ),
      ],
    );
  }
}

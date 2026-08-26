import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import '../../core/constants/sections.dart';
import '../../data/providers/app_provider.dart';
import '../../data/services/pdf_service.dart';
import '../../widgets/theme_sheet.dart';
import '../../core/extensions/turkish_extensions.dart';
import 'widgets/ani_tree.dart';
import 'widgets/milestone_badges.dart';
import 'widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _backup(BuildContext context) async {
    final prov = context.read<AppProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yedek hazırlanıyor...')),
    );
    final path = await prov.backup();
    if (!context.mounted) return;
    if (path != null) {
      await SharePlus.instance.share(
        ShareParams(
            files: [XFile(path)],
            text: 'Tılsım - Anı İzleri Yedeği'),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Yedekleme başarısız oldu')),
      );
    }
  }

  Future<void> _restore(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Geri yükleniyor...')),
    );
    final prov = context.read<AppProvider>();
    final ok = await prov.restore(path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '✅ Yedek başarıyla geri yüklendi'
            : '❌ Geri yükleme başarısız'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final prov = context.read<AppProvider>();
    final t = prov.theme;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF hazırlanıyor...')),
    );
    final babyEntry = prov.getEntry('bebek');
    final vals = (babyEntry['vals'] as List?) ?? [];
    final babyName = vals.isNotEmpty &&
            vals[0]?.toString().trim().isNotEmpty == true
        ? vals[0].toString().trim()
        : 'Bebeğim';
    final avatarPath = babyEntry['avatar'] as String?;

    final pdfPath = await PdfService.generateAlbum(
      babyName: babyName,
      avatarPath: avatarPath,
      entries: prov.allEntries,
      bgColor: t.bg,
      inkColor: t.ink,
      goldColor: t.gold,
      accentColor: t.accent,
    );

    if (!context.mounted) return;
    if (pdfPath != null) {
      await Printing.sharePdf(
        bytes: await File(pdfPath).readAsBytes(),
        filename: '$babyName - Anı İzleri.pdf',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ PDF oluşturulamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = prov.theme;
    final data = prov.allEntries;
    final total = kTotalUnits;
    final filled = filledUnits(data);
    final pct = total > 0 ? (filled / total * 100).round() : 0;
    final babyEntry = prov.getEntry('bebek');
    final vals = (babyEntry['vals'] as List?) ?? [];
    final babyName =
        vals.isNotEmpty && vals[0]?.toString().trim().isNotEmpty == true
            ? vals[0].toString().trim()
            : 'Bebeğim';
    final avatarPath = babyEntry['avatar'] as String?;

    return Scaffold(
      backgroundColor: t.bg,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'T I L S I M',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 12,
                    letterSpacing: 6,
                    color: t.soft,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ThemeSheet()),
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.panel,
                      border: Border.all(color: t.line),
                    ),
                    child: Icon(Icons.palette,
                        size: 17, color: t.soft),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 6),
            child: Column(
              children: [
                Text(
                  '$babyName${babyName.iyelikEki}',
                  style: GoogleFonts.pinyonScript(
                      fontSize: 26, color: t.gold),
                ),
                Text(
                  'Anı İzleri',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 44),
                child: AniTree(t: t, pct: pct),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.gold, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: t.accent.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarPath != null &&
                          File(avatarPath).existsSync()
                      ? Image.file(File(avatarPath),
                          fit: BoxFit.cover)
                      : Container(
                          color: t.panel,
                          child: Icon(Icons.child_care,
                              size: 36, color: t.soft),
                        ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ANI AĞACIN BÜYÜYOR',
                        style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            color: t.soft)),
                    Text('%$pct',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.goldDeep)),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: t.line,
                    valueColor: AlwaysStoppedAnimation(t.accent),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const MilestoneBadges(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: Text('Bölümler',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: t.ink)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: Column(
              children: sections
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: SectionCard(
                            section: e.value, index: e.key),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generatePdf(context),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF Albüm'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.ink,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _backup(context),
                    icon: const Icon(Icons.backup, size: 16),
                    label: const Text('Yedekle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.ink,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            child: OutlinedButton.icon(
              onPressed: () => _restore(context),
              icon: const Icon(Icons.restore, size: 16),
              label: const Text('Yedeği Geri Yükle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.soft,
                side: BorderSide(color: t.line),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 22, 30, 40),
            child: Text(
              'Tüm anıların yalnızca senin cihazında saklanır.\nTılsım\'ın ışığı her zaman seninle olsun.',
              style: TextStyle(
                fontSize: 11,
                color: t.soft.withOpacity(0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
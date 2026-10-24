import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import '../../core/constants/sections.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/services/pdf_service.dart';
import '../../widgets/theme_sheet.dart';
import '../../core/extensions/turkish_extensions.dart';
import 'widgets/ani_tree.dart';
import 'widgets/milestone_badges.dart';
import 'widgets/section_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeShowWelcome());
  }

  void _maybeShowWelcome() {
    if (!mounted) return;
    final prov = context.read<AppProvider>();
    if (prov.welcomeShown) return;
    prov.markWelcomeShown();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _WelcomeDialog(t: prov.theme),
    );
  }

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
      panelColor: t.panel,
      lineColor: t.line,
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
                    label: Text.rich(
                      TextSpan(
                        text: 'PDF Albüm',
                        children: [
                          TextSpan(
                            text: '  (beta)',
                            style: TextStyle(
                                fontSize: 10, color: t.soft),
                          ),
                        ],
                      ),
                    ),
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

class _WelcomeDialog extends StatelessWidget {
  final AppTheme t;
  const _WelcomeDialog({required this.t});

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.accent.withOpacity(0.16),
            ),
            child: Icon(icon, size: 16, color: t.goldDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    color: t.soft,
                  ),
                ),
                const SizedBox(height: 1),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 30, 26, 22),
        decoration: BoxDecoration(
          color: t.panel,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: t.gold.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 34, height: 0.8, color: t.gold),
            const SizedBox(height: 18),
            Text(
              'Hoş Geldiniz',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: t.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu ürün bir demo ürünüdür ve sizlerin geri '
              'dönüşleriyle daha da iyi hale getirilecektir. '
              'Deneyiminizi bizimle paylaşmanız bizim için çok değerli.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: t.soft,
              ),
            ),
            const SizedBox(height: 22),
            Container(height: 0.6, color: t.line),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BİZE ULAŞIN',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 2.2,
                  color: t.goldDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _contactRow(
              icon: Icons.camera_alt_outlined,
              label: 'INSTAGRAM',
              value: 'tilsimstore.tr',
            ),
            _contactRow(
              icon: Icons.chat_bubble_outline,
              label: 'WHATSAPP',
              value: '0554 720 9689',
            ),
            _contactRow(
              icon: Icons.public,
              label: 'WEB SİTE',
              value: 'tilsim.store',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.goldDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Anladım, Başlayalım'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
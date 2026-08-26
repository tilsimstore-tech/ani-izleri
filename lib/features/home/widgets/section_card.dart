import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/sections.dart';
import '../../../data/providers/app_provider.dart';
import '../../section/section_screen.dart';

IconData _sectionIcon(String icon) {
  switch (icon) {
    case 'users':    return Icons.people;
    case 'baby':     return Icons.child_care;
    case 'heart':    return Icons.favorite;
    case 'footprints': return Icons.follow_the_signs;
    case 'sparkles': return Icons.auto_awesome;
    case 'star':     return Icons.star;
    default:         return Icons.book;
  }
}

class SectionCard extends StatelessWidget {
  final SectionDef section;
  final int index;

  const SectionCard({super.key, required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = prov.theme;
    final data = prov.allEntries;
    final tot = sectionTotal(section.id);
    final fil = sectionFilled(section.id, data);
    final sp = tot > 0 ? (fil / tot * 100).round() : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SectionScreen(section: section)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: t.panel,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: section.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_sectionIcon(section.icon), color: section.color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${section.pages.length} sayfa · %$sp',
                    style: TextStyle(fontSize: 12, color: t.soft),
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: sp / 100,
                      backgroundColor: t.line,
                      valueColor: AlwaysStoppedAnimation(section.color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: t.soft, size: 18),
          ],
        ),
      ),
    );
  }
}

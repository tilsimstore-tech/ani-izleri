import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sections.dart';
import '../../data/providers/app_provider.dart';
import '../page_editor/page_editor_screen.dart';

IconData _kindIcon(String kind) {
  switch (kind) {
    case 'story':    return Icons.menu_book;
    case 'info':     return Icons.person;
    case 'quick':    return Icons.star;
    case 'album':    return Icons.photo_library;
    case 'photo':
    case 'print':    return Icons.camera_alt;
    case 'letter':
    case 'letters':  return Icons.mail;
    case 'monthly':
    case 'monthlyChange': return Icons.photo_camera;
    case 'prediction': return Icons.favorite;
    case 'firstsCollection': return Icons.auto_awesome;
    case 'members':  return Icons.people;
    case 'meaning':  return Icons.menu_book;
    case 'text':     return Icons.book;
    case 'familytree': return Icons.account_tree;
    case 'reactions': return Icons.people;
    case 'memories2': return Icons.favorite;
    case 'ultrasonAll': return Icons.image;
    case 'guestbook': return Icons.people;
    default:         return Icons.book;
  }
}

class SectionScreen extends StatelessWidget {
  final SectionDef section;

  const SectionScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = prov.theme;
    final data = prov.allEntries;

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          // header
          Container(
            color: section.color,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(_iconFor(section.icon), color: Colors.white, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      section.title.split(' ').first,
                      style: GoogleFonts.pinyonScript(
                        fontSize: 30,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    Text(
                      section.title.split(' ').skip(1).join(' ').toUpperCase(),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      section.sub,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // timeline list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
              itemCount: section.pages.length,
              itemBuilder: (context, i) {
                final p = section.pages[i];
                final e = data[p.id] ?? {};
                final u = entryUnits(p, e);
                final total = pageUnits(p);
                final done = u >= total && total > 0;
                final started = u > 0;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // timeline
                      SizedBox(
                        width: 34,
                        child: Column(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? section.color
                                    : started
                                        ? section.color.withOpacity(0.18)
                                        : t.panel,
                                border: Border.all(
                                  color: done ? section.color : t.line,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                done ? Icons.check : _kindIcon(p.kind),
                                size: 15,
                                color: done ? Colors.white : section.color,
                              ),
                            ),
                            if (i < section.pages.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: t.line,
                                  margin: const EdgeInsets.only(left: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageEditorScreen(page: p),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: i < section.pages.length - 1 ? 9 : 0,
                            ),
                            padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                            decoration: BoxDecoration(
                              color: t.panel,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rowTitle(p, e),
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: t.ink,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  done
                                      ? 'Tamamlandı'
                                      : started
                                          ? '$u/$total dolduruldu'
                                          : kindLabel(p.kind),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: t.soft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
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
}

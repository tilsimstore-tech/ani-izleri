import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sections.dart';
import '../../data/providers/app_provider.dart';
import 'pages/album_page.dart';
import 'pages/family_tree_page.dart';
import 'pages/firsts_collection_page.dart';
import 'pages/guestbook_page.dart';
import 'pages/info_page.dart';
import 'pages/letter_page.dart';
import 'pages/letters_page.dart';
import 'pages/meaning_page.dart';
import 'pages/members_page.dart';
import 'pages/memories2_page.dart';
import 'pages/monthly_change_page.dart';
import 'pages/monthly_page.dart';
import 'pages/photo_page.dart';
import 'pages/prediction_page.dart';
import 'pages/quick_page.dart';
import 'pages/reactions_page.dart';
import 'pages/story_page.dart';
import 'pages/text_page.dart';
import 'pages/ultrason_all_page.dart';

class PageEditorScreen extends StatefulWidget {
  final PageDef page;
  const PageEditorScreen({super.key, required this.page});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  late Map<String, dynamic> _local;

  @override
  void initState() {
    super.initState();
    _local = Map<String, dynamic>.from(
      context.read<AppProvider>().getEntry(widget.page.id),
    );
  }

  void _onChanged(Map<String, dynamic> patch) {
    setState(() => _local = {..._local, ...patch});
    context.read<AppProvider>().saveEntry(widget.page.id, _local);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = prov.theme;
    final page = widget.page;
    final isMeaning = page.kind == 'meaning';

    final babyEntry = prov.getEntry('bebek');
    final babyVals = (babyEntry['vals'] as List?) ?? [];
    final babyName = babyVals.isNotEmpty &&
            babyVals[0]?.toString().trim().isNotEmpty == true
        ? babyVals[0].toString().trim()
        : 'Bebeğim';

    final anneEntry = prov.getEntry('anne');
    final anneVals = (anneEntry['vals'] as List?) ?? [];
    final anneName = anneVals.isNotEmpty &&
            anneVals[0]?.toString().trim().isNotEmpty == true
        ? anneVals[0].toString().trim()
        : '';
    final annePhoto = anneEntry['avatar'] as String?;

    final babaEntry = prov.getEntry('baba');
    final babaVals = (babaEntry['vals'] as List?) ?? [];
    final babaName = babaVals.isNotEmpty &&
            babaVals[0]?.toString().trim().isNotEmpty == true
        ? babaVals[0].toString().trim()
        : '';
    final babaPhoto = babaEntry['avatar'] as String?;

    Widget pageWidget;
    switch (page.kind) {
      case 'info':
        pageWidget =
            InfoPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'quick':
        pageWidget =
            QuickPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'members':
        pageWidget =
            MembersPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'meaning':
        pageWidget = MeaningPage(
            t: t, babyName: babyName, entry: _local, onChanged: _onChanged);
        break;
      case 'text':
        pageWidget =
            TextPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'familytree':
        pageWidget = FamilyTreePage(
          t: t,
          babyName: babyName,
          anneName: anneName,
          annePhoto: annePhoto,
          babaName: babaName,
          babaPhoto: babaPhoto,
          entry: _local,
          onChanged: _onChanged,
        );
        break;
      case 'story':
        pageWidget =
            StoryPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'reactions':
        pageWidget =
            ReactionsPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'memories2':
        pageWidget =
            Memories2Page(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'photo':
      case 'print':
        pageWidget =
            PhotoPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'album':
        pageWidget = AlbumPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'monthly':
        pageWidget = MonthlyPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'monthlyChange':
        pageWidget =
            MonthlyChangePage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'ultrasonAll':
        pageWidget =
            UltrasonAllPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'guestbook':
        pageWidget = GuestbookPage(
            t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'letter':
        pageWidget =
            LetterPage(t: t, page: page, entry: _local, onChanged: _onChanged);
        break;
      case 'letters':
        pageWidget = LettersPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'prediction':
        pageWidget =
            PredictionPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      case 'firstsCollection':
        pageWidget =
            FirstsCollectionPage(t: t, entry: _local, onChanged: _onChanged);
        break;
      default:
        pageWidget = Center(
          child: Text('Bilinmeyen sayfa tipi: ${page.kind}',
              style: TextStyle(color: t.soft)),
        );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: GestureDetector(
	behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.panel,
                          border: Border.all(color: t.line),
                        ),
                        child: Icon(Icons.chevron_left,
                            size: 20, color: t.soft),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      page.title.split(' ').first,
                      style: GoogleFonts.pinyonScript(
                          fontSize: 22, color: t.gold),
                    ),
                  ],
                ),
              ),
            ),
            if (!isMeaning)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: t.ink,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 46,
                      height: 2,
                      decoration: BoxDecoration(
                        color: t.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: pageWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
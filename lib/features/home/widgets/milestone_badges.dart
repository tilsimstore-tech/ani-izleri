import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/milestones.dart';
import '../../../data/providers/app_provider.dart';
import 'milestone_sheet.dart';

class MilestoneBadges extends StatelessWidget {
  const MilestoneBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = prov.theme;
    final data = prov.allEntries;
    final earned = milestones.where((m) => m.test(data)).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
          child: Text(
            'Kilometre Taşların',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: t.ink,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: milestones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = milestones[i];
              final got = earned.any((e) => e.id == m.id);
              return GestureDetector(
                onTap: () => showMilestoneSheet(context, t, m, got, data),
                child: Opacity(
                  opacity: got ? 1.0 : 0.42,
                  child: SizedBox(
                    width: 74,
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: got
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [t.accent, t.goldDeep],
                                  )
                                : null,
                            color: got ? null : t.line,
                            border: got
                                ? null
                                : Border.all(
                                    color: t.soft.withOpacity(0.33),
                                    style: BorderStyle.solid,
                                  ),
                            boxShadow: got
                                ? [
                                    BoxShadow(
                                      color: t.accent.withOpacity(0.4),
                                      blurRadius: 16,
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            got ? m.icon : Icons.lock,
                            size: got ? 22 : 16,
                            color: got ? Colors.white : t.soft,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: t.soft,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

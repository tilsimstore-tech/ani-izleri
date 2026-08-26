import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/app_provider.dart';
import '../home/home_screen.dart';
import '../../widgets/baby_footprints.dart';

class CoverScreen extends StatelessWidget {
  const CoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().theme;
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
      child: Scaffold(
        backgroundColor: t.bg,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 1.2,
              colors: [t.panel, t.bg],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bebeğimin',
                  style: GoogleFonts.pinyonScript(fontSize: 30, color: t.gold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Anı',
                      style: GoogleFonts.pinyonScript(
                          fontSize: 64, color: t.goldDeep, height: 1),
                    ),
                    const SizedBox(width: 10),
                    BabyFootprints(color: t.soft, size: 34),
                  ],
                ),
                Text(
                  'İzleri',
                  style: GoogleFonts.pinyonScript(
                      fontSize: 50, color: t.goldDeep, height: 1.1),
                ),
                const SizedBox(height: 54),
                Text(
                  'T I L S I M',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15,
                    letterSpacing: 8,
                    color: t.soft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: t.soft.withOpacity(0.7), size: 11),
                    const SizedBox(width: 7),
                    Text(
                      'DEFTERİ AÇMAK İÇİN DOKUN',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: t.soft.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

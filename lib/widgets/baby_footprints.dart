// lib/widgets/baby_footprints.dart
//
// İki minik ayak izini kendi çizen widget (ikon paketine bağımlı değil).
// Kapakta "Anı" yazısının yanında, prototiptekine benzer görünür.
//
// Kullanım:
//   BabyFootprints(color: theme.soft, size: 30)
import 'package:flutter/material.dart';

class BabyFootprints extends StatelessWidget {
  final Color color;
  final double size;
  const BabyFootprints({super.key, required this.color, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.20, // hafif eğik dursun
      child: CustomPaint(
        size: Size(size, size),
        painter: _FootprintsPainter(color),
      ),
    );
  }
}

class _FootprintsPainter extends CustomPainter {
  final Color color;
  _FootprintsPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final unit = s.width / 30; // ölçek

    // tek bir ayak izi çizen yardımcı
    void foot(double dx, double dy, double scale) {
      canvas.save();
      canvas.translate(dx, dy);
      canvas.scale(scale);

      // topuk + taban (oval)
      final heel = Rect.fromCenter(
        center: Offset(0, 6 * unit),
        width: 9 * unit,
        height: 13 * unit,
      );
      canvas.drawOval(heel, p);

      // 5 parmak (küçükten büyüğe), tabanın üst kısmında yay şeklinde
      final toes = <List<double>>[
        [-4.2 * unit, -2.4 * unit, 1.5 * unit],
        [-2.2 * unit, -3.8 * unit, 1.7 * unit],
        [0.0 * unit, -4.3 * unit, 1.9 * unit],
        [2.2 * unit, -3.6 * unit, 1.7 * unit],
        [4.0 * unit, -2.0 * unit, 1.4 * unit],
      ];
      for (final t in toes) {
        canvas.drawCircle(Offset(t[0], t[1]), t[2], p);
      }
      canvas.restore();
    }

    // iki ayak: biri biraz yukarıda/solda, diğeri aşağıda/sağda
    foot(s.width * 0.34, s.height * 0.30, 0.85);
    foot(s.width * 0.66, s.height * 0.62, 0.85);
  }

  @override
  bool shouldRepaint(covariant _FootprintsPainter old) => old.color != color;
}
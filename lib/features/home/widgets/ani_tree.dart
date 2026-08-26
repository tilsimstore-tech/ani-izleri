import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AniTree extends StatelessWidget {
  final AppTheme t;
  final int pct;

  const AniTree({super.key, required this.t, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(220, 210),
        painter: _TreePainter(t: t, pct: pct),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final AppTheme t;
  final int pct;

  static const _blossoms = [
    [88.0, 70.0], [120.0, 52.0], [150.0, 74.0], [70.0, 100.0],
    [104.0, 92.0], [136.0, 96.0], [168.0, 100.0], [60.0, 130.0],
    [96.0, 124.0], [128.0, 120.0], [160.0, 126.0], [184.0, 132.0],
    [78.0, 158.0], [112.0, 150.0], [146.0, 152.0], [176.0, 158.0],
    [50.0, 158.0],
  ];

  _TreePainter({required this.t, required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final show = ((pct / 100) * _blossoms.length).round();

    // shadow
    final shadowPaint = Paint()
      ..color = t.line.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(115, 196), width: 124, height: 18),
      shadowPaint,
    );

    final trunkPaint = Paint()
      ..color = t.soft
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // trunk
    canvas.drawLine(const Offset(115, 196), const Offset(115, 120), trunkPaint);

    // branches
    final branchPaint = Paint()
      ..color = t.soft
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    branchPaint.strokeWidth = 5;
    _drawPath(canvas, branchPaint, [
      Offset(115, 150), Offset(100, 140), Offset(86, 128), Offset(74, 112)
    ]);
    _drawPath(canvas, branchPaint, [
      Offset(115, 142), Offset(132, 132), Offset(150, 120), Offset(162, 104)
    ]);

    branchPaint.strokeWidth = 4.5;
    _drawPath(canvas, branchPaint, [
      Offset(115, 128), Offset(108, 116), Offset(104, 100), Offset(106, 84)
    ]);

    branchPaint.strokeWidth = 4;
    _drawPath(canvas, branchPaint, [
      Offset(115, 122), Offset(128, 112), Offset(140, 96), Offset(142, 80)
    ]);

    // blossoms
    for (int i = 0; i < _blossoms.length; i++) {
      if (i >= show) continue;
      final x = _blossoms[i][0];
      final y = _blossoms[i][1];

      final petalPaint = Paint()
        ..color = t.accent.withOpacity(0.92)
        ..style = PaintingStyle.fill;

      for (int a = 0; a < 5; a++) {
        final angle = a * 72.0 * 3.14159 / 180.0;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, -5), width: 6.8, height: 12),
          petalPaint,
        );
        canvas.restore();
      }

      canvas.drawCircle(
        Offset(x, y),
        2.6,
        Paint()..color = t.goldDeep,
      );
    }
  }

  void _drawPath(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.pct != pct || old.t.key != t.key;
}

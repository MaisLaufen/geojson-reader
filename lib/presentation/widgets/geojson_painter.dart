import 'package:flutter/material.dart';

class GeoJsonPainter extends CustomPainter {
  final List<List<Offset>> polygons;
  final List<Color> colors;

  GeoJsonPainter(this.polygons, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < polygons.length; i++) {
      final path = Path()..moveTo(polygons[i].first.dx, polygons[i].first.dy);
      for (var point in polygons[i].skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();

      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'package:flutter/material.dart';

class GeoJsonPainter extends CustomPainter {
  final List<List<Offset>> polygons;
  final List<List<Offset>> lines;
  final List<List<Offset>> points;
  final List<Color> colors;

  GeoJsonPainter(this.polygons, this.lines, this.points, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // Отрисовываем полигоны
    for (int i = 0; i < polygons.length; i++) {
      final path = Path()..moveTo(polygons[i].first.dx, polygons[i].first.dy);
      for (var point in polygons[i].skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();

      final paint = Paint()
        ..color = colors[i].withAlpha(122)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }

    // Отрисовываем линии
    for (int i = 0; i < lines.length; i++) {
      final path = Path();
      path.moveTo(lines[i].first.dx, lines[i].first.dy);
      for (var point in lines[i].skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      final paint = Paint()
        ..color = colors[i].withAlpha(200)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);
    }

    // Отрисовываем точки
    for (int i = 0; i < points.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i].first, 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
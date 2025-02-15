import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';

class MapDrawer extends CustomPainter {
  final List<GeoJsonLayer> layers;
  final double scale;
  final Offset position;

  MapDrawer({
    required this.layers,
    required this.scale,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint polygonPaint = Paint()
      ..color = const Color.fromARGB(255, 47, 137, 255).withAlpha(50)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (var layer in layers) {
      if (layer.isVisible) {
      for (var polygon in layer.polygons) {
        final path = Path();
        for (int i = 0; i < polygon.length; i++) {
          final transformedPoint = (polygon[i] * scale) + position;
          if (i == 0) {
            path.moveTo(transformedPoint.dx, transformedPoint.dy);
          } else {
            path.lineTo(transformedPoint.dx, transformedPoint.dy);
          }
        }
        path.close();
        canvas.drawPath(path, polygonPaint);
      }

      for (var line in layer.lines) {
        for (int i = 0; i < line.length - 1; i++) {
          final start = (line[i] * scale) + position;
          final end = (line[i + 1] * scale) + position;
          canvas.drawLine(start, end, linePaint);
        }
      }

      for (var point in layer.points) {
        final transformedPoint = (point * scale) + position;
        canvas.drawCircle(transformedPoint, 2.0, pointPaint);
      }
    }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

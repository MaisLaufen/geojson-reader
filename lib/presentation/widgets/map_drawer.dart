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
    // Сортируем слои в порядке убывания индекса (чтобы верхние рисовались последними)
    List<GeoJsonLayer> sortedLayers = List.from(layers);
    sortedLayers.sort((a, b) => b.index.compareTo(a.index)); // Изменено: теперь по убыванию

    final Paint polygonPaint = Paint()
      ..color = const Color.fromARGB(153, 64, 142, 210)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = const Color(0xFFFFC740)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint pointPaint = Paint()
      ..color = const Color(0xFFF60018)
      ..style = PaintingStyle.fill;

    for (var layer in sortedLayers) {
      if (layer.isVisible) {
        // Отрисовка полигонов
        for (var polygon in layer.polygons) {
          final path = Path();
          for (int i = 0; i < polygon.coordinates.length; i++) {
            final transformedPoint = (polygon.coordinates[i] * scale) + position;
            if (i == 0) {
              path.moveTo(transformedPoint.dx, transformedPoint.dy);
            } else {
              path.lineTo(transformedPoint.dx, transformedPoint.dy);
            }
          }
          path.close();
          canvas.drawPath(path, polygonPaint);
        }

        // Отрисовка линий
        for (var line in layer.lines) {
          for (int i = 0; i < line.coordinates.length - 1; i++) {
            final start = (line.coordinates[i] * scale) + position;
            final end = (line.coordinates[i + 1] * scale) + position;
            canvas.drawLine(start, end, linePaint);
          }
        }

        // Отрисовка точек
        for (var point in layer.points) {
          final transformedPoint = (point.coordinates * scale) + position;
          canvas.drawCircle(transformedPoint, 2.0, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
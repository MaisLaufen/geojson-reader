import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/entities/map_object.dart';

class MapDrawer extends CustomPainter {
  final List<GeoJsonLayer> layers;
  final Set<MapObject> selectedObjects;
  final double scale;
  final Offset position;

  MapDrawer({
    required this.layers,
    required this.selectedObjects,
    required this.scale,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    List<GeoJsonLayer> sortedLayers = List.from(layers);
    sortedLayers.sort((a, b) => b.index.compareTo(a.index));

    final Paint polygonPaint = Paint()
      ..color = const Color.fromARGB(153, 64, 142, 210)
      ..style = PaintingStyle.fill;

    final Paint selectedPolygonPaint = Paint()
      ..color = const Color.fromARGB(153, 255, 0, 0) // 🔥 Красный для выделенных
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = const Color(0xFFFFC740)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint selectedLinePaint = Paint()
      ..color = const Color(0xFF00FF00) // 🔥 Зеленый для выделенных линий
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Paint pointPaint = Paint()
      ..color = const Color(0xFFF60018)
      ..style = PaintingStyle.fill;
    
    final Paint selectedPointPaint = Paint()
      ..color = const Color(0xFFFF00FF) // 🔥 Фиолетовый для выделенных точек
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

          // Проверяем, выделен ли этот объект
          bool isSelected = selectedObjects.any((obj) => obj.data == polygon);
          canvas.drawPath(path, isSelected ? selectedPolygonPaint : polygonPaint);
        }

        for (var line in layer.lines) {
          for (int i = 0; i < line.coordinates.length - 1; i++) {
            final start = (line.coordinates[i] * scale) + position;
            final end = (line.coordinates[i + 1] * scale) + position;

            bool isSelected = selectedObjects.any((obj) => obj.data == line);
            canvas.drawLine(start, end, isSelected ? selectedLinePaint : linePaint);
          }
        }

        for (var point in layer.points) {
          final transformedPoint = (point.coordinates * scale) + position;
          bool isSelected = selectedObjects.any((obj) => obj.data == point);
          canvas.drawCircle(transformedPoint, 4.0, isSelected ? selectedPointPaint : pointPaint);
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
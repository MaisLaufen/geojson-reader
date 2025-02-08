import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GeoJsonMapView extends StatefulWidget {
  final List<List<Offset>> polygons;
  final List<List<Offset>> lines;
  final List<Offset> points;

  const GeoJsonMapView({
    super.key,
    required this.polygons,
    required this.lines,
    required this.points,
  });

  @override
  GeoJsonMapViewState createState() => GeoJsonMapViewState();
}

class GeoJsonMapViewState extends State<GeoJsonMapView> {
  double scale = 1.0;
  Offset position = Offset.zero;
  String? selectedFeature;

  void _onScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1; // Уменьшение или увеличение
        scale = (scale * zoomFactor).clamp(0.5, 5.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onScroll, // Обработка колесика мыши
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            position += details.focalPointDelta;
          });
        },
         onTapDown: (TapDownDetails details) {
          Offset tapPosition = (details.localPosition - position) / scale;
          _detectFeatureAt(tapPosition);
  },
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(1000, 1000),
              painter: GeoJsonPainter(
                polygons: widget.polygons,
                lines: widget.lines,
                points: widget.points,
                scale: scale,
                position: position,
              ),
            ),
            if (selectedFeature != null)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white.withOpacity(0.8),
                  child: Text(selectedFeature!, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _detectFeatureAt(Offset tapPosition) {
  const double tapTolerance = 10.0;
  String? feature;

  for (var polygon in widget.polygons) {
    if (_isPointInsidePolygon(tapPosition, polygon)) {
      feature = "Polygon";
      break;
    }
  }

  if (feature == null) {
    for (var line in widget.lines) {
      for (int i = 0; i < line.length - 1; i++) {
        if (_isPointNearLine(tapPosition, line[i], line[i + 1], tapTolerance)) {
          feature = "Line";
          break;
        }
      }
      if (feature != null) break;
    }
  }

  if (feature == null) {
    for (var point in widget.points) {
      if ((tapPosition - point).distance < tapTolerance) {
        feature = "Point";
        break;
      }
    }
  }

  setState(() => selectedFeature = feature);
}

  bool _isPointInsidePolygon(Offset point, List<Offset> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy) &&
          point.dx < (polygon[j].dx - polygon[i].dx) * (point.dy - polygon[i].dy) /
              (polygon[j].dy - polygon[i].dy) + polygon[i].dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool _isPointNearLine(Offset point, Offset start, Offset end, double tolerance) {
    double lengthSquared = (end - start).distanceSquared;
    if (lengthSquared == 0) return (point - start).distance < tolerance;

    double t = ((point - start).dx * (end - start).dx + (point - start).dy * (end - start).dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);

    Offset projection = Offset(start.dx + t * (end.dx - start.dx), start.dy + t * (end.dy - start.dy));
    return (point - projection).distance < tolerance;
  }
}

class GeoJsonPainter extends CustomPainter {
  final List<List<Offset>> polygons;
  final List<List<Offset>> lines;
  final List<Offset> points; // Исправлено
  final double scale;
  final Offset position;

  GeoJsonPainter({
    required this.polygons,
    required this.lines,
    required this.points,
    required this.scale,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint polygonPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 243, 131).withAlpha(50)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (var polygon in polygons) {
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

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        final start = (line[i] * scale) + position;
        final end = (line[i + 1] * scale) + position;
        canvas.drawLine(start, end, linePaint);
      }
    }

    for (var point in points) { // Исправлено
      final transformedPoint = (point * scale) + position;
      canvas.drawCircle(transformedPoint, 5.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
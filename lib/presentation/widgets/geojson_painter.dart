import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/entities/map_object.dart';
import 'package:geoapp/presentation/dialogs/feature_dialog.dart';

class GeoJsonMapView extends StatefulWidget {
  final List<GeoJsonLayer> layers;

  const GeoJsonMapView({
    super.key,
    required this.layers,
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
        double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
        scale = (scale * zoomFactor).clamp(0.001, 100.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onScroll,
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
                layers: widget.layers,
                scale: scale,
                position: position,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureDialog(MapObject mapObject) {
    showDialog(
      context: context,
      builder: (context) => FeatureDialog(mapObject: mapObject),
    );
  }

  void _detectFeatureAt(Offset tapPosition) {
    const double tapTolerance = 10.0;
    MapObject? mapObject;

    for (var layer in widget.layers) {
      for (var polygon in layer.polygons) {
        if (_isPointInsidePolygon(tapPosition, polygon)) {
          mapObject = MapObject(type: "Polygon", data: polygon);
          break;
        }
      }

      if (mapObject == null) {
        for (var line in layer.lines) {
          for (int i = 0; i < line.length - 1; i++) {
            if (_isPointNearLine(tapPosition, line[i], line[i + 1], tapTolerance)) {
              mapObject = MapObject(type: "LineString", data: line);
              break;
            }
          }
          if (mapObject != null) break;
        }
      }

      if (mapObject == null) {
        for (var point in layer.points) {
          if ((tapPosition - point).distance < tapTolerance) {
            mapObject = MapObject(type: "Point", data: point);
            break;
          }
        }
      }

      if (mapObject != null) {
        _showFeatureDialog(mapObject);
        break;
      }
    }
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
  final List<GeoJsonLayer> layers;
  final double scale;
  final Offset position;

  GeoJsonPainter({
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
        canvas.drawCircle(transformedPoint, 5.0, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

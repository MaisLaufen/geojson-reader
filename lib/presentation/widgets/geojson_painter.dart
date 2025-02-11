import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/entities/map_object.dart';
import 'package:geoapp/presentation/dialogs/feature_dialog.dart';

import 'map_drawer.dart';

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
  double scale = 2.0;
  Offset position = Offset(-1000, -1000);
  Offset? cursorPosition;

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
    return Column(
      children: [
        Expanded(
          child: Listener(
            onPointerSignal: _onScroll,
            onPointerHover: (event) {
              setState(() {
                cursorPosition = event.localPosition;
              });
            },
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
                    size: Size.infinite,
                    painter: MapDrawer(
                      layers: widget.layers,
                      scale: scale,
                      position: position,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
Container(
        width: double.infinity,
        color: Colors.black54,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Scale: ${scale.toStringAsFixed(2)} | ${cursorPosition != null
              ? 'Lat: ${cursorPosition!.dx.toStringAsFixed(1)}, Lon: ${cursorPosition!.dy.toStringAsFixed(1)}'
              : 'Cursor: N/A'}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      ],
    );
  }

  GeoCoordinates pixelToGeo(Offset pixel, Size size) {
  double longitude = (pixel.dx - size.width / 2) + 0.0;
  double latitude = 0.0 - (pixel.dy - size.height / 2);
  return GeoCoordinates(latitude, longitude);
}

  void _showFeatureDialog(MapObject mapObject) {
    showDialog(
      context: context,
      builder: (context) => FeatureDialog(mapObject: mapObject),
    );
  }

  void _detectFeatureAt(Offset tapPosition) {
    const double tapTolerance = 2;
    MapObject? mapObject;

    for (var layer in widget.layers.where((layer) => layer.isVisible)) {
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
                  (polygon[j].dy - polygon[i].dy) +
              polygon[i].dx) {
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
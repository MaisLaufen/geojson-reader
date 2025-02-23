import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/entities/map_object.dart';
import 'package:geoapp/presentation/dialogs/feature_dialog.dart';

class GeoJsonMapViewModel extends ChangeNotifier {
  final List<GeoJsonLayer> layers;
  double scale = 3.0;
  Offset position = const Offset(400, 400);
  final ValueNotifier<Offset?> cursorPositionNotifier = ValueNotifier(null);

  final Set<MapObject> selectedObjects = {};

  GeoJsonMapViewModel(this.layers);

void toggleFeatureSelection(MapObject mapObject) {
  if (!selectedObjects.remove(mapObject)) {
    selectedObjects.add(mapObject);
  }
  notifyListeners();
}

    void clearSelection() {
    selectedObjects.clear();
    notifyListeners();
  }

void onScroll(double scrollDelta, Offset cursorPosition) {
    double zoomFactor = scrollDelta > 0 ? 0.9 : 1.1;
    double newScale = (scale * zoomFactor);

    // Вычисляем сдвиг
    double dx = cursorPosition.dx - position.dx;
    double dy = cursorPosition.dy - position.dy;

    // Обновляем позицию карты с учетом масштаба
    position = Offset(
      cursorPosition.dx - dx * newScale / scale,
      cursorPosition.dy - dy * newScale / scale,
    );

    scale = newScale;
  }

  void updateCursorPosition(Offset newPosition) {
    cursorPositionNotifier.value = newPosition;
  }

  void updatePosition(Offset delta) {
    position += delta;
  }

void detectFeatureAt(Offset tapPosition, BuildContext context) {
  double tapTolerance = 4 / scale;
  Offset relativePosition = (tapPosition - position) / scale;
  MapObject? detectedObject;

  for (var layer in layers.where((layer) => layer.isVisible)) {
    if (detectedObject == null) {
      for (var point in layer.points) {
        if ((relativePosition - point.coordinates).distance < tapTolerance) {
          detectedObject = MapObject(type: "Point", data: point);
          break;
        }
      }
    }

    if (detectedObject == null) {
      for (var line in layer.lines) {
        for (int i = 0; i < line.coordinates.length - 1; i++) {
          if (_isPointNearLine(relativePosition, line.coordinates[i], line.coordinates[i + 1], tapTolerance)) {
            detectedObject = MapObject(type: "LineString", data: line);
            break;
          }
        }
        if (detectedObject != null) break;
      }
    }

    if (detectedObject == null) {
      for (var polygon in layer.polygons) {
        if (_isPointInsidePolygon(relativePosition, polygon.coordinates)) {
          detectedObject = MapObject(type: "Polygon", data: polygon);
          break;
        }
      }
    }

    if (detectedObject != null) {
      // Проверяем, есть ли уже этот объект в selectedObjects
      var existingObject = selectedObjects.lookup(detectedObject) ?? detectedObject;
      toggleFeatureSelection(existingObject);
      break;
    }
  }
}

  void _showFeatureDialog(BuildContext context, MapObject mapObject) {
    showDialog(
      context: context,
      builder: (context) => FeatureDialog(mapObject: mapObject),
    );
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
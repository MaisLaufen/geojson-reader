import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/entities/map_line.dart';
import 'package:geoapp/domain/entities/map_object.dart';
import 'package:geoapp/domain/entities/map_point.dart';
import 'package:geoapp/domain/entities/map_polygon.dart';
//import 'package:geoapp/presentation/dialogs/feature_dialog.dart';

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

void selectIntersectingFeatures() {
  Set<MapObject> newSelections = {};

  for (var layer in layers.where((layer) => layer.isVisible)) {
    for (var selectedObject in selectedObjects) {
      var selectedData = selectedObject.data;

      for (var point in layer.points) {
        if (_objectsIntersect(selectedData, point)) {
          newSelections.add(MapObject(type: "Point", data: point));
        }
      }

      for (var line in layer.lines) {
        if (_objectsIntersect(selectedData, line)) {
          newSelections.add(MapObject(type: "LineString", data: line));
        }
      }

      for (var polygon in layer.polygons) {
        if (_objectsIntersect(selectedData, polygon)) {
          newSelections.add(MapObject(type: "Polygon", data: polygon));
        }
      }
    }
  }

  selectedObjects.addAll(newSelections);
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

  // void _showFeatureDialog(BuildContext context, MapObject mapObject) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => FeatureDialog(mapObject: mapObject),
  //   );
  // }

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


// Для выбора пересечений

bool _objectsIntersect(dynamic obj1, dynamic obj2) {
  if (obj1 is MapPoint && obj2 is MapPoint) {
    return obj1.coordinates == obj2.coordinates;
  }
  
  if (obj1 is MapLine && obj2 is MapLine) {
    return _linesIntersect(obj1.coordinates, obj2.coordinates);
  }
  
  if (obj1 is MapPolygon && obj2 is MapPolygon) {
    return _polygonsIntersect(obj1.coordinates, obj2.coordinates);
  }
  
  if (obj1 is MapPoint && obj2 is MapLine || obj2 is MapPoint && obj1 is MapLine) {
    var point = obj1 is MapPoint ? obj1.coordinates : obj2.coordinates;
    var line = obj1 is MapLine ? obj1.coordinates : obj2.coordinates;
    return _isPointNearLineSelect(point, line, 1e-6);
  }
  
if (obj1 is MapPoint && obj2 is MapPolygon || obj2 is MapPoint && obj1 is MapPolygon) {
  var point = obj1 is MapPoint ? obj1.coordinates : obj2.coordinates;
  var polygon = obj1 is MapPolygon ? obj1.coordinates : obj2.coordinates; // Здесь исправлено
  return _isPointInsidePolygonSelect(point, polygon);
}
  
  return false;
}

bool _linesIntersect(List<Offset> line1, List<Offset> line2) {
  for (int i = 0; i < line1.length - 1; i++) {
    for (int j = 0; j < line2.length - 1; j++) {
      if (_segmentsIntersect(line1[i], line1[i + 1], line2[j], line2[j + 1])) {
        return true;
      }
    }
  }
  return false;
}

bool _segmentsIntersect(Offset a, Offset b, Offset c, Offset d) {
  double det = (b.dx - a.dx) * (d.dy - c.dy) - (b.dy - a.dy) * (d.dx - c.dx);
  if (det == 0) return false;

  double t = ((c.dx - a.dx) * (d.dy - c.dy) - (c.dy - a.dy) * (d.dx - c.dx)) / det;
  double u = ((c.dx - a.dx) * (b.dy - a.dy) - (c.dy - a.dy) * (b.dx - a.dx)) / det;

  return (t >= 0 && t <= 1 && u >= 0 && u <= 1);
}

bool _polygonsIntersect(List<Offset> poly1, List<Offset> poly2) {
  for (var point in poly1) {
    if (_isPointInsidePolygonSelect(point, poly2)) return true;
  }
  for (var point in poly2) {
    if (_isPointInsidePolygonSelect(point, poly1)) return true;
  }

  for (int i = 0; i < poly1.length - 1; i++) {
    for (int j = 0; j < poly2.length - 1; j++) {
      if (_segmentsIntersect(poly1[i], poly1[i + 1], poly2[j], poly2[j + 1])) {
        return true;
      }
    }
  }
  return false;
}

bool _isPointNearLineSelect(Offset point, List<Offset> line, double tolerance) {
  for (int i = 0; i < line.length - 1; i++) {
    if (_pointSegmentDistance(point, line[i], line[i + 1]) < tolerance) {
      return true;
    }
  }
  return false;
}

double _pointSegmentDistance(Offset p, Offset a, Offset b) {
  double lengthSquared = (b - a).distanceSquared;
  if (lengthSquared == 0) return (p - a).distance;

  double t = ((p - a).dx * (b - a).dx + (p - a).dy * (b - a).dy) / lengthSquared;
  t = t.clamp(0.0, 1.0);

  Offset projection = Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy));
  return (p - projection).distance;
}

bool _isPointInsidePolygonSelect(Offset point, List<Offset> polygon) {
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
}
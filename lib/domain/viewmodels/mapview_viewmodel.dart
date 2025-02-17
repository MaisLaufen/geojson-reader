import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/data/models/geofeature.dart';
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geomultilinestring.dart';
import 'package:geoapp/data/models/geomultipolygon.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/data/models/point.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/utils/geojson_loader.dart';
import 'package:geoapp/presentation/dialogs/rename_layer_dialog.dart';

class GeoJsonViewModel extends ChangeNotifier {
  List<GeoJsonLayer> layers = [];

  double centerLon = 0.0, centerLat = 0.0;
  double maxDelta = 1.0;

  final double worldCenterLon = 0.0;
  final double worldCenterLat = 0.0;

  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  Future<void> addLayer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['geojson']);
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      if (!filePath.endsWith('.geojson')) {
        errorMessage.value = "Выбранный файл не является GeoJSON.";
        return;
      }
      await loadGeoJson(filePath);
    }
  }

  Future<void> loadGeoJson(String filePath) async {
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);
    int lastSlashIndex = filePath.lastIndexOf("\\");
    String fileNameWithExtension = filePath.substring(lastSlashIndex + 1);
    String fileName = fileNameWithExtension.split('.').first;
    int index = layers.length;
    var layer = _convertGeoJsonToLayer(geoJsonData.features, index, fileName);
    layers.add(layer);
    _updateGlobalCenter(layer);
    notifyListeners();
  }

  void removeLayer(int index) {
    if (index >= 0 && index < layers.length) {
      layers.removeAt(index);
      notifyListeners();
    }
  }

  void toggleLayerVisibility(int index) {
    if (index >= 0 && index < layers.length) {
      layers[index].isVisible = !layers[index].isVisible;
      notifyListeners();
    }
  }

  Future<void> renameLayer(BuildContext context, int index) async {
    if (index >= 0 && index < layers.length) {
      String? newName = await showRenameDialog(context, layers[index].name);
      if (newName != null && newName.isNotEmpty) {
        layers[index].name = newName;
        notifyListeners();
      }
    }
  }
  void moveLayerUp(int index) {
    if (index > 0) {
      GeoJsonLayer layer = layers.removeAt(index);
      layers.insert(index - 1, layer);
      notifyListeners();
    }
  }

  void moveLayerDown(int index) {
    if (index < layers.length - 1) {
      GeoJsonLayer layer = layers.removeAt(index);
      layers.insert(index + 1, layer);
      notifyListeners();
    }
  }

  bool isTopLayer(int index) {
    return index == 0;
  }

  bool isBottomLayer(int index) {
    return index == layers.length - 1;
  }

  GeoJsonLayer _convertGeoJsonToLayer(List<GeoFeature> features, int index, String name) {
    List<List<Offset>> polygons = [];
    List<List<Offset>> lines = [];
    List<Offset> points = [];
    List<GeoCoordinates> allCoordinates = [];

    for (var feature in features) {
      var geometry = feature.geometry;
      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          polygons.add(_convertToPixels(ring));
          allCoordinates.addAll(ring);
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            polygons.add(_convertToPixels(ring));
            allCoordinates.addAll(ring);
          }
        }
      } else if (geometry is GeoLineString) {
        lines.add(_convertToPixels(geometry.points));
        allCoordinates.addAll(geometry.points);
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          lines.add(_convertToPixels(line.points));
          allCoordinates.addAll(line.points);
        }
      } else if (geometry is GeoPoint) {
        points.add(geoToPixel(geometry.coordinates));
        allCoordinates.add(geometry.coordinates);
      }
    }

    if (allCoordinates.isEmpty) return GeoJsonLayer(polygons: polygons, lines: lines, points: points, centerLon: 0, centerLat: 0, maxDelta: 1, index: index, name: name);

    double tempCenterLon = allCoordinates.map((c) => c.longitude).reduce((a, b) => a + b) / allCoordinates.length;
    double tempCenterLat = allCoordinates.map((c) => c.latitude).reduce((a, b) => a + b) / allCoordinates.length;
    double tempMaxDelta = allCoordinates.map((c) => (c.longitude - tempCenterLon).abs().clamp(0.0, (c.latitude - tempCenterLat).abs())).reduce((a, b) => a > b ? a : b);
    if (tempMaxDelta == 0) tempMaxDelta = 1.0;

    return GeoJsonLayer(
      polygons: polygons,
      lines: lines,
      points: points,
      centerLon: tempCenterLon,
      centerLat: tempCenterLat,
      maxDelta: tempMaxDelta,
      index: index,
      name: name,
    );
  }

  List<Offset> _convertToPixels(List<GeoCoordinates> coordinates) {
    return coordinates.map((c) => geoToPixel(c)).toList();
  }

  Offset geoToPixel(GeoCoordinates coord) {
    double x = (coord.longitude - worldCenterLon);
    double y = (worldCenterLat - coord.latitude);
    return Offset(x, y);
  }

  void _updateGlobalCenter(GeoJsonLayer layer) {
    centerLon = layer.centerLon;
    centerLat = layer.centerLat;
    maxDelta = layer.maxDelta;
  }
}

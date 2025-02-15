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

class GeoJsonViewModel extends ChangeNotifier {
  List<GeoJsonLayer> layers = [];

  double centerLon = 0.0, centerLat = 0.0;
  double maxDelta = 1.0;

  final double worldCenterLon = 0.0;
  final double worldCenterLat = 0.0;

  Future<void> addLayer(BuildContext context, Size size) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['geojson']);
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      if (!filePath.endsWith('.geojson')) {
        _showErrorDialog(context, "Выбранный файл не является GeoJSON.");
        return;
      }
      await loadGeoJson(filePath, size);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ошибка"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("ОК"))
        ],
      ),
    );
  }

  Future<void> loadGeoJson(String filePath, Size size) async {
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);
    int lastSlashIndex = filePath.lastIndexOf('/');
    String fileNameWithExtension = filePath.substring(lastSlashIndex + 1);
    String fileName = fileNameWithExtension.split('.').first;
    int index = layers.length;
    var layer = _convertGeoJsonToLayer(geoJsonData.features, size, index, fileName);
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

  GeoJsonLayer _convertGeoJsonToLayer(List<GeoFeature> features, Size size, int index, String name) {
    List<List<Offset>> polygons = [];
    List<List<Offset>> lines = [];
    List<Offset> points = [];
    List<GeoCoordinates> allCoordinates = [];

    for (var feature in features) {
      var geometry = feature.geometry;
      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          polygons.add(_convertToPixels(ring, size));
          allCoordinates.addAll(ring);
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            polygons.add(_convertToPixels(ring, size));
            allCoordinates.addAll(ring);
          }
        }
      } else if (geometry is GeoLineString) {
        lines.add(_convertToPixels(geometry.points, size));
        allCoordinates.addAll(geometry.points);
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          lines.add(_convertToPixels(line.points, size));
          allCoordinates.addAll(line.points);
        }
      } else if (geometry is GeoPoint) {
        points.add(geoToPixel(geometry.coordinates, size));
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

  List<Offset> _convertToPixels(List<GeoCoordinates> coordinates, Size size) {
    return coordinates.map((c) => geoToPixel(c, size)).toList();
  }

  Offset geoToPixel(GeoCoordinates coord, Size size) {
    double x = (coord.longitude - worldCenterLon) + size.width / 2;
    double y = (worldCenterLat - coord.latitude) + size.height / 2;
    return Offset(x, y);
  }

  void _updateGlobalCenter(GeoJsonLayer layer) {
    centerLon = layer.centerLon;
    centerLat = layer.centerLat;
    maxDelta = layer.maxDelta;
  }
}

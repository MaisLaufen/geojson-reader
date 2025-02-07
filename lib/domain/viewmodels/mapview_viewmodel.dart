import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geomultilinestring.dart';
import 'package:geoapp/data/models/geomultipolygon.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/data/models/point.dart';
import 'package:geoapp/domain/utils/geojson_loader.dart';

double minLon = double.maxFinite, maxLon = double.minPositive;
double minLat = double.maxFinite, maxLat = double.minPositive;

class GeoJsonViewModel extends ChangeNotifier {
  List<List<Offset>> polygons = [];
  List<List<Offset>> lines = [];
  List<Offset> points = [];

  Future<void> loadGeoJson(String filePath, Size size) async {
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);

    // Определение границ координат
    for (var feature in geoJsonData.features) {
      var geometry = feature.geometry;

      if (geometry is GeoPolygon) {
        _updateBounds(geometry.coordinates.expand((ring) => ring));
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          _updateBounds(polygon.coordinates.expand((ring) => ring));
        }
      } else if (geometry is GeoLineString) {
        _updateBounds(geometry.points);
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          _updateBounds(line.points);
        }
      } else if (geometry is GeoPoint) {
        _updateBounds([geometry.coordinates]);
      }
    }

    // Преобразование координат в пиксели
    polygons.clear();
    lines.clear();
    points.clear();

    for (var feature in geoJsonData.features) {
      var geometry = feature.geometry;

      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          polygons.add(_convertToPixels(ring, minLon, maxLon, minLat, maxLat, size));
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            polygons.add(_convertToPixels(ring, minLon, maxLon, minLat, maxLat, size));
          }
        }
      } else if (geometry is GeoLineString) {
        lines.add(_convertToPixels(geometry.points, minLon, maxLon, minLat, maxLat, size));
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          lines.add(_convertToPixels(line.points, minLon, maxLon, minLat, maxLat, size));
        }
      } else if (geometry is GeoPoint) {
        points.add(geoToPixel(geometry.coordinates.longitude, geometry.coordinates.latitude, 
            minLon, maxLon, minLat, maxLat, size));
      }
    }

    notifyListeners();
  }

  void _updateBounds(Iterable<GeoCoordinates> points) {
    for (var point in points) {
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
    }
  }

  List<Offset> _convertToPixels(List<GeoCoordinates> coordinates, 
      double minLon, double maxLon, double minLat, double maxLat, Size size) {
    return coordinates.map((point) => geoToPixel(
        point.longitude, point.latitude, minLon, maxLon, minLat, maxLat, size)).toList();
  }

  Offset geoToPixel(double lon, double lat, double minLon, double maxLon, double minLat, double maxLat, Size size) {
    double scaleX = size.width / (maxLon - minLon);
    double scaleY = size.height / (maxLat - minLat);
    double scale = scaleX < scaleY ? scaleX : scaleY; // Нужно брать минимальный масштаб, чтобы сохранить пропорции

    double x = (lon - minLon) * scale;
    double y = (maxLat - lat) * scale; // Инвертируем, чтобы карта не была перевернутой

    return Offset(x, y);
  }
}
import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geomultilinestring.dart';
import 'package:geoapp/data/models/geomultipolygon.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/data/models/point.dart';
import 'package:geoapp/domain/utils/geojson_loader.dart';

class GeoJsonViewModel extends ChangeNotifier {
  List<List<Offset>> polygons = [];
  List<List<Offset>> lines = [];
  List<List<Offset>> points = [];

  Future<void> loadGeoJson(String filePath, Size size) async {
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);

    double minLon = double.infinity, maxLon = double.negativeInfinity;
    double minLat = double.infinity, maxLat = double.negativeInfinity;

    // Преобразуем координаты для каждого геометрического типа
    for (var feature in geoJsonData.features) {
      var geometry = feature.geometry;

      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          for (var point in ring) {
            minLon = point.longitude < minLon ? point.longitude : minLon;
            maxLon = point.longitude > maxLon ? point.longitude : maxLon;
            minLat = point.latitude < minLat ? point.latitude : minLat;
            maxLat = point.latitude > maxLat ? point.latitude : maxLat;
          }
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            for (var point in ring) {
              minLon = point.longitude < minLon ? point.longitude : minLon;
              maxLon = point.longitude > maxLon ? point.longitude : maxLon;
              minLat = point.latitude < minLat ? point.latitude : minLat;
              maxLat = point.latitude > maxLat ? point.latitude : maxLat;
            }
          }
        }
      } else if (geometry is GeoLineString) {
        for (var point in geometry.points) {
          minLon = point.longitude < minLon ? point.longitude : minLon;
          maxLon = point.longitude > maxLon ? point.longitude : maxLon;
          minLat = point.latitude < minLat ? point.latitude : minLat;
          maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        }
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          for (var point in line.points) {
            minLon = point.longitude < minLon ? point.longitude : minLon;
            maxLon = point.longitude > maxLon ? point.longitude : maxLon;
            minLat = point.latitude < minLat ? point.latitude : minLat;
            maxLat = point.latitude > maxLat ? point.latitude : maxLat;
          }
        }
      } else if (geometry is GeoPoint) {
        var lat = geometry.latitude;
        var lon = geometry.longitude;
        minLon = lon < minLon ? lon : minLon;
        maxLon = lon > maxLon ? lon : maxLon;
        minLat = lat < minLat ? lat : minLat;
        maxLat = lat > maxLat ? lat : maxLat;
      }
    }

    // Преобразуем географические координаты в пиксели для каждого типа
    polygons.clear();
    lines.clear();
    points.clear();

    for (var feature in geoJsonData.features) {
      var geometry = feature.geometry;

      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          List<Offset> convertedRing = ring.map((point) {
            return geoToPixel(point.longitude, point.latitude, minLon, maxLon, minLat, maxLat, size);
          }).toList();
          polygons.add(convertedRing);
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            List<Offset> convertedRing = ring.map((point) {
              return geoToPixel(point.longitude, point.latitude, minLon, maxLon, minLat, maxLat, size);
            }).toList();
            polygons.add(convertedRing);
          }
        }
      } else if (geometry is GeoLineString) {
        List<Offset> convertedLine = geometry.points.map((point) {
          return geoToPixel(point.longitude, point.latitude, minLon, maxLon, minLat, maxLat, size);
        }).toList();
        lines.add(convertedLine);
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          List<Offset> convertedLine = line.points.map((point) {
            return geoToPixel(point.longitude, point.latitude, minLon, maxLon, minLat, maxLat, size);
          }).toList();
          lines.add(convertedLine);
        }
      } else if (geometry is GeoPoint) {
        List<Offset> convertedPoint = [
          geoToPixel(geometry.longitude, geometry.latitude, minLon, maxLon, minLat, maxLat, size)
        ];
        points.add(convertedPoint);
      }
    }

    notifyListeners();
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
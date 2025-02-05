import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/models/geomultipolygon.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/domain/utils/geojson_loader.dart';

class GeoJsonViewModel extends ChangeNotifier {
  List<List<Offset>> polygons = [];

  Future<void> loadGeoJson(String filePath, Size size) async {
    // Загружаем GeoJSON данные из файла
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);

    // Определяем границы координат
    double minLon = double.infinity, maxLon = double.negativeInfinity;
    double minLat = double.infinity, maxLat = double.negativeInfinity;

    // Находим минимальные и максимальные значения для долготы и широты
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
      }
    }

    // Преобразуем координаты в пиксели
    polygons = <List<Offset>>[];

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
      }
    }

    notifyListeners();
  }

// Преобразование географических координат в пиксели с учетом размера виджета
  Offset geoToPixel(double lon, double lat, double minLon, double maxLon, double minLat, double maxLat, Size size) {
    // Находим масштабирование по ширине и высоте
    double scaleX = size.width / (maxLon - minLon);
    double scaleY = size.height / (maxLat - minLat);

    // Поддерживаем пропорции карты
    double scale = scaleX < scaleY ? scaleX : scaleY;

    double x = (lon - minLon) * scale;
    double y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height * scale;

    return Offset(x, y);
  }
}
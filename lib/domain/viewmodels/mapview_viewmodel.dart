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

  // Условные глобальные координаты (центр карты мира)
  final double worldCenterLon = 0.0; // Центр долгот (экватор)
  final double worldCenterLat = 0.0; // Центр широт (нулевой меридиан)

  Future<void> loadGeoJson(String filePath, Size size) async {
    GeoJsonData geoJsonData = await GeoJsonLoader.loadFromFile(filePath);

    // Собираем все координаты
    List<GeoCoordinates> allCoordinates = [];
    for (var feature in geoJsonData.features) {
      var geometry = feature.geometry;
      if (geometry is GeoPolygon) {
        allCoordinates.addAll(geometry.coordinates.expand((ring) => ring));
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          allCoordinates.addAll(polygon.coordinates.expand((ring) => ring));
        }
      } else if (geometry is GeoLineString) {
        allCoordinates.addAll(geometry.points);
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          allCoordinates.addAll(line.points);
        }
      } else if (geometry is GeoPoint) {
        allCoordinates.add(geometry.coordinates);
      }
    }

    if (allCoordinates.isEmpty) return;

    // Вычисляем центр для этого слоя
    double tempCenterLon = allCoordinates.map((c) => c.longitude).reduce((a, b) => a + b) / allCoordinates.length;
    double tempCenterLat = allCoordinates.map((c) => c.latitude).reduce((a, b) => a + b) / allCoordinates.length;

    // Вычисляем максимальное отклонение от центра для масштаба
    double tempMaxDelta = allCoordinates
        .map((c) => (c.longitude - tempCenterLon).abs().clamp(0.0, (c.latitude - tempCenterLat).abs()))
        .reduce((a, b) => a > b ? a : b);
    if (tempMaxDelta == 0) tempMaxDelta = 1.0; // Предотвращаем деление на ноль

    // Нормализуем масштаб относительно глобальных координат (центр карты мира)
    var layer = _convertGeoJsonToLayer(geoJsonData.features, size, tempCenterLon, tempCenterLat, tempMaxDelta);

    // Добавляем слой в коллекцию
    layers.add(layer);

    // Обновляем глобальные параметры центра и maxDelta для всего набора слоев
    centerLon = tempCenterLon;
    centerLat = tempCenterLat;
    maxDelta = tempMaxDelta;

    notifyListeners();
  }

  GeoJsonLayer _convertGeoJsonToLayer(List<GeoFeature> features, Size size, double centerLon, double centerLat, double maxDelta) {
    List<List<Offset>> polygons = [];
    List<List<Offset>> lines = [];
    List<Offset> points = [];

    for (var feature in features) {
      var geometry = feature.geometry;
      if (geometry is GeoPolygon) {
        for (var ring in geometry.coordinates) {
          polygons.add(_convertToPixels(ring, size, centerLon, centerLat, maxDelta));
        }
      } else if (geometry is GeoMultiPolygon) {
        for (var polygon in geometry.polygons) {
          for (var ring in polygon.coordinates) {
            polygons.add(_convertToPixels(ring, size, centerLon, centerLat, maxDelta));
          }
        }
      } else if (geometry is GeoLineString) {
        lines.add(_convertToPixels(geometry.points, size, centerLon, centerLat, maxDelta));
      } else if (geometry is GeoMultiLineString) {
        for (var line in geometry.lineStrings) {
          lines.add(_convertToPixels(line.points, size, centerLon, centerLat, maxDelta));
        }
      } else if (geometry is GeoPoint) {
        points.add(geoToPixel(geometry.coordinates, size, centerLon, centerLat, maxDelta));
      }
    }

    return GeoJsonLayer(
      polygons: polygons,
      lines: lines,
      points: points,
      centerLon: centerLon,
      centerLat: centerLat,
      maxDelta: maxDelta,
    );
  }

  List<Offset> _convertToPixels(List<GeoCoordinates> coordinates, Size size, double centerLon, double centerLat, double maxDelta) {
    return coordinates.map((c) => geoToPixel(c, size, centerLon, centerLat, maxDelta)).toList();
  }

  Offset geoToPixel(GeoCoordinates coord, Size size, double centerLon, double centerLat, double maxDelta) {
    // Масштабируем относительно глобального масштаба

    // Переводим координаты относительно центра карты мира, чтобы они были точно в том месте
    double x = (coord.longitude - worldCenterLon)  + size.width / 2;
    double y = (worldCenterLat - coord.latitude)  + size.height / 2;

    return Offset(x, y);
  }
}
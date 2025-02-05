import 'dart:convert';

// Типы объектов:
import 'package:geoapp/data/models/geofeature.dart';
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geometry.dart';
import 'package:geoapp/data/models/geomultilinestring.dart';
import 'package:geoapp/data/models/geomultipolygon.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/data/models/point.dart';

class GeoJsonParser {
  static GeoJsonData parse(String jsonString) {
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final List<GeoFeature> features = (jsonData['features'] as List)
        .map((feature) => _parseFeature(feature))
        .toList();

    return GeoJsonData(features);
  }

  static GeoFeature _parseFeature(Map<String, dynamic> feature) {
    String type = feature['type'];
    Geometry geometry = _parseGeometry(feature['geometry']);
    Map<String, dynamic> properties = feature['properties'] ?? {};

    return GeoFeature(type: type, geometry: geometry, properties: properties);
  }

  static Geometry _parseGeometry(Map<String, dynamic> geometry) {
    String type = geometry['type'];
    var coordinates = geometry['coordinates'];

    switch (type) {
      case 'Point':
        return GeoPoint(
          (coordinates[1] as num).toDouble(),
          (coordinates[0] as num).toDouble(),
        );
      case 'LineString':
        return GeoLineString(
          (coordinates as List).map((coord) => GeoPoint(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          )).toList(),
        );
      case 'Polygon':
        return GeoPolygon(
          (coordinates as List).map((ring) => (ring as List)
              .map((coord) => GeoPoint(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              ))
              .toList()).toList(),
        );
      case 'MultiPolygon':
        return GeoMultiPolygon(
          (coordinates as List).map((polygon) => GeoPolygon(
            (polygon as List).map((ring) => (ring as List)
                .map((coord) => GeoPoint(
                  (coord[1] as num).toDouble(),
                  (coord[0] as num).toDouble(),
                ))
                .toList()).toList(),
          )).toList(),
        );
      case 'MultiLineString':
        return GeoMultiLineString(
          (coordinates as List).map((line) => GeoLineString(
            (line as List).map((coord) => GeoPoint(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            )).toList(),
          )).toList(),
        );
      default:
        throw UnsupportedError('Geometry type $type is not supported');
    }
  }
}
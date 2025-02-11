import 'dart:convert';

// Типы объектов:
import 'package:geoapp/data/models/geocoordinate.dart';
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
        .map((feature) => _parseFeature(feature as Map<String, dynamic>))
        .toList();

    return GeoJsonData(features);
  }

  static GeoFeature _parseFeature(Map<String, dynamic> feature) {
    Geometry geometry = _parseGeometry(feature['geometry'] as Map<String, dynamic>);
    Map<String, dynamic> properties = feature['properties'] ?? {};

    return GeoFeature(geometry: geometry, properties: properties);
  }

  static Geometry _parseGeometry(Map<String, dynamic> geometry) {
    String type = geometry['type'];
    var coordinates = geometry['coordinates'];
    String? name = geometry.containsKey('name') ? geometry['name'] : null;

    switch (type) {
      case 'Point':
        return GeoPoint(
          GeoCoordinates(
            (coordinates[1] as num).toDouble(),
            (coordinates[0] as num).toDouble(),
          ),
          name,
          geometry['website'],
          geometry['phone'],
        );
      case 'LineString':
        return GeoLineString(
          (coordinates as List)
              .map((coord) => GeoCoordinates(
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  ))
              .toList(),
          name ?? '',
        );
      case 'Polygon':
        return GeoPolygon(
          (coordinates as List)
              .map((ring) => (ring as List)
                  .map((coord) => GeoCoordinates(
                        (coord[1] as num).toDouble(),
                        (coord[0] as num).toDouble(),
                      ))
                  .toList())
              .toList(),
          name ?? '',
        );
      case 'MultiPolygon':
        return GeoMultiPolygon(
          (coordinates as List)
              .map((polygon) => GeoPolygon(
                    (polygon as List)
                        .map((ring) => (ring as List)
                            .map((coord) => GeoCoordinates(
                                  (coord[1] as num).toDouble(),
                                  (coord[0] as num).toDouble(),
                                ))
                            .toList())
                        .toList(),
                    name ?? '',
                  ))
              .toList(),
          name ?? '',
        );
      case 'MultiLineString':
        return GeoMultiLineString(
          (coordinates as List)
              .map((line) => GeoLineString(
                    (line as List)
                        .map((coord) => GeoCoordinates(
                              (coord[1] as num).toDouble(),
                              (coord[0] as num).toDouble(),
                            ))
                        .toList(),
                    name ?? '',
                  ))
              .toList(),
          name ?? '',
        );
      default:
        throw UnsupportedError('Geometry type $type is not supported');
    }
  }
}

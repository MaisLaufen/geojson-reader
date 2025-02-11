import 'package:geoapp/data/models/geometry.dart';

/// Класс для представления объекта GeoJSON
class GeoFeature {
  final Geometry geometry;
  final Map<String, dynamic> properties;

  GeoFeature({required this.geometry, required this.properties});
}
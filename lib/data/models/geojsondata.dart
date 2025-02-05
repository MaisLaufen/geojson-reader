import 'package:geoapp/data/models/geofeature.dart';

/// Основной объект GeoJSON (FeatureCollection)
class GeoJsonData {
  final List<GeoFeature> features;

  GeoJsonData(this.features);
}
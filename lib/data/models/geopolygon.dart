import 'package:geoapp/data/models/geometry.dart';
import 'package:geoapp/data/models/point.dart';

class GeoPolygon extends Geometry {
  final List<List<GeoPoint>> coordinates;

  GeoPolygon(this.coordinates) : super('Polygon');
}
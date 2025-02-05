import 'package:geoapp/data/models/geometry.dart';
import 'package:geoapp/data/models/point.dart';

class GeoLineString extends Geometry {
  final List<GeoPoint> points;

  GeoLineString(this.points) : super('LineString');
}
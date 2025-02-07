import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/data/models/geometry.dart';

class GeoLineString extends Geometry {
  final List<GeoCoordinates> points;
  final String name;

  GeoLineString(this.points, this.name) : super('LineString');
}
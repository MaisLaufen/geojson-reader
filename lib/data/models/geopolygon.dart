import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/data/models/geometry.dart';

class GeoPolygon extends Geometry {
  final List<List<GeoCoordinates>> coordinates;
  final String name;

  GeoPolygon(this.coordinates, this.name) : super('Polygon');
}
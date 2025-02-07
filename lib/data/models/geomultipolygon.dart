import 'package:geoapp/data/models/geometry.dart';
import 'package:geoapp/data/models/geopolygon.dart';

class GeoMultiPolygon extends Geometry {
  final List<GeoPolygon> polygons;
  final String name;

  GeoMultiPolygon(this.polygons, this.name) : super("MultiPolygon");
}
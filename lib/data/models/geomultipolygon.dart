import 'package:geoapp/data/models/geometry.dart';
import 'package:geoapp/data/models/geopolygon.dart';

class GeoMultiPolygon extends Geometry {
  List<GeoPolygon> polygons;

  GeoMultiPolygon(this.polygons) : super("MultiPolygon");
}
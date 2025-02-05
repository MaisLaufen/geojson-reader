import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geometry.dart';

class GeoMultiLineString extends Geometry {
  final List<GeoLineString> lineStrings;

  GeoMultiLineString(this.lineStrings) : super('MultiLineString');
}
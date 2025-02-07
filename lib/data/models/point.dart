import 'package:geoapp/data/models/geocoordinate.dart';
import 'package:geoapp/data/models/geometry.dart';

class GeoPoint extends Geometry {
  final GeoCoordinates coordinates;
  final String? name;
  final String? website;
  final String? phone;

  GeoPoint(this.coordinates, this.name, this.website, this.phone) : super('Point');
}
import 'package:geoapp/data/models/geometry.dart';

class GeoPoint extends Geometry {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude) : super('Point');
}
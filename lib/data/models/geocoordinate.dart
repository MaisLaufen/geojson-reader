import 'package:geoapp/data/models/geometry.dart';

class GeoCoordinates extends Geometry {
  final double latitude;
  final double longitude;

  GeoCoordinates(this.latitude, this.longitude) : super('Coordinates');
}
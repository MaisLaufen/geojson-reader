import 'package:geoapp/data/models/geometry.dart';

class MapObject extends Geometry {
  final dynamic data;

  MapObject({required String type, required this.data}) : super(type);
}
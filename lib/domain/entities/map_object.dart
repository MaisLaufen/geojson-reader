import 'package:geoapp/data/models/geometry.dart';

class MapObject extends Geometry {
  final dynamic data;

  MapObject({required String type, required this.data}) : super(type);

    @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapObject && other.type == type && other.data == data;
  }

  @override
  int get hashCode => Object.hash(type, data);
}
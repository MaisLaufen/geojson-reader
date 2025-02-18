import 'package:geoapp/domain/entities/map_line.dart';
import 'package:geoapp/domain/entities/map_point.dart';
import 'package:geoapp/domain/entities/map_polygon.dart';

class GeoJsonLayer {
  List<MapPolygon> polygons = [];
  List<MapLine> lines = [];
  List<MapPoint> points = [];
  int index;
  bool isVisible;
  String name = "Unnamed layer";

  double centerLon = 0.0, centerLat = 0.0;
  double maxDelta = 1.0;

  GeoJsonLayer({
    required this.polygons,
    required this.lines,
    required this.points,
    required this.centerLon,
    required this.centerLat,
    required this.maxDelta,
    required this.index,
    required this.name,
    this.isVisible = true,
  });
}
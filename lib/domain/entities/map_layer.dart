import 'dart:ui';

class GeoJsonLayer {
  List<List<Offset>> polygons = [];
  List<List<Offset>> lines = [];
  List<Offset> points = [];
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
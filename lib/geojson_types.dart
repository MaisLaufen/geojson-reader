/// Bounding box
/// https://tools.ietf.org/html/rfc7946#section-5
typedef BBox = List<double>;

/// A Position is an array of coordinates.
/// https://tools.ietf.org/html/rfc7946#section-3.1.1
typedef Position = List<double>;

/// The base GeoJSON object.
/// https://tools.ietf.org/html/rfc7946#section-3
abstract class GeoJsonObject {
  /// Specifies the type of GeoJSON object.
  final String type;

  /// Bounding box of the coordinate range.
  final BBox? bbox;

  GeoJsonObject({required this.type, this.bbox});
}

/// Geometry object.
/// https://tools.ietf.org/html/rfc7946#section-3
abstract class Geometry extends GeoJsonObject {
  Geometry({required super.type, super.bbox});
}

class Point extends Geometry {
  final Position coordinates;

  Point({required this.coordinates}) : super(type: "Point");
}

class MultiPoint extends Geometry {
  final List<Position> coordinates;

  MultiPoint({required this.coordinates}) : super(type: "MultiPoint");
}

class LineString extends Geometry {
  final List<Position> coordinates;

  LineString({required this.coordinates}) : super(type: "LineString");
}

class MultiLineString extends Geometry {
  final List<List<Position>> coordinates;

  MultiLineString({required this.coordinates}) : super(type: "MultiLineString");
}

class Polygon extends Geometry {
  final List<List<Position>> coordinates;

  Polygon({required this.coordinates}) : super(type: "Polygon");
}

class MultiPolygon extends Geometry {
  final List<List<List<Position>>> coordinates;

  MultiPolygon({required this.coordinates}) : super(type: "MultiPolygon");
}

class GeometryCollection extends Geometry {
  final List<Geometry> geometries;

  GeometryCollection({required this.geometries}) : super(type: "GeometryCollection");
}

typedef GeoJsonProperties = Map<String, dynamic>?;

/// A feature object which contains a geometry and associated properties.
/// https://tools.ietf.org/html/rfc7946#section-3.2
class Feature<G extends Geometry?> extends GeoJsonObject {
  final G geometry;
  final GeoJsonProperties properties;
  final dynamic id;

  Feature({required this.geometry, this.properties, this.id}) : super(type: "Feature");
}

/// A collection of feature objects.
/// https://tools.ietf.org/html/rfc7946#section-3.3
class FeatureCollection<G extends Geometry?> extends GeoJsonObject {
  final List<Feature<G>> features;

  FeatureCollection({required this.features}) : super(type: "FeatureCollection");
}

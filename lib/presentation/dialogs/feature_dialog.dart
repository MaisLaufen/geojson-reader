import 'package:flutter/material.dart';
import 'package:geoapp/data/models/geolinestring.dart';
import 'package:geoapp/data/models/geopolygon.dart';
import 'package:geoapp/data/models/point.dart';
import 'package:geoapp/domain/entities/map_object.dart';

class FeatureDialog extends StatelessWidget {
  final MapObject mapObject;

  const FeatureDialog({super.key, required this.mapObject});

  @override
  Widget build(BuildContext context) {
    String dataString;
    String? name;

    if (mapObject.data is GeoLineString) {
      name = (mapObject.data as GeoLineString).name;
      dataString = "Линия с ${(mapObject.data as GeoLineString).points.length} точками";
    } else if (mapObject.data is GeoPolygon) {
      name = (mapObject.data as GeoPolygon).name;
      dataString = "Полигон с ${(mapObject.data as GeoPolygon).coordinates.length} вершинами";
    } else if (mapObject.data is GeoPoint) {
      dataString = "Координаты точки: ${mapObject.data}";
    } else {
      dataString = "Неизвестный объект";
    }

    return AlertDialog(
      title: Text("Объект: ${mapObject.type}"),
      content: Text("Имя: ${name ?? 'Нет'}\nДанные: $dataString"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Закрыть"),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_line.dart';
import 'package:geoapp/domain/entities/map_object.dart';
import 'package:geoapp/domain/entities/map_point.dart';
import 'package:geoapp/domain/entities/map_polygon.dart';

class FeatureDialog extends StatelessWidget {
  final MapObject mapObject;

  const FeatureDialog({super.key, required this.mapObject});

  @override
  Widget build(BuildContext context) {
    String dataString;
    String? name;

    if (mapObject.data is MapLine) {
      name = (mapObject.data as MapLine).name;
      dataString = "Линия с ${(mapObject.data as MapLine).coordinates.length} точками";
    } else if (mapObject.data is MapPolygon) {
      name = (mapObject.data as MapPolygon).name;
      dataString = "Полигон с ${(mapObject.data as MapPolygon).coordinates.length} вершинами";
    } else if (mapObject.data is MapPoint) {
      name = (mapObject.data as MapPoint).name;
      dataString = "Координаты точки: ${(mapObject.data as MapPoint).coordinates}";
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
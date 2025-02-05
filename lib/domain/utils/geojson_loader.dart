import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geoapp/data/models/geojsondata.dart';
import 'package:geoapp/data/repositories/geojson_parser.dart';

class GeoJsonLoader {
  /// Загружает GeoJSON из локального файла на устройстве
  static Future<GeoJsonData> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      return GeoJsonParser.parse(jsonString);
    } catch (e) {
      throw Exception('Ошибка загрузки GeoJSON из файла: $e');
    }
  }

  /// Загружает GeoJSON из assets (если файл встроен в приложение)
  static Future<GeoJsonData> loadFromAssets(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return GeoJsonParser.parse(jsonString);
    } catch (e) {
      throw Exception('Ошибка загрузки GeoJSON из assets: $e');
    }
  }
}

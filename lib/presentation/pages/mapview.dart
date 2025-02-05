import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';
import 'package:geoapp/presentation/widgets/geojson_painter.dart';
import 'package:provider/provider.dart';

class GeoJsonScreen extends StatefulWidget {
  const GeoJsonScreen({super.key});

  @override
  GeoJsonScreenState createState() => GeoJsonScreenState();
}

class GeoJsonScreenState extends State<GeoJsonScreen> {
  late TransformationController _transformationController;
  List<Color> _colors = [];
  late double _mapWidth;
  late double _mapHeight;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GeoJsonViewModel>(context, listen: false);
      viewModel.loadGeoJson(
        'C://Users//MaisLaufen//source//geoapp//lib//test_data//stud_area.geojson',
        const Size(1000, 1000),
      ).then((_) {
        _generateColors(viewModel.polygons.length + viewModel.lines.length + viewModel.points.length);
        _updateMapSize(viewModel);
      });
    });
  }

  void _generateColors(int count) {
    setState(() {
      _colors = List.generate(count, (index) {
        final Random random = Random();
        return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
      });
    });
  }

  void _updateMapSize(GeoJsonViewModel viewModel) {
    double minLon = double.infinity, maxLon = double.negativeInfinity;
    double minLat = double.infinity, maxLat = double.negativeInfinity;

    for (var feature in viewModel.polygons) {
      for (var point in feature) {
        double lon = point.dx;
        double lat = point.dy;

        minLon = lon < minLon ? lon : minLon;
        maxLon = lon > maxLon ? lon : maxLon;
        minLat = lat < minLat ? lat : minLat;
        maxLat = lat > maxLat ? lat : maxLat;
      }
    }

    final widthRatio = maxLon - minLon;
    final heightRatio = maxLat - minLat;

    setState(() {
      _mapWidth = widthRatio;
      _mapHeight = heightRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карта GeoJSON')),
      body: Center(
        child: Consumer<GeoJsonViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.polygons.isEmpty &&
                viewModel.lines.isEmpty &&
                viewModel.points.isEmpty) {
              return const CircularProgressIndicator();
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2)
              ),
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.5,
                maxScale: 5.0,
                child: CustomPaint(
                  size: Size(_mapWidth, _mapHeight),
                  painter: GeoJsonPainter(
                    viewModel.polygons, 
                    viewModel.lines, 
                    viewModel.points, 
                    _colors
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
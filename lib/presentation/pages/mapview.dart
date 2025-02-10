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

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GeoJsonViewModel>(context, listen: false);
      viewModel.loadGeoJson(
        'C://Users//MaisLaufen//source//geoapp//lib//test_data//world.geojson',
        const Size(1000, 1000)
      );
      viewModel.loadGeoJson(
      'C://Users//MaisLaufen//source//geoapp//lib//test_data//uk_la.geojson',
      const Size(1000, 1000),
    );
      viewModel.loadGeoJson(
      'C://Users//MaisLaufen//source//geoapp//lib//test_data//us_cities.geojson',
      const Size(1000, 1000),
    );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карта GeoJSON')),
      body: Center(
        child: Consumer<GeoJsonViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.layers.isEmpty) {
              return const CircularProgressIndicator();
            }

            return GeoJsonMapView(
              layers: viewModel.layers,
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

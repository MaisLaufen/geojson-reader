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
      viewModel.loadGeoJson('C://Users//MaisLaufen//source//geoapp//lib//test_data//world.geojson', const Size(1000, 1000));
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GeoJsonViewModel>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF353535),
      appBar: AppBar(
        title: const Text('Карта GeoJSON', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: viewModel.layers.isEmpty
                  ? const CircularProgressIndicator()
                  : GeoJsonMapView(layers: viewModel.layers),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            color: Colors.black87,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    viewModel.addLayer(context, const Size(1000, 1000));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('Добавить слой', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.layers.length,
                    itemBuilder: (context, index) {
                      final layer = viewModel.layers[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(layer.name, style: const TextStyle(color: Colors.white)),
                          leading: Checkbox(
                            value: layer.isVisible,
                            onChanged: (bool? value) {
                              viewModel.toggleLayerVisibility(index);
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              viewModel.removeLayer(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

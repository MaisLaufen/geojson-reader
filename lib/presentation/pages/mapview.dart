import 'package:flutter/material.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';
import 'package:geoapp/presentation/widgets/geojson_painter.dart';
import 'package:geoapp/presentation/widgets/layer_widget.dart';
import 'package:provider/provider.dart';

class GeoJsonScreen extends StatefulWidget {
  const GeoJsonScreen({super.key});

  @override
  GeoJsonScreenState createState() => GeoJsonScreenState();
}

class GeoJsonScreenState extends State<GeoJsonScreen> {

  @override
  void initState() {
    super.initState();

    final viewModel = Provider.of<GeoJsonViewModel>(context, listen: false);
      viewModel.loadGeoJson('lib\\test_data\\world.geojson');

    viewModel.errorMessage.addListener(() {
    if (viewModel.errorMessage.value != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Ошибка"),
          content: Text(viewModel.errorMessage.value!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ОК"),
            ),
          ],
        ),
      );
      viewModel.errorMessage.value = null;
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GeoJsonViewModel>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF353535),
      appBar: AppBar(
        title: const Text('Просмотр карт формата geojson', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
child: Center(
  child: viewModel.layers.isEmpty
      ? const Text(
          'В данный момент слоев нет.\nЧтобы добавить их, нажмите на кнопку "Добавить слой".',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        )
      : GeoJsonMapView(layers: viewModel.layers),
),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
        width: double.infinity,
        color: Colors.black54,
        child: const Text(
          "Список слоев:",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
                Expanded(
  child: ListView.builder(
    itemCount: viewModel.layers.length,
    itemBuilder: (context, index) {
      final layer = viewModel.layers[index];
      return LayerListItem(
        layer: layer,
        onToggleVisibility: () => viewModel.toggleLayerVisibility(index),
        onRemove: () => viewModel.removeLayer(index),
      );
    },
  ),
                ),
SizedBox(
  width: double.infinity,
  height: 35,
  child: ElevatedButton(
    onPressed: () {
      viewModel.addLayer();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    child: const Text('Добавить слой', style: TextStyle(fontSize: 16.0)),
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
    super.dispose();
  }
}

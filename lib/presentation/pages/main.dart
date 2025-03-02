import 'package:flutter/material.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';
import 'package:geoapp/presentation/widgets/map_gesture_detector.dart';
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
      backgroundColor: const Color(0xFF303030),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Center(
  child: viewModel.layers.isEmpty
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              'https://media.tenor.com/xz0WA5Lg9koAAAAi/shuba-shuba-transparent.gif',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'В данный момент слоев нет.\nЧтобы добавить их, нажмите на кнопку "Добавить слой".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        )
      : GeoJsonMapView(layers: viewModel.layers),
),
            ),
            const SizedBox(width: 12),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(162, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Список слоев:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                 Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: viewModel.layers.length,
    itemBuilder: (context, index) {
      final layer = viewModel.layers[index];
      return LayerListItem(
        layer: layer,
        onToggleVisibility: () => viewModel.toggleLayerVisibility(index),
        onRemove: () => viewModel.removeLayer(index),
        onMoveUp: () => viewModel.moveLayerUp(index),
        onMoveDown: () => viewModel.moveLayerDown(index),
        isTopLayer: viewModel.isTopLayer(index),
        isBottomLayer: viewModel.isBottomLayer(index),
        viewModel: viewModel,
      );
    },
  ),
),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.addLayer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2F2F2F),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Добавить слой',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

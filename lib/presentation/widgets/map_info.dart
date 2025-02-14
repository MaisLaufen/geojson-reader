
import 'package:flutter/material.dart';
import 'package:geoapp/domain/viewmodels/map_widget_vm.dart';

class GeoJsonMapInfo extends StatelessWidget {
  final GeoJsonMapViewModel viewModel;

  const GeoJsonMapInfo({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset?>(
      valueListenable: viewModel.cursorPositionNotifier,
      builder: (context, cursorPosition, child) {
        return Container(
          width: double.infinity,
          color: Colors.black54,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Scale: ${viewModel.scale.toStringAsFixed(2)} | '
            '${cursorPosition != null ? 'Lat: ${cursorPosition.dx.toStringAsFixed(1)}, Lon: ${cursorPosition.dy.toStringAsFixed(1)}' : 'Cursor: N/A'}',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
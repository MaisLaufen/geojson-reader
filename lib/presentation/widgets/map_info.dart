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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(162, 0, 0, 0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Приближение: ${viewModel.scale.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                cursorPosition != null
                    ? _getCoordinates(cursorPosition)
                    : 'Cursor: N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCoordinates(Offset cursorPosition) {

    double relativeLon = (cursorPosition.dx - viewModel.position.dx) / viewModel.scale;
    double relativeLat = (cursorPosition.dy - viewModel.position.dy) / viewModel.scale;

    double longitude = relativeLon;
    double latitude = relativeLat;

    return 'Широта: ${latitude.toStringAsFixed(5)}, Долгота: ${longitude.toStringAsFixed(5)}';
  }
}
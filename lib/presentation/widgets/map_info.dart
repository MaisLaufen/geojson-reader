
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
                'Scale: ${viewModel.scale.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                cursorPosition != null
                    ? 'Lat: ${cursorPosition.dx.toStringAsFixed(1)}, Lon: ${cursorPosition.dy.toStringAsFixed(1)}'
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
}
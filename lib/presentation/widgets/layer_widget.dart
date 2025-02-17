import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';

class LayerListItem extends StatelessWidget {
  final GeoJsonLayer layer;
  final VoidCallback onToggleVisibility;
  final VoidCallback onRemove;

  const LayerListItem({
    super.key,
    required this.layer,
    required this.onToggleVisibility,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        title: Text(layer.name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.visibility,
            color: layer.isVisible ? Colors.white : Colors.black,
          ),
          onPressed: onToggleVisibility,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.grey), // Иконка мусорки серого цвета
          onPressed: onRemove,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';

class LayerListItem extends StatelessWidget {
  final GeoJsonLayer layer;
  final VoidCallback onToggleVisibility;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final bool isTopLayer;
  final bool isBottomLayer;
  final GeoJsonViewModel viewModel;

  const LayerListItem({
    super.key,
    required this.layer,
    required this.onToggleVisibility,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.isTopLayer,
    required this.isBottomLayer,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        title: Text(
          layer.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            layer.isVisible ? Icons.visibility : Icons.visibility_off,
            color: layer.isVisible ? Colors.grey[600] : Colors.grey[1000],
          ),
          onPressed: onToggleVisibility,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isTopLayer)
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                color: Colors.grey[600],
                onPressed: onMoveUp,
              ),
            if (!isBottomLayer)
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                color: Colors.grey[600],
                onPressed: onMoveDown,
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.grey[600],
              onPressed: () => viewModel.renameLayer(context, viewModel.layers.indexOf(layer)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
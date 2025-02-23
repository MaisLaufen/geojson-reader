import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_object.dart';

class SelectedObjectsList extends StatelessWidget {
  final List<MapObject> selectedObjects;
  final Function(MapObject) onRemoveSelected;

  const SelectedObjectsList({
    super.key,
    required this.selectedObjects,
    required this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(100, 50, 50, 50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: selectedObjects.isEmpty
          ? const Center(
              child: Text(
                "Нет выбранных объектов",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: selectedObjects.length,
              itemBuilder: (context, index) {
                final object = selectedObjects[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F2F2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        object.data.name ?? "Без имени",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          onRemoveSelected(object);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
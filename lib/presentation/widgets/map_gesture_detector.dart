import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoapp/domain/entities/map_layer.dart';
import 'package:geoapp/domain/viewmodels/map_widget_vm.dart';
import 'package:geoapp/presentation/widgets/custom_btn.dart';
import 'package:geoapp/presentation/widgets/map_info.dart';

import 'map_drawer.dart';

class GeoJsonMapView extends StatefulWidget {
  final List<GeoJsonLayer> layers;

  const GeoJsonMapView({super.key, required this.layers});

  @override
  GeoJsonMapViewState createState() => GeoJsonMapViewState();
}

class GeoJsonMapViewState extends State<GeoJsonMapView> {
  late final GeoJsonMapViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GeoJsonMapViewModel(widget.layers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Listener(
            onPointerSignal: (event) {
if (event is PointerScrollEvent) {
  setState(() => _viewModel.onScroll(event.scrollDelta.dy, _viewModel.cursorPositionNotifier.value ?? Offset.zero));
}
            },
            onPointerHover: (event) {
              setState(() => _viewModel.updateCursorPosition(event.localPosition));
            },
            child: GestureDetector(
              onScaleUpdate: (details) {
                setState(() => _viewModel.updatePosition(details.focalPointDelta));
              },
              onTapDown: (TapDownDetails details) {
                _viewModel.detectFeatureAt(details.localPosition, context);
              },
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: MapDrawer(
                      layers: widget.layers,
                      selectedObjects: Set.from(_viewModel.selectedObjects),
                      scale: _viewModel.scale,
                      position: _viewModel.position,
                    ),
                  ),
/// Кнопки в верхнем левом углу в ряд
    Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Отступ от краев
        child: Row(
          mainAxisSize: MainAxisSize.min, // Чтобы кнопки не растягивались
          children: [
            CustomButton(label: "Очистить выборку", onPressed: _viewModel.clearSelection),
            const SizedBox(width: 10), // Отступ между кнопками
            CustomButton(label: "Выбрать пересечения", onPressed: _viewModel.selectIntersectingFeatures),
          ],
        ),
      ),
    ),
  ],
),
            ),
          ),
        ),
        GeoJsonMapInfo(viewModel: _viewModel),
      ],
    );
  }
}

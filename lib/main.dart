import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';
import 'package:geoapp/presentation/pages/mapview.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeoJsonViewModel()),
      ],
      child: MaterialApp(
        home: GeoJsonScreen(),
      ),
    ),
  );
}
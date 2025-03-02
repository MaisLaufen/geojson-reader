import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geoapp/domain/viewmodels/mapview_viewmodel.dart';
import 'package:geoapp/presentation/pages/main.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeoJsonViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GeoJsonScreen(),
      ),
    ),
  );
}
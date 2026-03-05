import 'package:flutter/material.dart';
import 'package:map_food/controller/comerciante_controller.dart';
import 'package:provider/provider.dart';

class MapTeste extends StatefulWidget {
  const MapTeste({super.key});

  @override
  State<MapTeste> createState() => _MapTesteState();
}

class _MapTesteState extends State<MapTeste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ComercianteController(),
        child: Builder(builder: (context) {
          final controller = Provider.of<ComercianteController>(context);
          return Column(
            children: [
              Text('Latitude: ${controller.latitue}'),
              Text('Longitude: ${controller.longitude}'),
              Text('Erro: ${controller.erro}'),
            ],
          );
        }),
    ));
  }
}

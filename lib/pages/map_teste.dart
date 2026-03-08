import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        child: Builder(
          builder: (context) {
            final controller = Provider.of<ComercianteController>(context);
            return Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.latitue,
                          controller.longitude,
                        ),
                        zoom: 15,
                      ),
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

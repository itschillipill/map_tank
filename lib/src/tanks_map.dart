import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

import 'render_box.dart';

class TanksMap extends StatefulWidget {
  const TanksMap({super.key});

  @override
  State<TanksMap> createState() => _TanksMapState();
}

class _TanksMapState extends State<TanksMap> with TickerProviderStateMixin {
  late final MapController mapController;
  final _tanksLayerKey = GlobalKey();
  ui.Image? sprite;
  final Tank playerTank = Tank(
    position: const LatLng(41.0082, 28.9784),
    isMine: true,
  );

  final List<Tank> tanks = [
    Tank(position: const LatLng(32.088, 34.785)),
    Tank(position: const LatLng(30.0444, 31.2357)),
    Tank(position: const LatLng(48.8566, 2.3522)),
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadUiImage('assets/images/tank.png').then((img) {
      setState(() {
        sprite = img;
      });
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void handleTap(PointerDownEvent event) {
    final renderBox =
        _tanksLayerKey.currentContext?.findRenderObject() as RenderTanksLayer?;
    if (renderBox == null) return;
    renderBox.handleTap(event);
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map Tanks")),
      drawer: const Drawer(),
      body: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: playerTank.position,
                initialZoom: 5,
                minZoom: 3,
                maxZoom: 20,
              ),
              children: <Widget>[openStreetMapTileLayer],
            ),
          ),
          if (sprite != null)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: handleTap,
                child: RepaintBoundary(
                  child: TanksLayer(
                    key: _tanksLayerKey,
                    mapController: mapController,
                    palyerTank: playerTank,
                    tanks: tanks,
                    vsync: this,
                    sprite: sprite!,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 10,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 16,
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 0.5,
                    );
                  },
                  child: const Icon(Icons.add),
                ),

                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 0.5,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),

                FloatingActionButton.small(
                  heroTag: "my_location",
                  onPressed: () {
                    mapController.move(
                      playerTank.position,
                      mapController.camera.zoom,
                    );
                  },
                  child: const Icon(Icons.my_location_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TanksLayer extends LeafRenderObjectWidget {
  final MapController mapController;
  final List<Tank> tanks;
  final Tank palyerTank;
  final TickerProvider vsync;
  final ui.Image sprite;

  const TanksLayer({
    required this.mapController,
    required this.tanks,
    required this.palyerTank,
    required this.vsync,
    required this.sprite,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTanksLayer(
      mapController,
      tanks,
      palyerTank,
      vsync: vsync,
      sprite: sprite,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTanksLayer renderObject) {
    renderObject
      ..mapController = mapController
      ..enemyTanks = tanks
      ..playerTank = palyerTank;
  }
}

final httpClient = RetryClient(Client());

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  tileProvider: NetworkTileProvider(httpClient: httpClient),
);

class Tank {
  final LatLng position;
  final bool isMine;
  double angle;

  Tank({required this.position, this.isMine = false, this.angle = 0.0});
}

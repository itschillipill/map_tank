import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_tanks/constants.dart';
import 'package:map_tanks/widgets/button.dart';
import 'package:map_tanks/widgets/drawer.dart';
import 'dart:ui' as ui;

import 'render_box.dart';
import 'tank.dart';

class TanksMap extends StatefulWidget {
  const TanksMap({super.key});

  @override
  State<TanksMap> createState() => _TanksMapState();
}

class _TanksMapState extends State<TanksMap> with TickerProviderStateMixin {
  late final MapController mapController;
  int? _selectedIndex;
  final _tanksLayerKey = GlobalKey();
  TankSprite? sprite;
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
    $loadSprites();
  }

  void $loadSprites() async {
    final myTank = await loadUiImage(asset: Constants.myTankImageAsset);
    final enemyTank = await loadUiImage(asset: Constants.enemyTankImageAsset);
    setState(() => sprite = (myTank, enemyTank));
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<ui.Image> loadUiImage({required String asset}) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Constants.appName,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
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
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all ^ InteractiveFlag.rotate,
                ),
              ),
              children: <Widget>[
                openStreetMapTileLayer,
                if (sprite != null)
                  Positioned.fill(
                    child: IgnorePointer(
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
              ],
            ),
          ),

          Positioned(
            right: 10,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 16,
              children: [
                CustomButton(
                  heroTag: "zoom_in",
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 0.5,
                    );
                  },
                  icon: Icons.add,
                ),

                CustomButton(
                  heroTag: "zoom_out",
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 0.5,
                    );
                  },
                  icon: Icons.remove,
                ),

                CustomButton(
                  heroTag: "my_location",
                  onPressed: () {
                    mapController.move(
                      playerTank.position,
                      mapController.camera.zoom,
                    );
                  },
                  icon: Icons.my_location_outlined,
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
  final TankSprite sprite;

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
      tanksSprite: sprite,
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

import 'dart:ui' as ui;

import 'package:latlong2/latlong.dart';

class Tank {
  final LatLng position;
  final bool isMine;
  double angle;

  Tank({required this.position, this.isMine = false, this.angle = 0.0});
}

typedef TankSprite = (ui.Image myTankSprite, ui.Image enemyTankSprite);

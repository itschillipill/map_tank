import 'package:latlong2/latlong.dart';

class Explosion {
  LatLng position;
  double time = 0.0;
  final double duration = 0.3;
  bool finished = false;

  Explosion({required this.position});

  void update(double dt) {
    time += dt;
    if (time >= duration) finished = true;
  }

  double get progress => time / duration;
}

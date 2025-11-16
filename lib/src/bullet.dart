import 'package:latlong2/latlong.dart';

class Bullet {
  LatLng position;
  final LatLng target;
  final double flightTimeMs;
  bool finished = false;
  double _progress = 0.0;

  Bullet({
    required this.position,
    required this.target,
    this.flightTimeMs = 600,
  });

  void update(double dt) {
    if (finished) return;

    _progress += dt * 1000 / flightTimeMs;
    _progress = _progress.clamp(0.0, 1.0);

    final deltaLat = target.latitude - position.latitude;
    final deltaLng = target.longitude - position.longitude;

    position = LatLng(
      position.latitude + deltaLat * _progress,
      position.longitude + deltaLng * _progress,
    );

    if (_progress >= 1.0) {
      position = target;
      finished = true;
    }
  }
}

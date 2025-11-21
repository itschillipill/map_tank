import 'dart:math';
import 'dart:ui' as ui;
import 'explosion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'bullet.dart';
import 'tanks_map.dart';

class RenderTanksLayer extends RenderBox {
  MapController _mapController;
  Tank _playerTank;
  List<Tank> _enemyTanks;
  TickerProvider vsync;
  late final Ticker ticker;
  final List<Bullet> _bullets = [];
  final List<Explosion> _explosions = [];
  final ui.Image sprite;
  final Size tankSize = const Size(40, 40);
  final Paint tankPaint = Paint();
  final Paint explosionPainter = Paint()..style = PaintingStyle.fill;

  final bulletPaint =
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

  RenderTanksLayer(
    this._mapController,
    this._enemyTanks,
    this._playerTank, {
    required this.vsync,
    required this.sprite,
  }) {
    ticker = vsync.createTicker(_onTick);

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventTap) {
        final tapPos = _mapController.camera.getOffsetFromOrigin(
          event.tapPosition,
        );
        handleTap(tapPos);
      }
      markNeedsPaint();
    });
  }

  void shootBullet(LatLng target) {
    _bullets.add(Bullet(position: _playerTank.position, target: target));
    _playerTank.angle = getAngle(_playerTank.position, target);
    if (!ticker.isActive) ticker.start();
  }

  double getAngle(LatLng position, LatLng target) {
    final p1 = _mapController.camera.getOffsetFromOrigin(position);
    final p2 = _mapController.camera.getOffsetFromOrigin(target);

    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return atan2(dy, dx) + pi / 2;
  }

  void _onTick(_) {
    if (_bullets.isEmpty && _explosions.isEmpty) {
      ticker.stop();
      return;
    }

    const dt = 1 / 60.0;
    for (final b in _bullets) {
      b.update(dt);
    }
    final finishedBullets = _bullets.where((b) => b.finished).toList();

    for (final b in finishedBullets) {
      removeBullet(b);
    }
    for (final e in _explosions) {
      e.update(dt);
    }

    _explosions.removeWhere((e) => e.finished);

    markNeedsPaint();
  }

  void removeBullet(Bullet bullet) {
    _bullets.remove(bullet);
    _explosions.add(Explosion(position: bullet.target));
    _enemyTanks.removeWhere((t) => t.position == bullet.target);
  }

  bool _isOnScreen(Offset pixel, Size size) {
    return pixel.dx >= 0 &&
        pixel.dx <= size.width &&
        pixel.dy >= 0 &&
        pixel.dy <= size.height;
  }

  set mapController(MapController value) {
    if (value == _mapController) return;
    _mapController = value;
    markNeedsPaint();
  }

  set enemyTanks(List<Tank> value) {
    if (value == _enemyTanks) return;
    _enemyTanks = value;
    markNeedsPaint();
  }

  set playerTank(Tank value) {
    if (value == _playerTank) return;
    _playerTank = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  void handleTap(Offset tapPos) {
    bool hitEnemy = false;

    for (final t in _enemyTanks) {
      final pixel = _mapController.camera.getOffsetFromOrigin(t.position);
      final rect = Rect.fromCenter(
        center: pixel,
        width: tankSize.width,
        height: tankSize.height,
      );

      if (rect.contains(tapPos)) {
        shootBullet(t.position);
        hitEnemy = true;
        break;
      }
    }

    if (!hitEnemy) {
      final latlng = _mapController.camera.offsetToCrs(tapPos);
      shootBullet(latlng);
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void drawTank(Tank t, {Offset offset = Offset.zero, required Canvas canvas}) {
    final pixel = _mapController.camera.getOffsetFromOrigin(t.position);

    final srcRect = Rect.fromLTWH(
      0,
      0,
      sprite.width.toDouble(),
      sprite.height.toDouble(),
    );

    canvas.save();

    final center = pixel + offset;
    canvas.translate(center.dx, center.dy);

    canvas.rotate(t.angle);

    final dstRect = Rect.fromCenter(
      center: Offset.zero,
      width: tankSize.width,
      height: tankSize.height,
    );
    canvas.drawImageRect(sprite, srcRect, dstRect, tankPaint);
    canvas.restore();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final bulletPoints = <Offset>[];

    for (final b in _bullets) {
      final pixel = _mapController.camera.getOffsetFromOrigin(b.position);
      if (!_isOnScreen(pixel, size)) continue;
      bulletPoints.add(pixel + offset);
    }

    drawTank(_playerTank, canvas: canvas, offset: offset);

    for (int i = 0; i < _enemyTanks.length; i++) {
      drawTank(_enemyTanks[i], canvas: canvas, offset: offset);
    }

    for (final e in _explosions) {
      final pixel = _mapController.camera.getOffsetFromOrigin(e.position);
      final p = pixel + offset;
      final progress = e.progress.clamp(0.0, 1.0);

      final radius = 20.0 * progress;
      final opacity = (1.0 - progress);

      final paint =
          explosionPainter..color = Colors.orange.withValues(alpha: opacity);

      canvas.drawCircle(p, radius, paint);

      canvas.drawCircle(
        p,
        radius * 0.6,
        explosionPainter..color = Colors.yellow.withValues(alpha: opacity),
      );
    }

    canvas.drawPoints(ui.PointMode.points, bulletPoints, bulletPaint);
  }
}

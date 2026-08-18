import 'dart:math' as math;

import 'package:glint_engine/glint_engine.dart';

import '../../data/listing.dart';

double _shortestTurn(double from, double to) {
  var delta = (to - from) % (math.pi * 2);
  if (delta > math.pi) delta -= math.pi * 2;
  if (delta < -math.pi) delta += math.pi * 2;
  return from + delta;
}

double _easeInOutCubic(double t) =>
    t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

/// Drives the first-person camera: drag to look, glide between rooms.
///
/// Kept deliberately free of Flutter state so it can be stepped straight from
/// `GlintGameView.onFrame` with the real frame delta.
class WalkController {
  WalkController(this.waypoints) {
    final first = waypoints.first;
    _position = first.eye;
    final aim = _aimAt(first.eye, first.focus);
    _yaw = aim.$1;
    _pitch = aim.$2;
  }

  final List<RoomWaypoint> waypoints;

  static const _glideSeconds = 1.15;
  static const _maxPitch = math.pi / 2 * 0.82;

  late Vector3 _position;
  late double _yaw;
  late double _pitch;

  int _currentIndex = 0;
  double _glide = 1;
  Vector3 _fromPosition = Vector3.zero;
  double _fromYaw = 0;
  double _fromPitch = 0;

  int get currentIndex => _currentIndex;
  bool get isTravelling => _glide < 1;

  /// Yaw/pitch that looks from [eye] toward [focus].
  static (double, double) _aimAt(Vector3 eye, Vector3 focus) {
    final d = focus - eye;
    final yaw = math.atan2(d.x, -d.z);
    final horizontal = math.sqrt(d.x * d.x + d.z * d.z);
    final pitch = math.atan2(d.y, horizontal);
    return (yaw, pitch);
  }

  /// Look direction as a unit vector.
  Vector3 get _forward {
    final cosPitch = math.cos(_pitch);
    return Vector3(
      math.sin(_yaw) * cosPitch,
      math.sin(_pitch),
      -math.cos(_yaw) * cosPitch,
    );
  }

  /// One-finger drag rotates the view.
  void look(double dxPixels, double dyPixels) {
    if (isTravelling) return;
    const sensitivity = 0.0055;
    _yaw += dxPixels * sensitivity;
    _pitch = (_pitch - dyPixels * sensitivity).clamp(-_maxPitch, _maxPitch);
  }

  void goTo(int index) {
    if (index < 0 || index >= waypoints.length || index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    _fromPosition = _position;
    _fromYaw = _yaw;
    _fromPitch = _pitch;
    _glide = 0;
  }

  /// Advances any in-flight glide. Call once per frame.
  void update(double dt) {
    if (_glide >= 1) return;
    _glide = math.min(1, _glide + dt / _glideSeconds);
    final t = _easeInOutCubic(_glide);
    final target = waypoints[_currentIndex];
    final aim = _aimAt(target.eye, target.focus);

    _position = _fromPosition + (target.eye - _fromPosition) * t;
    _yaw = _fromYaw + (_shortestTurn(_fromYaw, aim.$1) - _fromYaw) * t;
    _pitch = _fromPitch + (aim.$2 - _fromPitch) * t;
  }

  GlintGameCamera get camera => GlintGameCamera(
    position: _position,
    target: _position + _forward,
    fieldOfViewDegrees: 62,
    near: 0.05,
    far: 60,
  );
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view_web/photo_view_web.dart';

/// Controller for PhotoViewWeb widget
/// 
/// Allows programmatic control of scale, position, and rotation
class PhotoViewController {
  PhotoViewController({
    double initialScale = 1.0,
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
  })  : _scale = initialScale,
        _position = initialPosition,
        _rotation = initialRotation {
    _valueController = StreamController<PhotoViewControllerValue>.broadcast();
    _notifyListeners();
  }

  double _scale;
  Offset _position;
  double _rotation;
  Offset? _rotationFocusPoint;

  late StreamController<PhotoViewControllerValue> _valueController;

  /// Stream of controller value changes
  Stream<PhotoViewControllerValue> get outputStateStream =>
      _valueController.stream;

  /// Current controller value
  PhotoViewControllerValue get value => PhotoViewControllerValue(
        position: _position,
        scale: _scale,
        rotation: _rotation,
        rotationFocusPoint: _rotationFocusPoint,
      );

  /// Current scale value
  double get scale => _scale;

  /// Current position value
  Offset get position => _position;

  /// Current rotation value (in degrees)
  double get rotation => _rotation;

  /// Current rotation focus point
  Offset? get rotationFocusPoint => _rotationFocusPoint;

  /// Set the scale value
  void setScale(double scale) {
    _scale = scale;
    _notifyListeners();
  }

  /// Set the position value
  void setPosition(Offset position) {
    _position = position;
    _notifyListeners();
  }

  /// Set the rotation value (in degrees)
  void setRotation(double rotation, {Offset? rotationFocusPoint}) {
    _rotation = rotation;
    _rotationFocusPoint = rotationFocusPoint;
    _notifyListeners();
  }

  /// Reset to initial values
  void reset() {
    _scale = 1.0;
    _position = Offset.zero;
    _rotation = 0.0;
    _rotationFocusPoint = null;
    _notifyListeners();
  }

  /// Update the controller value
  void updateValue(PhotoViewControllerValue newValue) {
    _scale = newValue.scale;
    _position = newValue.position;
    _rotation = newValue.rotation;
    _rotationFocusPoint = newValue.rotationFocusPoint;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_valueController.isClosed) {
      _valueController.add(value);
    }
  }

  /// Dispose the controller
  void dispose() {
    _valueController.close();
  }
}

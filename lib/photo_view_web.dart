library photo_view_web;

import 'package:flutter/material.dart';

export 'src/photo_view_web_widget.dart';
export 'src/photo_view_controller.dart';
export 'src/photo_view_scale_state_controller.dart';
export 'src/photo_view_computed_scale.dart';
export 'src/photo_view_hero_attributes.dart';
export 'src/core/photo_view_core_utils.dart';

// Type definitions
typedef PhotoViewImageTapUpCallback = void Function(
  BuildContext context,
  TapUpDetails details,
  PhotoViewControllerValue controllerValue,
);

typedef PhotoViewImageTapDownCallback = void Function(
  BuildContext context,
  TapDownDetails details,
  PhotoViewControllerValue controllerValue,
);

typedef PhotoViewImageScaleEndCallback = void Function(
  BuildContext context,
  ScaleEndDetails details,
  PhotoViewControllerValue controllerValue,
);

typedef LoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);

typedef ErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

// Enums
enum PhotoViewScaleState {
  initial,
  covering,
  originalSize,
  zoomedIn,
  zoomedOut,
}

enum ScaleStateCycle {
  doubleTap,
  tripleState,
  noScale,
}

// Value classes
class PhotoViewControllerValue {
  const PhotoViewControllerValue({
    required this.position,
    required this.scale,
    required this.rotation,
    this.rotationFocusPoint,
  });

  final Offset position;
  final double scale;
  final double rotation;
  final Offset? rotationFocusPoint;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoViewControllerValue &&
        other.position == position &&
        other.scale == scale &&
        other.rotation == rotation &&
        other.rotationFocusPoint == rotationFocusPoint;
  }

  @override
  int get hashCode {
    return Object.hash(position, scale, rotation, rotationFocusPoint);
  }

  @override
  String toString() {
    return 'PhotoViewControllerValue(position: $position, scale: $scale, rotation: $rotation, rotationFocusPoint: $rotationFocusPoint)';
  }
}



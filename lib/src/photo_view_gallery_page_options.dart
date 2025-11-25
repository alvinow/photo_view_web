import 'package:flutter/material.dart';
import 'package:photo_view_web/photo_view_web.dart';

class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions({
    required this.imageProvider,
    this.heroAttributes,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.controller,
    this.scaleStateController,
    this.basePosition,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    this.tightMode = false,
    this.filterQuality = FilterQuality.none,
    this.disableGestures = false,
    this.errorBuilder,
  });

  final ImageProvider imageProvider;
  final PhotoViewHeroAttributes? heroAttributes;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final PhotoViewController? controller;
  final PhotoViewScaleStateController? scaleStateController;
  final Alignment? basePosition;
  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final PhotoViewImageScaleEndCallback? onScaleEnd;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final ErrorBuilder? errorBuilder;
}

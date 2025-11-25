import 'package:flutter/material.dart';
import 'package:photo_view_web/photo_view_web.dart';
import 'package:photo_view_web/src/photo_view_gallery_page_options.dart';

class PhotoViewGalleryWeb extends StatefulWidget {
  const PhotoViewGalleryWeb({
    super.key,
    required this.pageOptions,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
  }) : itemCount = null, builder = null;

  const PhotoViewGalleryWeb.builder({
    super.key,
    required this.itemCount,
    required this.builder,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
  }) : pageOptions = null;

  final List<PhotoViewGalleryPageOptions>? pageOptions;
  final int? itemCount;
  final PhotoViewGalleryPageOptions Function(BuildContext, int)? builder;
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final bool gaplessPlayback;
  final bool reverse;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;
  final bool enableRotation;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;
  final Size? customSize;

  @override
  State<PhotoViewGalleryWeb> createState() => _PhotoViewGalleryWebState();
}

class _PhotoViewGalleryWebState extends State<PhotoViewGalleryWeb> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.pageController ?? PageController();
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  int get _itemCount {
    if (widget.pageOptions != null) return widget.pageOptions!.length;
    return widget.itemCount!;
  }

  PhotoViewGalleryPageOptions _buildPageOption(BuildContext context, int index) {
    if (widget.pageOptions != null) return widget.pageOptions![index];
    return widget.builder!(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      physics: widget.scrollPhysics,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      itemCount: _itemCount,
      itemBuilder: (context, index) {
        final options = _buildPageOption(context, index);
        return ClipRect(
          child: PhotoViewWeb(
            key: ObjectKey(index),
            imageProvider: options.imageProvider,
            loadingBuilder: widget.loadingBuilder,
            backgroundDecoration: widget.backgroundDecoration,
            minScale: options.minScale,
            maxScale: options.maxScale,
            initialScale: options.initialScale,
            basePosition: options.basePosition,
            controller: options.controller,
            scaleStateController: options.scaleStateController,
            enableRotation: widget.enableRotation,
            disableGestures: options.disableGestures,
            gaplessPlayback: widget.gaplessPlayback,
            customSize: widget.customSize,
            heroAttributes: options.heroAttributes,
            onTapUp: options.onTapUp,
            onTapDown: options.onTapDown,
            onScaleEnd: options.onScaleEnd,
            filterQuality: options.filterQuality,
          ),
        );
      },
    );
  }
}

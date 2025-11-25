import 'dart:async';
import 'dart:ui';
import 'dart:js_interop';
import 'package:flutter/material.dart';

import 'package:photo_view_web/photo_view_web.dart';
import 'package:photo_view_web/src/js_interop.dart' as js_interop;
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class PhotoViewWeb extends StatefulWidget {
  const PhotoViewWeb({
    super.key,
    required this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition,
    this.controller,
    this.scaleStateController,
    this.enableRotation = false,
    this.enablePanAlways = false,
    this.disableGestures = false,
    this.gaplessPlayback = false,
    this.customSize,
    this.heroAttributes,
    this.scaleStateCycle = ScaleStateCycle.doubleTap,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.filterQuality = FilterQuality.none,
    this.enableInstagramZoom = false,
  });

  final ImageProvider imageProvider;
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment? basePosition;
  final PhotoViewController? controller;
  final PhotoViewScaleStateController? scaleStateController;
  final bool enableRotation;
  final bool enablePanAlways;
  final bool disableGestures;
  final bool gaplessPlayback;
  final Size? customSize;
  final PhotoViewHeroAttributes? heroAttributes;
  final ScaleStateCycle scaleStateCycle;
  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final PhotoViewImageScaleEndCallback? onScaleEnd;
  final FilterQuality filterQuality;
  final bool enableInstagramZoom;

  @override
  State<PhotoViewWeb> createState() => _PhotoViewWebState();
}

class _PhotoViewWebState extends State<PhotoViewWeb> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final String _viewId = 'photo_view_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond)}';
  late PhotoViewController _controller;
  late PhotoViewScaleStateController _scaleStateController;
  bool _externalController = false;
  bool _externalScaleStateController = false;
  
  final Completer<void> _viewCreated = Completer<void>();
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PhotoViewController();
    _externalController = widget.controller != null;
    
    _scaleStateController = widget.scaleStateController ?? PhotoViewScaleStateController();
    _externalScaleStateController = widget.scaleStateController != null;
    
    // Listen to controller changes to update JS
    _controller.outputStateStream.listen(_onControllerChange);
    _scaleStateController.outputScaleStateStream.listen(_onScaleStateChange);
    
    // Register the view factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final element = web.document.createElement('div') as web.HTMLDivElement;
        element.id = _viewId;
        element.style.width = '100%';
        element.style.height = '100%';
        
        // Register the element directly with JS to avoid DOM search issues
        js_interop.registerPhotoViewElement(_viewId.toJS, element as JSObject);
        
        // Signal that view is created
        if (!_viewCreated.isCompleted) {
          _viewCreated.complete();
        }
        
        return element;
      },
    );

    // Initialize JS handler immediately after view creation
    _initializeJsHandler();
  }

  @override
  void didUpdateWidget(PhotoViewWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      // Re-initialize if image changes
      _initializeJsHandler();
    }
  }

  void _initializeJsHandler() {
    // Resolve image URL
    String? imageUrl;
    if (widget.imageProvider is NetworkImage) {
      imageUrl = (widget.imageProvider as NetworkImage).url;
    } else if (widget.imageProvider is AssetImage) {
      imageUrl = 'assets/${(widget.imageProvider as AssetImage).assetName}';
    } else if (widget.imageProvider is MemoryImage) {
      final bytes = (widget.imageProvider as MemoryImage).bytes;
      final blob = web.Blob([bytes.toJS].toJS);
      imageUrl = web.URL.createObjectURL(blob);
    } else {
      print('Warning: Unsupported ImageProvider type: ${widget.imageProvider.runtimeType}');
      return;
    }

    // Wait for view creation and then initialize JS
    _viewCreated.future.then((_) {
      if (!mounted) return;
      
      final options = js_interop.PhotoViewOptions(
        initialScale: 1.0,
        minScale: widget.minScale is double ? widget.minScale : 0.0,
        maxScale: widget.maxScale is double ? widget.maxScale : 1000.0,
        enableRotation: widget.enableRotation,
        enablePan: true,
        disableGestures: widget.disableGestures,
        enableInstagramZoom: widget.enableInstagramZoom,
        onScaleUpdate: ((double scale) {
          _controller.setScale(scale);
        }).toJS,
        onPanUpdate: ((double x, double y) {
          _controller.setPosition(Offset(x, y));
        }).toJS,
        onRotateUpdate: ((double rotation) {
          _controller.setRotation(rotation);
        }).toJS,
        onTap: ((double x, double y) {
          if (widget.onTapUp != null) {
            widget.onTapUp!(
              context, 
              TapUpDetails(kind: PointerDeviceKind.touch, globalPosition: Offset.zero, localPosition: Offset(x, y)), 
              _controller.value
            );
          }
        }).toJS,
        onDoubleTap: ((double x, double y) {
           final nextState = PhotoViewCoreUtils.nextScaleState(
             _scaleStateController.scaleState, 
             widget.scaleStateCycle
           );
           _scaleStateController.setScaleState(nextState);
        }).toJS,
      );

      js_interop.createPhotoViewHandler(
        _viewId.toJS,
        imageUrl!.toJS,
        options as JSObject,
      );
    });
  }
  
  void _onControllerChange(PhotoViewControllerValue value) {
    // Optional: Sync back to JS if needed
  }
  
  void _onScaleStateChange(PhotoViewScaleState state) {
    final handler = js_interop.getPhotoViewHandler(_viewId.toJS);
    if (handler != null) {
      if (state == PhotoViewScaleState.initial) {
        (handler as js_interop.PhotoViewHandler).reset(true);
      } else if (state == PhotoViewScaleState.zoomedIn) {
        (handler as js_interop.PhotoViewHandler).setScale(2.0, true);
      }
    }
  }

  @override
  void dispose() {
    if (!_externalController) {
      _controller.dispose();
    }
    if (!_externalScaleStateController) {
      _scaleStateController.dispose();
    }
    
    js_interop.disposePhotoViewHandler(_viewId.toJS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    Widget content = HtmlElementView(viewType: _viewId);

    if (widget.heroAttributes != null) {
      content = Hero(
        tag: widget.heroAttributes!.tag,
        transitionOnUserGestures: widget.heroAttributes!.transitionOnUserGestures,
        child: content,
      );
    }

    return Container(
      decoration: widget.backgroundDecoration,
      child: content,
    );
  }
}

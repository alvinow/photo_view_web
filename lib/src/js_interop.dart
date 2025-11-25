import 'dart:js_interop';


@JS()
external void createPhotoViewHandler(
  JSString containerId,
  JSString imageUrl,
  JSObject options,
);

@JS()
external void disposePhotoViewHandler(JSString containerId);

@JS()
external JSObject? getPhotoViewHandler(JSString containerId);

@JS()
external void registerPhotoViewElement(JSString containerId, JSObject element);

@JS()
@anonymous
extension type PhotoViewHandler._(JSObject _) implements JSObject {
  external void setScale(double scale, bool animated);
  external void setPosition(double x, double y, bool animated);
  external void setRotation(double rotation, bool animated);
  external void reset(bool animated);
  external void updateImage(JSString imageUrl);
}

@JS()
@anonymous
extension type PhotoViewOptions._(JSObject _) implements JSObject {
  external factory PhotoViewOptions({
    double? initialScale,
    double? minScale,
    double? maxScale,
    bool? enableRotation,
    bool? enablePan,
    bool? disableGestures,
    JSFunction? onScaleUpdate,
    JSFunction? onPanUpdate,
    JSFunction? onRotateUpdate,
    JSFunction? onTap,
    JSFunction? onDoubleTap,
    bool? enableInstagramZoom,
    bool? enableDebug,
  });
}

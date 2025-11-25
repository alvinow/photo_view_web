
import 'package:photo_view_web/photo_view_web.dart';

class PhotoViewCoreUtils {
  static bool isScaleStateCycle(ScaleStateCycle? cycle) {
    return cycle != null && cycle != ScaleStateCycle.noScale;
  }

  static double clampScale(double scale, double min, double max) {
    return scale.clamp(min, max);
  }
  
  static PhotoViewScaleState nextScaleState(
    PhotoViewScaleState actual,
    ScaleStateCycle cycle,
  ) {
    switch (cycle) {
      case ScaleStateCycle.doubleTap:
        switch (actual) {
          case PhotoViewScaleState.initial:
          case PhotoViewScaleState.zoomedOut:
          case PhotoViewScaleState.originalSize:
          case PhotoViewScaleState.covering:
            return PhotoViewScaleState.zoomedIn;
          case PhotoViewScaleState.zoomedIn:
            return PhotoViewScaleState.initial;
        }
      case ScaleStateCycle.tripleState:
        switch (actual) {
          case PhotoViewScaleState.initial:
          case PhotoViewScaleState.zoomedOut:
            return PhotoViewScaleState.zoomedIn;
          case PhotoViewScaleState.zoomedIn:
            return PhotoViewScaleState.originalSize;
          case PhotoViewScaleState.originalSize:
          case PhotoViewScaleState.covering:
            return PhotoViewScaleState.initial;
        }
      case ScaleStateCycle.noScale:
        return actual;
    }
  }
}

import 'dart:async';
import 'package:photo_view_web/photo_view_web.dart';

/// Controller for managing scale state changes
class PhotoViewScaleStateController {
  PhotoViewScaleStateController({
    PhotoViewScaleState initialState = PhotoViewScaleState.initial,
  }) : _scaleState = initialState {
    _stateController = StreamController<PhotoViewScaleState>.broadcast();
    _notifyListeners();
  }

  PhotoViewScaleState _scaleState;
  late StreamController<PhotoViewScaleState> _stateController;

  /// Stream of scale state changes
  Stream<PhotoViewScaleState> get outputScaleStateStream =>
      _stateController.stream;

  /// Current scale state
  PhotoViewScaleState get scaleState => _scaleState;

  /// Set the scale state
  void setScaleState(PhotoViewScaleState state) {
    if (_scaleState != state) {
      _scaleState = state;
      _notifyListeners();
    }
  }

  /// Reset to initial state
  void reset() {
    setScaleState(PhotoViewScaleState.initial);
  }

  void _notifyListeners() {
    if (!_stateController.isClosed) {
      _stateController.add(_scaleState);
    }
  }

  /// Dispose the controller
  void dispose() {
    _stateController.close();
  }
}

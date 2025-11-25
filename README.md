# Photo View Web

A Flutter web-optimized fork of the popular [photo_view](https://pub.dev/packages/photo_view) package. This package solves the touch gesture issues on Flutter web by using a hybrid approach: Flutter for the container and layout, and JavaScript (Hammer.js) for reliable gesture handling.

## Features

- 👆 **Reliable Gestures**: Uses Hammer.js for smooth pinch-to-zoom, pan, and rotation on web.
- 📱 **Mobile & Desktop Web**: Works great on both touch devices and mouse input.
- 🖼️ **Gallery Support**: Includes `PhotoViewGalleryWeb` for swiping between multiple images.
- 📸 **Instagram-style Zoom**: Optional "snap-back" animation when releasing a pinch gesture.
- 🎮 **Controllers**: Full programmatic control via `PhotoViewController` and `PhotoViewScaleStateController`.
- 🔄 **API Compatible**: Designed to be a drop-in replacement for the original `photo_view` package.

## Installation

Add `photo_view_web` to your `pubspec.yaml`:

```yaml
dependencies:
  photo_view_web:
    path: /path/to/photo_view_web # Or git url
```

## Setup

You must include the JavaScript assets in your `web/index.html`. 
If you are using this as a package, Flutter should automatically include the assets declared in `pubspec.yaml`.
However, ensure your `web/index.html` has the scripts if they are not automatically injected:

```html
<script src="assets/packages/photo_view_web/web/hammer.min.js"></script>
<script src="assets/packages/photo_view_web/web/photo_view_handler.js"></script>
```

## Usage

### Basic Usage

```dart
import 'package:photo_view_web/photo_view_web.dart';

@override
Widget build(BuildContext context) {
  return Container(
    child: PhotoViewWeb(
      imageProvider: AssetImage("assets/large-image.jpg"),
      minScale: 0.1,
      maxScale: 4.0,
      enableRotation: true,
      enableInstagramZoom: true, // Snap back on release
    )
  );
}
```

### Gallery

```dart
import 'package:photo_view_web/photo_view_gallery_web.dart';

@override
Widget build(BuildContext context) {
  return PhotoViewGalleryWeb.builder(
    itemCount: imageList.length,
    builder: (context, index) {
      return PhotoViewGalleryPageOptions(
        imageProvider: NetworkImage(imageList[index]),
        minScale: 0.5,
        maxScale: 4.0,
        heroAttributes: PhotoViewHeroAttributes(tag: index),
      );
    },
    scrollPhysics: BouncingScrollPhysics(),
    backgroundDecoration: BoxDecoration(color: Colors.black),
  );
}
```

### Controllers

```dart
class _MyState extends State<MyWidget> {
  late PhotoViewController controller;

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoViewWeb(
      imageProvider: AssetImage("assets/image.jpg"),
      controller: controller,
    );
  }
  
  void rotate() {
    controller.setRotation(controller.rotation + 90);
  }
}
```

## Development & Contributing

If you want to fork and develop this package, follow these steps:

### Project Structure

- **`lib/`**: Contains the Dart code.
    - `src/photo_view_web_widget.dart`: The main Flutter widget.
    - `src/js_interop.dart`: The bridge between Dart and JavaScript.
- **`web/`**: Contains the JavaScript logic.
    - `photo_view_handler.js`: The core logic using Hammer.js. This is where gesture handling, transforms, and animations are implemented.
    - `hammer.min.js`: The Hammer.js library.
- **`example/`**: A complete Flutter example app to test changes.

### Running the Example

1.  Go to the example directory:
    ```bash
    cd example
    ```
2.  Run on Chrome:
    ```bash
    flutter run -d chrome
    ```

### Modifying JavaScript Logic

The core gesture handling logic resides in `web/photo_view_handler.js`.
-   **`init()`**: Initializes the handler and finds the container.
-   **`setup()`**: Creates the `<img>` element and binds Hammer.js events.
-   **`handlePinch`, `handlePan`, `handleRotate`**: Process gesture events and update state.
-   **`applyTransform()`**: Applies CSS transforms to the image.

**Tip**: After modifying `photo_view_handler.js`, you usually need to restart the Flutter app (Hot Restart `R`) to reload the JavaScript.

### Modifying Dart-JS Interop

If you add new features to the JS handler (e.g., new options or callbacks), you need to update `lib/src/js_interop.dart` to match the JavaScript API.

1.  Update `PhotoViewOptions` factory to include new parameters.
2.  Update `PhotoViewHandler` extension type if you added new public methods in JS.

### Contributing

1.  Fork the repository.
2.  Create a feature branch.
3.  Make your changes.
4.  Verify with the example app.
5.  Submit a Pull Request.

## Limitations

- This package is **strictly for Flutter Web**. It uses `dart:js_interop` and HTML elements.
- Custom child widgets (other than images) are not fully supported yet. The focus is on high-performance image viewing.

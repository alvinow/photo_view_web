/*! PhotoView Web Handler - Gesture management using Hammer.js */

class PhotoViewHandler {
  constructor(containerId, imageUrl, options) {
    this.containerId = containerId;
    // Container will be resolved in init()
    this.imageUrl = imageUrl;
    this.options = options || {};

    // Transform state
    this.scale = this.options.initialScale || 1.0;
    this.posX = 0;
    this.posY = 0;
    this.rotation = 0;

    // Gesture state
    this.lastScale = 1.0;
    this.lastRotation = 0;
    this.lastPosX = 0;
    this.lastPosY = 0;
    this.rotationThreshold = 15; // Minimum rotation in degrees to START rotating (increased from 5)
    this.rotationEnabled = false; // Rotation only enabled after delay
    this.rotationDelayMs = 500; // Delay before rotation activates
    this.maxRotationSpeed = 5; // Maximum degrees per frame (increased for responsiveness)
    this.rotationDamping = 0.5; // Damping factor (0-1, higher = more responsive)
    this.totalRotation = 0; // Track total rotation during gesture

    // Constraints
    this.minScale = this.options.minScale || 0.5;
    this.maxScale = this.options.maxScale || 4.0;
    this.enableRotation = this.options.enableRotation !== false;
    this.enablePan = this.options.enablePan !== false;
    this.disableGestures = this.options.disableGestures || false;
    this.enableInstagramZoom = this.options.enableInstagramZoom || false;
    this.enableDebug = this.options.enableDebug || false;

    if (this.enableDebug) {
      console.log('PhotoViewHandler initialized with options:', this.options);
    }

    // Callbacks
    this.onScaleUpdate = this.options.onScaleUpdate || (() => { });
    this.onPanUpdate = this.options.onPanUpdate || (() => { });
    this.onRotateUpdate = this.options.onRotateUpdate || (() => { });
    this.onTap = this.options.onTap || (() => { });
    this.onDoubleTap = this.options.onDoubleTap || (() => { });

    this.init();
  }

  init(retries = 0) {
    // Try to get from registry first (direct reference from Dart)
    if (window.photoViewElements && window.photoViewElements[this.containerId]) {
      this.container = window.photoViewElements[this.containerId];
    } else {
      // Fallback to DOM search
      this.container = document.getElementById(this.containerId);
    }

    if (!this.container) {
      if (retries < 20) {
        setTimeout(() => this.init(retries + 1), 50);
        return;
      }
      console.error('Container not found:', this.containerId);
      return;
    }

    this.setup();
  }

  setup() {
    if (!this.container) return;

    // Create image element
    this.imageElement = document.createElement('img');
    this.imageElement.src = this.imageUrl;
    this.imageElement.style.cssText = `
      width: 100%;
      height: 100%;
      object-fit: contain;
      user-select: none;
      -webkit-user-select: none;
      touch-action: none;
      transform-origin: center center;
    `;

    this.container.appendChild(this.imageElement);
    this.container.style.cssText = `
      width: 100%;
      height: 100%;
      overflow: hidden;
      position: relative;
      touch-action: none;
      -webkit-user-drag: none;
      display: flex;
      justify-content: center;
      align-items: center;
    `;

    if (this.disableGestures) {
      this.applyTransform();
      return;
    }

    // Initialize Hammer.js
    this.hammer = new Hammer.Manager(this.container);

    // Add recognizers
    const pinch = new Hammer.Pinch();
    const pan = new Hammer.Pan();
    const rotate = new Hammer.Rotate();
    const tap = new Hammer.Tap();
    const doubleTap = new Hammer.Tap({ event: 'doubletap', taps: 2 });

    // Enable simultaneous recognition
    pinch.recognizeWith([pan, rotate]);
    pan.recognizeWith(rotate);
    tap.requireFailure(doubleTap);

    this.hammer.add([pinch, rotate, pan, tap, doubleTap]);

    // Bind events
    this.hammer.on('pinchstart', (e) => {
      if (this.enableDebug) console.log('Pinch start', e);
    });
    this.hammer.on('pinchmove', this.handlePinch.bind(this));
    this.hammer.on('pinchend', this.handlePinchEnd.bind(this));
    this.hammer.on('pinchcancel', (e) => {
      if (this.enableDebug) console.log('Pinch cancel', e);
    });

    if (this.enableRotation) {
      this.hammer.on('rotatestart', (e) => {
        // Reset total rotation tracker
        this.totalRotation = 0;
        this.rotationEnabled = false;
        if (this.rotationTimer) {
          clearTimeout(this.rotationTimer);
        }
        this.rotationTimer = setTimeout(() => {
          this.rotationEnabled = true;
          if (this.enableDebug) {
            console.log('Rotation enabled after delay');
          }
        }, this.rotationDelayMs);
      });
      this.hammer.on('rotatemove', this.handleRotate.bind(this));
      this.hammer.on('rotateend', this.handleRotateEnd.bind(this));
    }

    if (this.enablePan) {
      this.hammer.on('panstart panmove', this.handlePan.bind(this));
      this.hammer.on('panend', this.handlePanEnd.bind(this));
    }

    this.hammer.on('tap', this.handleTap.bind(this));
    this.hammer.on('doubletap', this.handleDoubleTap.bind(this));

    // Apply initial transform
    this.applyTransform();

    // Add wheel listener for trackpad support
    this.container.addEventListener('wheel', this.handleWheel.bind(this), { passive: false });
  }

  handleWheel(event) {
    event.preventDefault();

    if (event.ctrlKey) {
      // Zoom
      const zoomFactor = 0.01;
      const newScale = this.scale - (event.deltaY * zoomFactor);
      this.setScale(newScale, false);

      // Instagram zoom: reset after user stops zooming
      if (this.enableInstagramZoom) {
        // Clear previous timeout
        if (this.zoomResetTimeout) {
          clearTimeout(this.zoomResetTimeout);
        }

        // Set new timeout to reset after 500ms of no zoom activity
        this.zoomResetTimeout = setTimeout(() => {
          if (this.enableDebug) {
            console.log('Wheel zoom ended, resetting...');
          }
          this.reset(true);
        }, 500);
      }
    } else {
      // Pan
      if (!this.enablePan) return;
      this.posX -= event.deltaX;
      this.posY -= event.deltaY;

      // Apply boundaries and centering
      if (this.scale <= 1.0) {
        this.posX = 0;
        this.posY = 0;
      } else {
        // Calculate boundaries
        const rect = this.imageElement.getBoundingClientRect();
        const containerRect = this.container.getBoundingClientRect();

        // If image width is smaller than container, center X
        if (rect.width <= containerRect.width) {
          this.posX = 0;
        }

        // If image height is smaller than container, center Y
        if (rect.height <= containerRect.height) {
          this.posY = 0;
        }
      }

      this.applyTransform();
      this.onPanUpdate(this.posX, this.posY);
    }
  }

  handlePinch(event) {
    if (this.enableDebug) {
      console.log('Pinch move. Scale:', event.scale);
    }
    const newScale = this.lastScale * event.scale;
    this.scale = Math.max(this.minScale, Math.min(this.maxScale, newScale));
    this.applyTransform();
    this.onScaleUpdate(this.scale);
  }

  handlePinchEnd(event) {
    this.lastScale = this.scale;

    if (this.enableDebug) {
      console.log('Pinch end. Scale:', this.scale, 'EnableInstagramZoom:', this.enableInstagramZoom);
    }

    if (this.enableInstagramZoom) {
      if (this.enableDebug) {
        console.log('Resetting zoom...');
      }
      this.reset(true);
    }
  }

  handleRotate(event) {
    if (!this.enableRotation) return;
    
    // Track total rotation during this gesture
    this.totalRotation = Math.abs(event.rotation);
    
    // Only apply rotation after delay AND if total rotation exceeds threshold
    if (!this.rotationEnabled || this.totalRotation < this.rotationThreshold) {
      if (this.enableDebug && this.totalRotation > 0) {
        console.log('Rotation detected but below threshold:', this.totalRotation, '/', this.rotationThreshold);
      }
      return;
    }
    
    // Calculate target rotation
    const targetRotation = this.lastRotation + event.rotation;
    
    // Calculate rotation delta
    let rotationDelta = targetRotation - this.rotation;
    
    // Limit rotation speed to prevent jumps
    if (Math.abs(rotationDelta) > this.maxRotationSpeed) {
      rotationDelta = Math.sign(rotationDelta) * this.maxRotationSpeed;
    }
    
    // Apply damping for smooth rotation
    this.rotation += rotationDelta * this.rotationDamping;
    
    this.applyTransform();
    this.onRotateUpdate(this.rotation);
  }

  handleRotateEnd(event) {
    this.lastRotation = this.rotation;
    this.rotationEnabled = false;
    this.totalRotation = 0;
    if (this.rotationTimer) {
      clearTimeout(this.rotationTimer);
    }
  }

  handlePan(event) {
    if (!this.enablePan) return;

    // Calculate new position
    this.posX = this.lastPosX + event.deltaX;
    this.posY = this.lastPosY + event.deltaY;

    // Apply boundaries when not zoomed
    if (this.scale <= 1.0) {
      this.posX = 0;
      this.posY = 0;
    }

    this.applyTransform();
    this.onPanUpdate(this.posX, this.posY);
  }

  handlePanEnd(event) {
    this.lastPosX = this.posX;
    this.lastPosY = this.posY;
  }

  handleTap(event) {
    const rect = this.container.getBoundingClientRect();
    const x = event.center.x - rect.left;
    const y = event.center.y - rect.top;
    this.onTap(x, y);
  }

  handleDoubleTap(event) {
    // Toggle between min and max scale
    const targetScale = this.scale > 1.0 ? 1.0 : 2.0;
    this.setScale(targetScale);
    this.onDoubleTap(event.center.x, event.center.y);
  }

  applyTransform() {
    if (!this.imageElement) return;

    const transform = `translate(${this.posX}px, ${this.posY}px) scale(${this.scale}) rotate(${this.rotation}deg)`;
    this.imageElement.style.transform = transform;
    this.imageElement.style.webkitTransform = transform;
  }

  // Public API methods
  setScale(scale, animated = true) {
    this.scale = Math.max(this.minScale, Math.min(this.maxScale, scale));
    this.lastScale = this.scale;

    if (animated) {
      this.imageElement.style.transition = 'transform 0.3s ease-out';
      setTimeout(() => {
        this.imageElement.style.transition = '';
      }, 300);
    }

    this.applyTransform();
    this.onScaleUpdate(this.scale);
  }

  setPosition(x, y, animated = true) {
    this.posX = x;
    this.posY = y;
    this.lastPosX = x;
    this.lastPosY = y;

    if (animated) {
      this.imageElement.style.transition = 'transform 0.3s ease-out';
      setTimeout(() => {
        this.imageElement.style.transition = '';
      }, 300);
    }

    this.applyTransform();
    this.onPanUpdate(this.posX, this.posY);
  }

  setRotation(rotation, animated = true) {
    this.rotation = rotation;
    this.lastRotation = rotation;

    if (animated) {
      this.imageElement.style.transition = 'transform 0.3s ease-out';
      setTimeout(() => {
        this.imageElement.style.transition = '';
      }, 300);
    }

    this.applyTransform();
    this.onRotateUpdate(this.rotation);
  }

  reset(animated = true) {
    this.setScale(this.options.initialScale || 1.0, animated);
    this.setPosition(0, 0, animated);
    this.setRotation(0, animated);
  }

  updateImage(imageUrl) {
    this.imageUrl = imageUrl;
    if (this.imageElement) {
      this.imageElement.src = imageUrl;
    }
  }

  dispose() {
    if (this.hammer) {
      this.hammer.destroy();
      this.hammer = null;
    }
    if (this.zoomResetTimeout) {
      clearTimeout(this.zoomResetTimeout);
    }
    if (this.rotationTimer) {
      clearTimeout(this.rotationTimer);
    }
    if (this.container && this.imageElement) {
      this.container.removeChild(this.imageElement);
    }
    this.imageElement = null;
  }
}

// Global registry for handlers and elements
window.photoViewHandlers = window.photoViewHandlers || {};
window.photoViewElements = window.photoViewElements || {};

// Register element from Dart
window.registerPhotoViewElement = function (containerId, element) {
  window.photoViewElements[containerId] = element;
};

// Factory function called from Dart
window.createPhotoViewHandler = function (containerId, imageUrl, options) {
  const handler = new PhotoViewHandler(containerId, imageUrl, options);
  window.photoViewHandlers[containerId] = handler;
  return handler;
};

window.getPhotoViewHandler = function (containerId) {
  return window.photoViewHandlers[containerId];
};

window.disposePhotoViewHandler = function (containerId) {
  const handler = window.photoViewHandlers[containerId];
  if (handler) {
    handler.dispose();
    delete window.photoViewHandlers[containerId];
  }
  delete window.photoViewElements[containerId];
};

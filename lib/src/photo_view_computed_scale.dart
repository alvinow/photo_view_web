class PhotoViewComputedScale {
  const PhotoViewComputedScale._internal(this.value, this.name);

  final double value;
  final String name;

  static const PhotoViewComputedScale contained =
      PhotoViewComputedScale._internal(double.negativeInfinity, 'contained');

  static const PhotoViewComputedScale covered =
      PhotoViewComputedScale._internal(double.infinity, 'covered');

  @override
  String toString() {
    return 'PhotoViewComputedScale.$name';
  }

  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoViewComputedScale &&
        other.value == value &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(value, name);

  double operator *(double multiplier) {
    // We can't multiply the symbolic constants, but we can return a new object
    // that represents the calculation if needed, or just return the value if it's a concrete number.
    // For the symbolic constants, we usually handle them in the logic.
    // However, the original photo_view allows `PhotoViewComputedScale.contained * 0.8`
    // So we need to support that pattern.
    
    // Since we can't easily represent "contained * 0.8" as a double without context,
    // we might need a wrapper or just rely on the user passing a double if they want a specific value.
    // But to be compatible with the original API which allows `PhotoViewComputedScale.contained * 0.8`,
    // we need to see how they did it. 
    // In original photo_view, PhotoViewComputedScale is likely a class that implements multiplication.
    
    // Let's make this class capable of holding a multiplier.
    return 0.0; // Placeholder, as we need to see how to best implement this for web.
    // Actually, let's redefine this to match the likely usage pattern.
  }
}

// Re-implementation to better match expected behavior
class PhotoViewComputedScaleDefinition {
  const PhotoViewComputedScaleDefinition(this.value);
  final double value;
  
  static const PhotoViewComputedScaleDefinition contained = 
      PhotoViewComputedScaleDefinition(-1.0); // Using -1 as sentinel
  static const PhotoViewComputedScaleDefinition covered = 
      PhotoViewComputedScaleDefinition(-2.0); // Using -2 as sentinel

  dynamic operator *(double multiplier) {
    if (this == contained) {
      return _ComputedScaleMultiplier(contained, multiplier);
    }
    if (this == covered) {
      return _ComputedScaleMultiplier(covered, multiplier);
    }
    return value * multiplier;
  }
}

class _ComputedScaleMultiplier {
  const _ComputedScaleMultiplier(this.definition, this.multiplier);
  final PhotoViewComputedScaleDefinition definition;
  final double multiplier;
}

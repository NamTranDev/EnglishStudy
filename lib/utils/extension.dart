extension ListExtension<T> on List<T> {
  /// Gets the element at the specified [index] if it exists; otherwise, returns null.
  T? getOrNull(int index) {
    return index >= 0 && index < length ? this[index] : null;
  }
}

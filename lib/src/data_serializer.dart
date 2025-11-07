/// Serializer interface for converting objects to a map representation.
/// The type parameters are:
/// - [T]: The type of the object to be serialized/deserialized.
/// - [JSON]: The type of the intermediate JSON representation
///   (e.g., String, Map)
///   Converted type should strictly be JSON serializable.
mixin DataSerializer<T, JSON> {
  /// Creates a JSON object from the given data.
  /// The type of output is up to the implementation
  /// Eg: String, Map, List etc.
  JSON? toJson(T? data);

  /// Creates an object from a JSON.
  /// The type of input is up to the implementation
  /// Eg: String, Map, List etc.
  T? fromJson(JSON? source);
}

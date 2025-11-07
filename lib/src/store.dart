import 'package:flutter_flow_chart/flutter_flow_chart.dart';

class _Store {
  final Map<dynamic, DataSerializer<dynamic, dynamic>> _serializers = {};

  /// Registers a new data serializer.
  void registerSerializer<T>(DataSerializer<T, dynamic> serializer) {
    _serializers[T] = serializer as DataSerializer<dynamic, dynamic>;
  }

  /// Retrieves a data serializer for the given type.
  DataSerializer<T, dynamic>? getSerializer<T>() {
    return _serializers[T] as DataSerializer<T, dynamic>?;
  }
}

/// Exception thrown by the store
class StoreException implements Exception {
  ///
  StoreException(this.message);

  ///
  final String message;

  @override
  String toString() => 'StoreException: $message';
}

/// Global store instance.
/// This instance is used by the Flow Chart package
/// and should not be accessed directly.
final store = _Store();

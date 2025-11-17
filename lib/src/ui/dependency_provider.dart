import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

///
class DependencyProvider extends InheritedWidget {
  ///
  const DependencyProvider({
    required super.child,
    required Map<Type, Object> dependencies,
    super.key,
  }) : _dependencies = dependencies;
  final Map<Type, Object> _dependencies;

  /// Grab a dependency by type:
  static T? of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DependencyProvider>();
    if (provider == null) {
      throw FlutterError(
        // ignore: lines_longer_than_80_chars
        'DependencyProvider.of() called with no DependencyProvider in context for type $T.',
      );
    }

    final dep = provider._dependencies[T];
    return dep as T?;
  }

  @override
  bool updateShouldNotify(DependencyProvider oldWidget) {
    // If any dependency instances change, notify listeners.
    return !mapEquals(_dependencies, oldWidget._dependencies);
  }
}

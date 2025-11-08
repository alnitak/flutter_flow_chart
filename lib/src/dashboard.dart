// ignore: lines_longer_than_80_chars
// ignore_for_file: use_setters_to_change_properties, avoid_positional_boolean_parameters

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/platform/platform.dart';
import 'package:flutter_flow_chart/src/store.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';
import 'package:uuid/uuid.dart';

/// Listener definition for a new connection
typedef ConnectionListener<T> = void Function(
  FlowElement<T> srcElement,
  FlowElement<T> destElement,
);

/// Class to store all the scene elements.
/// This also acts as the controller to the flow_chart widget
/// It notifies changes to [FlowChart]
class Dashboard<T> extends ChangeNotifier {
  ///
  Dashboard({
    Offset? handlerFeedbackOffset,
    this.blockDefaultZoomGestures = false,
    this.minimumZoomFactor = 0.25,
    this.defaultArrowStyle = ArrowStyle.curve,
    DataSerializer<T, dynamic>? dataSerializer,
  })  : elements = [],
        _dashboardPosition = Offset.zero,
        dashboardSize = Size.zero,
        gridBackgroundParams = GridBackgroundParams() {
    // This is a workaround to set the handlerFeedbackOffset
    // to improve the user experience on devices with touch screens
    // This will prevent the handler being covered by user's finger
    if (handlerFeedbackOffset != null) {
      this.handlerFeedbackOffset = handlerFeedbackOffset;
    } else {
      if (isMobile()) {
        this.handlerFeedbackOffset = const Offset(0, -50);
      } else {
        this.handlerFeedbackOffset = Offset.zero;
      }
    }

    if (dataSerializer != null) {
      store.registerSerializer<T>(dataSerializer);
    }
  }

  ///
  factory Dashboard.fromMap(
    Map<String, dynamic> map, {
    DataSerializer<T, dynamic>? dataSerializer,
  }) {
    final d = Dashboard<T>(
      defaultArrowStyle: ArrowStyle.values[map['arrowStyle'] as int? ?? 0],
      dataSerializer: dataSerializer,
    )
      ..elements = List<FlowElement<T>>.from(
        (map['elements'] as List<dynamic>).map<FlowElement<T>>(
          (x) => FlowElement.fromMap(x as Map<String, dynamic>),
        ),
      )
      ..dashboardSize = Size(
        ((map['dashboardSizeWidth'] ?? 0) as num).toDouble(),
        ((map['dashboardSizeHeight'] ?? 0) as num).toDouble(),
      );

    if (map['gridBackgroundParams'] != null) {
      d.gridBackgroundParams = GridBackgroundParams.fromMap(
        map['gridBackgroundParams'] as Map<String, dynamic>,
      );
    }
    d
      ..blockDefaultZoomGestures =
          (map['blockDefaultZoomGestures'] as bool? ?? false)
      ..minimumZoomFactor =
          ((map['minimumZoomFactor'] ?? 0.25) as num).toDouble();

    return d;
  }

  ///
  factory Dashboard.fromJson(
    String source, {
    DataSerializer<T, dynamic>? dataSerializer,
  }) =>
      Dashboard.fromMap(
        json.decode(source) as Map<String, dynamic>,
        dataSerializer: dataSerializer,
      );

  /// The current elements in the dashboard
  List<FlowElement<T>> elements;

  Offset _dashboardPosition;

  /// Dashboard size
  Size dashboardSize;

  /// The default style for the new created arrow
  final ArrowStyle defaultArrowStyle;

  /// [handlerFeedbackOffset] sets an offset for the handler when user
  /// is dragging it.
  /// This can be used to prevent the handler being covered by user's
  /// finger on touch screens.
  late Offset handlerFeedbackOffset;

  /// Background parameters.
  GridBackgroundParams gridBackgroundParams;

  ///
  bool blockDefaultZoomGestures;

  /// minimum zoom factor allowed
  /// default is 0.25
  /// setting it to 1 will prevent zooming out
  /// setting it to 0 will remove the limit
  double minimumZoomFactor;

  final List<ConnectionListener<T>> _connectionListeners = [];

  /// add listener called when a new connection is created
  void addConnectionListener(ConnectionListener<T> listener) {
    _connectionListeners.add(listener);
  }

  /// remove connection listener
  void removeConnectionListener(ConnectionListener<T> listener) {
    _connectionListeners.remove(listener);
  }

  /// set grid background parameters
  void setGridBackgroundParams(GridBackgroundParams params) {
    gridBackgroundParams = params;
    notifyListeners();
  }

  /// set the feedback offset to help on mobile device to see the
  /// end of arrow and not hiding behind the finger when moving it
  void setHandlerFeedbackOffset(Offset offset) =>
      handlerFeedbackOffset = offset;

  /// set [draggable] element property
  void setElementDraggable(
    FlowElement<T> element,
    bool draggable, {
    bool notify = true,
  }) {
    element.isDraggable = draggable;
    if (notify) notifyListeners();
  }

  /// set [connectable] element property
  void setElementConnectable(
    FlowElement<T> element,
    bool connectable, {
    bool notify = true,
  }) {
    element.isConnectable = connectable;
    if (notify) notifyListeners();
  }

  /// set [resizable] element property
  void setElementResizable(
    FlowElement<T> element,
    bool resizable, {
    bool notify = true,
  }) {
    element.isResizable = resizable;
    if (notify) notifyListeners();
  }

  /// add a [FlowElement] to the dashboard
  void addElement(FlowElement<T> element, {bool notify = true, int? position}) {
    if (element.id.isEmpty) {
      element.id = const Uuid().v4();
    }
    element.setScale(1, gridBackgroundParams.scale);
    elements.insert(position ?? elements.length, element);
    if (notify) {
      notifyListeners();
    }
  }

  /// Enable editing mode for an element
  void setElementEditingText(
    FlowElement<T> element,
    bool editing, {
    bool notify = true,
  }) {
    element.isEditingText = editing;
    if (notify) notifyListeners();
  }

  /// Set a new [style] to the arrow staring from [src] pointing to [dest].
  /// If [notify] is true the dasboard is refreshed.
  /// The [tension] parameter is used when [style] is [ArrowStyle.segmented] to
  /// set the curve strength on pivot points. 0 means no curve.
  void setArrowStyle(
    FlowElement<T> src,
    FlowElement<T> dest,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    for (final conn in src.next) {
      if (conn.destElementId == dest.id) {
        conn.arrowParams.style = style;
        conn.arrowParams.tension = tension;
        break;
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  /// Set a new [style] to the arrow staring from the [handler] of [src]
  /// element.
  /// If [notify] is true the dasboard is refreshed.
  /// The [tension] parameter is used when [style] is [ArrowStyle.segmented] to
  /// set the curve strength on pivot points. 0 means no curve.
  void setArrowStyleByHandler(
    FlowElement<T> src,
    Handler handler,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    // find arrows that start from [src] inside [handler]
    for (final conn in src.next) {
      if (conn.arrowParams.startArrowPosition == handler.toAlignment()) {
        conn.arrowParams.tension = tension;
        conn.arrowParams.style = style;
      }
    }
    // find arrow that ends to this [src] inside [handler]
    for (final element in elements) {
      for (final conn in element.next) {
        if (conn.arrowParams.endArrowPosition == handler.toAlignment() &&
            conn.destElementId == src.id) {
          conn.arrowParams.tension = tension;
          conn.arrowParams.style = style;
        }
      }
    }

    if (notify) {
      notifyListeners();
    }
  }

  /// find the element by its [id]
  int findElementIndexById(String id) {
    return elements.indexWhere((element) => element.id == id);
  }

  /// find the element by its [id] for convenience
  /// return null if not found
  FlowElement<T>? findElementById(String id) {
    try {
      return elements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// find the connection from [srcElement] to [destElement]
  /// return null if not found.
  /// In case of multiple connections, first connection is returned.
  ConnectionParams? findConnectionByElements(
    FlowElement<T> srcElement,
    FlowElement<T> destElement,
  ) {
    try {
      return srcElement.next
          .firstWhere((element) => element.destElementId == destElement.id);
    } catch (e) {
      return null;
    }
  }

  /// find the source element of the [dest] element.
  FlowElement<T>? findSrcElementByDestElement(FlowElement<T> dest) {
    for (final element in elements) {
      for (final connection in element.next) {
        if (connection.destElementId == dest.id) {
          return element;
        }
      }
    }

    return null;
  }

  /// remove all elements
  void removeAllElements({bool notify = true}) {
    elements.clear();
    if (notify) notifyListeners();
  }

  /// remove the [handler] connection of [element]
  void removeElementConnection(
    FlowElement<T> element,
    Handler handler, {
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = Alignment.topCenter;
      case Handler.bottomCenter:
        alignment = Alignment.bottomCenter;
      case Handler.leftCenter:
        alignment = Alignment.centerLeft;
      case Handler.rightCenter:
        alignment = Alignment.centerRight;
    }

    var isSrc = false;
    for (final connection in element.next) {
      if (connection.arrowParams.startArrowPosition == alignment) {
        isSrc = true;
        break;
      }
    }

    if (isSrc) {
      element.next.removeWhere(
        (handlerParam) =>
            handlerParam.arrowParams.startArrowPosition == alignment,
      );
    } else {
      final src = findSrcElementByDestElement(element);
      if (src != null) {
        src.next.removeWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );
      }
    }

    if (notify) notifyListeners();
  }

  /// dissect an element connection
  /// [handler] is the handler that is in connection
  /// [point] is the point where the connection is dissected
  /// if [point] is null, point is automatically calculated
  void dissectElementConnection(
    FlowElement<T> element,
    Handler handler, {
    Offset? point,
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = Alignment.topCenter;
      case Handler.bottomCenter:
        alignment = Alignment.bottomCenter;
      case Handler.leftCenter:
        alignment = Alignment.centerLeft;
      case Handler.rightCenter:
        alignment = Alignment.centerRight;
    }

    ConnectionParams? conn;

    var newPoint = Offset.zero;
    if (point == null) {
      try {
        // assuming element is the src
        conn = element.next.firstWhere(
          (handlerParam) =>
              handlerParam.arrowParams.startArrowPosition == alignment,
        );
        if (conn.arrowParams.style != ArrowStyle.segmented) return;

        final dest = findElementById(conn.destElementId);
        newPoint = (dest!
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                element
                    .getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      } catch (e) {
        // apparently is not
        final src = findSrcElementByDestElement(element)!;
        conn = src.next.firstWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );
        if (conn.arrowParams.style != ArrowStyle.segmented) return;

        newPoint = (element
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                src.getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      }
    } else {
      newPoint = point;
    }

    conn?.dissect(newPoint);

    if (notify && conn != null) {
      notifyListeners();
    }
  }

  /// remove the dissection of the connection
  void removeDissection(Pivot pivot, {bool notify = true}) {
    for (final element in elements) {
      for (final connection in element.next) {
        connection.pivots.removeWhere((item) => item == pivot);
      }
    }
    if (notify) notifyListeners();
  }

  /// remove the connection from [srcElement] to [destElement]
  void removeConnectionByElements(
    FlowElement<T> srcElement,
    FlowElement<T> destElement, {
    bool notify = true,
  }) {
    srcElement.next.removeWhere(
      (handlerParam) => handlerParam.destElementId == destElement.id,
    );
    if (notify) notifyListeners();
  }

  /// remove all the connection from the [element]
  void removeElementConnections(FlowElement<T> element, {bool notify = true}) {
    element.next.clear();
    if (notify) notifyListeners();
  }

  /// remove all the elements with [id] from the dashboard
  void removeElementById(String id, {bool notify = true}) {
    // remove the element
    var elementId = '';
    elements.removeWhere((element) {
      if (element.id == id) {
        elementId = element.id;
      }
      return element.id == id;
    });

    // remove all connections to the elements found
    for (final e in elements) {
      e.next.removeWhere((handlerParams) {
        return elementId.contains(handlerParams.destElementId);
      });
    }
    if (notify) notifyListeners();
  }

  /// remove element
  /// return true if it has been removed
  bool removeElement(FlowElement<T> element, {bool notify = true}) {
    // remove the element
    var found = false;
    final elementId = element.id;
    elements.removeWhere((e) {
      if (e.id == element.id) found = true;
      return e.id == element.id;
    });

    // remove all connections to the element
    for (final e in elements) {
      e.next.removeWhere(
        (handlerParams) => handlerParams.destElementId == elementId,
      );
    }
    if (notify) notifyListeners();
    return found;
  }

  /// [factor] needs to be a non negative value.
  /// 1 is the default value.
  /// Giving a value above 1 will zoom the dashboard by the given factor
  /// and vice versa. Negative values will be ignored.
  /// [zoomFactor] will not go below [minimumZoomFactor]
  /// [focalPoint] is the point where the zoom is centered
  /// default is the center of the dashboard
  void setZoomFactor(double factor, {Offset? focalPoint}) {
    if (factor < minimumZoomFactor || gridBackgroundParams.scale == factor) {
      return;
    }

    focalPoint ??= Offset(dashboardSize.width / 2, dashboardSize.height / 2);

    for (final element in elements) {
      // applying new zoom
      element
        ..position = (element.position - focalPoint) /
                gridBackgroundParams.scale *
                factor +
            focalPoint
        ..setScale(gridBackgroundParams.scale, factor);
      for (final conn in element.next) {
        for (final pivot in conn.pivots) {
          pivot.setScale(gridBackgroundParams.scale, focalPoint, factor);
        }
      }
    }

    gridBackgroundParams.setScale(factor, focalPoint);

    notifyListeners();
  }

  /// shorthand to get the current zoom factor
  double get zoomFactor {
    return gridBackgroundParams.scale;
  }

  /// needed to know the diagram widget position to compute
  /// offsets for drag and drop elements
  void setDashboardPosition(Offset position) => _dashboardPosition = position;

  /// Get the position.
  Offset get position => _dashboardPosition;

  /// needed to know the diagram widget size
  void setDashboardSize(Size size) => dashboardSize = size;

  /// make an arrow connection from [sourceElement] to
  /// the elements with id [destId]
  /// [arrowParams] definition of arrow parameters
  void addNextById(
    FlowElement<T> sourceElement,
    String destId,
    ArrowParams arrowParams, {
    bool notify = true,
  }) {
    var found = 0;
    arrowParams.setScale(1, gridBackgroundParams.scale);
    for (var i = 0; i < elements.length; i++) {
      if (elements[i].id == destId) {
        // if the [id] already exist, remove it and add this new connection
        sourceElement.next
            .removeWhere((element) => element.destElementId == destId);
        final conn = ConnectionParams(
          destElementId: elements[i].id,
          arrowParams: arrowParams,
          pivots: [],
        );
        sourceElement.next.add(conn);
        for (final listener in _connectionListeners) {
          listener(sourceElement, elements[i]);
        }

        found++;
      }
    }

    if (found == 0) {
      debugPrint('Element with $destId id not found!');
      return;
    }
    if (notify) {
      notifyListeners();
    }
  }

  //******************************* */
  /// manage load/save using json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elements': elements.map((x) => x.toMap()).toList(),
      'dashboardSizeWidth': dashboardSize.width,
      'dashboardSizeHeight': dashboardSize.height,
      'gridBackgroundParams': gridBackgroundParams.toMap(),
      'blockDefaultZoomGestures': blockDefaultZoomGestures,
      'minimumZoomFactor': minimumZoomFactor,
      'arrowStyle': defaultArrowStyle.index,
    };
  }

  ///
  String toJson() => json.encode(toMap());

  ///
  String prettyJson() {
    final spaces = ' ' * 2;
    final encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(toMap());
  }

  /// recenter the dashboard
  void recenter() {
    final center = Offset(dashboardSize.width / 2, dashboardSize.height / 2);
    gridBackgroundParams.offset = center;
    if (elements.isNotEmpty) {
      final currentDeviation = elements.first.position - center;
      for (final element in elements) {
        element.position -= currentDeviation;
        for (final next in element.next) {
          for (final pivot in next.pivots) {
            pivot.pivot -= currentDeviation;
          }
        }
      }
    }
    notifyListeners();
  }

  /// save the dashboard into [completeFilePath]
  void saveDashboard(String completeFilePath) {
    saveDashboardData(completeFilePath, prettyJson());
  }

  /// clear the dashboard and load the new one from file [completeFilePath]
  void loadDashboard(String completeFilePath) {
    final data = readDashboardData(completeFilePath);
    if (data != null) {
      final source = json.decode(data) as Map<String, dynamic>;
      loadDashboardData(source);
    }
  }

  /// clear the dashboard and load the new one from [source] json
  void loadDashboardData(Map<String, dynamic> source) {
    elements.clear();

    gridBackgroundParams = GridBackgroundParams.fromMap(
      source['gridBackgroundParams'] as Map<String, dynamic>,
    );
    blockDefaultZoomGestures = source['blockDefaultZoomGestures'] as bool;
    minimumZoomFactor = (source['minimumZoomFactor'] as num).toDouble();
    dashboardSize = Size(
      (source['dashboardSizeWidth'] as num).toDouble(),
      (source['dashboardSizeHeight'] as num).toDouble(),
    );

    final loadedElements = List<FlowElement<T>>.from(
      (source['elements'] as List<dynamic>).map<FlowElement<T>>(
        (x) => FlowElement.fromMap(x as Map<String, dynamic>),
      ),
    );
    elements
      ..clear()
      ..addAll(loadedElements);

    recenter();
  }
}

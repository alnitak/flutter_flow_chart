import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

typedef ConnectionListener = void Function(
  FlowElement srcElement,
  FlowElement destElement,
);

/// Class to store all the scene elements.
/// This also acts as the controller to the flow_chart widget
/// It notifies changes to [FlowChart]
class Dashboard extends ChangeNotifier {
  List<FlowElement> elements;
  Offset _dashboardPosition;
  Size dashboardSize;
  final ArrowStyle defaultArrowStyle;

  /// [handlerFeedbackOffset] sets an offset for the handler when user is dragging it
  /// This can be used to prevent the handler being covered by user's finger on touch screens
  late Offset handlerFeedbackOffset;

  GridBackgroundParams gridBackgroundParams;
  bool blockDefaultZoomGestures;

  /// minimum zoom factor allowed
  /// default is 0.25
  /// setting it to 1 will prevent zooming out
  /// setting it to 0 will remove the limit
  double minimumZoomFactor;

  final List<ConnectionListener> _connectionListeners = [];

  Dashboard({
    Offset? handlerFeedbackOffset,
    this.blockDefaultZoomGestures = false,
    this.minimumZoomFactor = 0.25,
    this.defaultArrowStyle = ArrowStyle.curve,
  })  : elements = [],
        _dashboardPosition = Offset.zero,
        dashboardSize = const Size(0, 0),
        gridBackgroundParams = GridBackgroundParams() {
    // This is a workaround to set the handlerFeedbackOffset
    // to improve the user experience on devices with touch screens
    // This will prevent the handler being covered by user's finger
    if (handlerFeedbackOffset != null) {
      this.handlerFeedbackOffset = handlerFeedbackOffset;
    } else {
      if (kIsWeb) {
        this.handlerFeedbackOffset = const Offset(0, 0);
      } else {
        if (Platform.isIOS || Platform.isAndroid) {
          this.handlerFeedbackOffset = const Offset(0, -50);
        } else {
          this.handlerFeedbackOffset = const Offset(0, 0);
        }
      }
    }
  }

  /// add listener called when a new connection is created
  addConnectionListener(ConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  /// remove connection listener
  removeConnectionListener(ConnectionListener listener) {
    _connectionListeners.remove(listener);
  }

  /// set grid background parameters
  setGridBackgroundParams(GridBackgroundParams params) {
    gridBackgroundParams = params;
    notifyListeners();
  }

  /// set the feedback offset to help on mobile device to see the
  /// end of arrow and not hiding behind the finger when moving it
  setHandlerFeedbackOffset(Offset offset) {
    handlerFeedbackOffset = offset;
  }

  /// set [isResizable] element property
  setElementResizable(FlowElement element, bool resizable,
      {bool notify = true}) {
    element.isResizing = resizable;
    if (notify) notifyListeners();
  }

  /// add a [FlowElement] to the dashboard
  addElement(FlowElement element, {bool notify = true}) {
    if (element.id.isEmpty) {
      element.id = const Uuid().v4();
    }
    element.setScale(1, gridBackgroundParams.scale);
    elements.add(element);
    if (notify) {
      notifyListeners();
    }
  }

  /// set the [element] position
  setArrowStyle(FlowElement src, FlowElement dest, ArrowStyle style,
      {bool notify = true}) {
    for (final conn in src.next) {
      if (conn.destElementId == dest.id) {
        conn.arrowParams.style = style;
        break;
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
  FlowElement? findElementById(String id) {
    try {
      return elements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// find the connection from [srcElement] to [destElement]
  /// return null if not found
  /// In case of multiple connections, first connection is returned
  ConnectionParams? findConnectionByElements(
    FlowElement srcElement,
    FlowElement destElement,
  ) {
    try {
      return srcElement.next
          .firstWhere((element) => element.destElementId == destElement.id);
    } catch (e) {
      return null;
    }
  }

  /// find the source element of the [element]
  FlowElement? findSrcElementByDestElement(FlowElement dest) {
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
  removeAllElements({bool notify = true}) {
    elements.clear();
    if (notify) notifyListeners();
  }

  /// remove the [handler] connection of [element]
  removeElementConnection(
    FlowElement element,
    Handler handler, {
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = const Alignment(0.0, -1.0);
        break;
      case Handler.bottomCenter:
        alignment = const Alignment(0.0, 1.0);
        break;
      case Handler.leftCenter:
        alignment = const Alignment(-1.0, 0.0);
        break;
      case Handler.rightCenter:
      default:
        alignment = const Alignment(1.0, 0.0);
    }

    bool isSrc = false;
    for (final connection in element.next) {
      if (connection.arrowParams.startArrowPosition == alignment) {
        isSrc = true;
        break;
      }
    }

    if (isSrc) {
      element.next.removeWhere((handlerParam) =>
          handlerParam.arrowParams.startArrowPosition == alignment);
    } else {
      final src = findSrcElementByDestElement(element);
      if (src != null) {
        src.next.removeWhere(
            (handlerParam) => handlerParam.destElementId == element.id);
      }
    }

    if (notify) notifyListeners();
  }

  /// dissect an element connection
  /// [handler] is the handler that is in connection
  /// [point] is the point where the connection is dissected
  /// if [point] is null, point is automatically calculated
  dissectElementConnection(
    FlowElement element,
    Handler handler, {
    Offset? point,
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = const Alignment(0.0, -1.0);
        break;
      case Handler.bottomCenter:
        alignment = const Alignment(0.0, 1.0);
        break;
      case Handler.leftCenter:
        alignment = const Alignment(-1.0, 0.0);
        break;
      case Handler.rightCenter:
      default:
        alignment = const Alignment(1.0, 0.0);
    }

    ConnectionParams? conn;

    if (point == null) {
      try {
        // assuming element is the src
        conn = element.next.firstWhere((handlerParam) =>
            handlerParam.arrowParams.startArrowPosition == alignment);
        final dest = findElementById(conn.destElementId);
        // point = (dest!.position + element.position) / 2;
        point = (dest!.getHandlerPosition(conn.arrowParams.endArrowPosition) +
                element
                    .getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      } catch (e) {
        // apparently is not
        final src = findSrcElementByDestElement(element)!;
        conn = src.next.firstWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );

        point = (element.getHandlerPosition(conn.arrowParams.endArrowPosition) +
                src.getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      }
    }

    conn?.dissect(point);

    if (notify && conn != null) {
      notifyListeners();
    }
  }

  /// remove the dissection of the connection
  removeDissection(Pivot pivot, {bool notify = true}) {
    for (FlowElement element in elements) {
      for (ConnectionParams connection in element.next) {
        connection.pivots.removeWhere((item) => item == pivot);
      }
    }
    if (notify) notifyListeners();
  }

  /// remove the connection from [srcElement] to [destElement]
  removeConnectionByElements(FlowElement srcElement, FlowElement destElement,
      {bool notify = true}) {
    srcElement.next.removeWhere(
        (handlerParam) => handlerParam.destElementId == destElement.id);
    if (notify) notifyListeners();
  }

  /// remove all the connection from the [element]
  removeElementConnections(FlowElement element, {bool notify = true}) {
    element.next.clear();
    if (notify) notifyListeners();
  }

  /// remove all the elements with [id] from the dashboard
  removeElementById(String id, {bool notify = true}) {
    // remove the element
    String elementId = '';
    elements.removeWhere((element) {
      if (element.id == id) {
        elementId = element.id;
      }
      return element.id == id;
    });

    // remove all connections to the elements found
    for (FlowElement e in elements) {
      e.next.removeWhere((handlerParams) {
        return elementId.contains(handlerParams.destElementId);
      });
    }
    if (notify) notifyListeners();
  }

  /// remove element
  /// return true if it has been removed
  bool removeElement(FlowElement element, {bool notify = true}) {
    // remove the element
    bool found = false;
    String elementId = element.id;
    elements.removeWhere((e) {
      if (e.id == element.id) found = true;
      return e.id == element.id;
    });

    // remove all connections to the element
    for (FlowElement e in elements) {
      e.next.removeWhere(
          (handlerParams) => handlerParams.destElementId == elementId);
    }
    if (notify) notifyListeners();
    return found;
  }

  /// [factor] needs to be a non negative value
  /// 1 is the default value
  /// giving a value above 1 will zoom the dashboard by the given factor and vice versa
  /// Negative values will be ignored
  /// [zoomFactor] will not go below [minimumZoomFactor]
  /// [focalPoint] is the point where the zoom is centered
  /// default is the center of the dashboard
  void setZoomFactor(double factor, {Offset? focalPoint}) {
    if (factor < minimumZoomFactor || gridBackgroundParams.scale == factor) {
      return;
    }

    focalPoint ??= Offset(dashboardSize.width / 2, dashboardSize.height / 2);

    for (FlowElement element in elements) {
      // applying new zoom
      element.position = (element.position - focalPoint) /
              gridBackgroundParams.scale *
              factor +
          focalPoint;
      element.setScale(gridBackgroundParams.scale, factor);
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
  setDashboardPosition(Offset position) {
    _dashboardPosition = position;
  }

  get position => _dashboardPosition;

  /// needed to know the diagram widget size
  setDashboardSize(Size size) {
    dashboardSize = size;
  }

  /// make an arrow connection from [sourceElement] to
  /// the elements with id [destId]
  /// [arrowParams] definition of arrow parameters
  addNextById(
    FlowElement sourceElement,
    String destId,
    ArrowParams arrowParams, {
    bool notify = true,
  }) {
    int found = 0;
    arrowParams.setScale(1, gridBackgroundParams.scale);
    for (int i = 0; i < elements.length; i++) {
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

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    Dashboard d = Dashboard(
        defaultArrowStyle: ArrowStyle.values[map['arrowStyle'] as int? ?? 0]);
    d.elements = List<FlowElement>.from(
      (map['elements'] as List<dynamic>).map<FlowElement>(
        (x) => FlowElement.fromMap(x as Map<String, dynamic>),
      ),
    );
    d.dashboardSize = Size(
      map['dashboardSizeWidth'] as double? ?? 0,
      map['dashboardSizeHeight'] as double? ?? 0,
    );

    if (map['gridBackgroundParams'] != null) {
      d.gridBackgroundParams =
          GridBackgroundParams.fromMap(map['gridBackgroundParams'] as Map);
    }
    d.blockDefaultZoomGestures =
        map['blockDefaultZoomGestures'] as bool? ?? false;
    d.minimumZoomFactor = map['minimumZoomFactor'] as double? ?? 0.25;

    return d;
  }

  String toJson() => json.encode(toMap());

  factory Dashboard.fromJson(String source) =>
      Dashboard.fromMap(json.decode(source) as Map<String, dynamic>);

  String prettyJson() {
    var spaces = ' ' * 2;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(toMap());
  }

  /// recenter the dashboard
  void recenter() {
    Offset center = Offset(dashboardSize.width / 2, dashboardSize.height / 2);
    gridBackgroundParams.offset = center;
    if (elements.isNotEmpty) {
      Offset currentDeviation = elements.first.position - center;
      for (FlowElement element in elements) {
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
  saveDashboard(String completeFilePath) {
    File f = File(completeFilePath);
    f.writeAsStringSync(prettyJson(), flush: true);
  }

  /// clear the dashboard and load the new one
  loadDashboard(String completeFilePath) {
    File f = File(completeFilePath);
    if (f.existsSync()) {
      elements.clear();
      String source = f.readAsStringSync();

      gridBackgroundParams = GridBackgroundParams.fromMap(
          (json.decode(source))['gridBackgroundParams'] as Map);
      blockDefaultZoomGestures =
          (json.decode(source)['blockDefaultZoomGestures'] as bool);
      minimumZoomFactor = (json.decode(source)['minimumZoomFactor'] as double);
      dashboardSize = Size(
        json.decode(source)['dashboardSizeWidth'] as double,
        json.decode(source)['dashboardSizeHeight'] as double,
      );

      final loadedElements = List<FlowElement>.from(
        ((json.decode(source))['elements'] as List<dynamic>).map<FlowElement>(
          (x) => FlowElement.fromMap(x as Map<String, dynamic>),
        ),
      );
      elements.clear();
      elements.addAll(loadedElements);

      recenter();
    }
  }
}

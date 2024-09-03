// ignore_for_file: public_member_api_docs

import 'package:example/element_settings_menu.dart';
import 'package:example/platforms/hooks_mobile.dart'
    if (dart.library.js) 'package:example/platforms/hooks_web.dart';
import 'package:example/text_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:star_menu/star_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Flow Chart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Flow Chart Demo'),
    );
  }
}

///
class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dashboard dashboard = Dashboard();

  /// Notifier for the tension slider
  final segmentedTension = ValueNotifier<double>(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              dashboard.setZoomFactor(1.5 * dashboard.zoomFactor);
            },
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () {
              dashboard.setZoomFactor(dashboard.zoomFactor / 1.5);
            },
            icon: const Icon(Icons.zoom_out),
          ),
        ],
      ),
      backgroundColor: Colors.black12,
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: FlowChart(
          dashboard: dashboard,
          onNewConnection: (p1, p2) {
            debugPrint('new connection');
          },
          onDashboardTapped: (context, position) {
            debugPrint('Dashboard tapped $position');
            _displayDashboardMenu(context, position);
          },
          onScaleUpdate: (newScale) {
            debugPrint('Scale updated. new scale: $newScale');
          },
          onDashboardSecondaryTapped: (context, position) {
            debugPrint('Dashboard right clicked $position');
            _displayDashboardMenu(context, position);
          },
          onDashboardLongTapped: (context, position) {
            debugPrint('Dashboard long tapped $position');
          },
          onDashboardSecondaryLongTapped: (context, position) {
            debugPrint(
              'Dashboard long tapped with mouse right click $position',
            );
          },
          onElementLongPressed: (context, position, element) {
            debugPrint('Element with "${element.text}" text '
                'long pressed');
          },
          onElementSecondaryLongTapped: (context, position, element) {
            debugPrint('Element with "${element.text}" text '
                'long tapped with mouse right click');
          },
          onElementPressed: (context, position, element) {
            debugPrint('Element with "${element.text}" text pressed');
            _displayElementMenu(context, position, element);
          },
          onElementSecondaryTapped: (context, position, element) {
            debugPrint('Element with "${element.text}" text pressed');
            _displayElementMenu(context, position, element);
          },
          onHandlerPressed: (context, position, handler, element) {
            debugPrint('handler pressed: position $position '
                'handler $handler" of element $element');
            _displayHandlerMenu(position, handler, element);
          },
          onHandlerLongPressed: (context, position, handler, element) {
            debugPrint('handler long pressed: position $position '
                'handler $handler" of element $element');
          },
          onPivotSecondaryPressed: (context, pivot) {
            dashboard.removeDissection(pivot);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: dashboard.recenter,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  //*********************
  //* POPUP MENUS
  //*********************

  /// Display a drop down menu when tapping on a handler
  void _displayHandlerMenu(
    Offset position,
    Handler handler,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            space: 10,
            alignment: LinearAlignment.left,
          ),
          onHoverScale: 1.1,
          useTouchAsCenter: true,
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) {
          if (index != 2) {
            controller.closeMenu!();
          }
        },
        items: [
          ActionChip(
            label: const Icon(Icons.delete),
            onPressed: () =>
                dashboard.removeElementConnection(element, handler),
          ),
          ActionChip(
            label: const Icon(Icons.control_point),
            onPressed: () {
              dashboard.dissectElementConnection(element, handler);
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: segmentedTension,
            builder: (_, tension, __) {
              return Wrap(
                children: [
                  ActionChip(
                    label: const Text('segmented'),
                    onPressed: () {
                      dashboard.setArrowStyleByHandler(
                        element,
                        handler,
                        ArrowStyle.segmented,
                        tension: tension,
                      );
                    },
                  ),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: tension,
                      max: 3,
                      onChanged: (v) {
                        segmentedTension.value = v;
                        dashboard.setArrowStyleByHandler(
                          element,
                          handler,
                          ArrowStyle.segmented,
                          tension: v,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          ActionChip(
            label: const Text('curved'),
            onPressed: () {
              dashboard.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.curve,
              );
            },
          ),
          ActionChip(
            label: const Text('rectangular'),
            onPressed: () {
              dashboard.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.rectangular,
              );
            },
          ),
        ],
        parentContext: context,
      ),
    );
  }

  /// Display a drop down menu when tapping on an element
  void _displayElementMenu(
    BuildContext context,
    Offset position,
    FlowElement element,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          onHoverScale: 1.1,
          centerOffset: position - const Offset(50, 0),
          boundaryBackground: BoundaryBackground(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[6],
            ),
          ),
        ),
        onItemTapped: (index, controller) {
          if (!(index == 5 || index == 2)) {
            controller.closeMenu!();
          }
        },
        items: [
          Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          InkWell(
            onTap: () => dashboard.removeElement(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          InkWell(
            onTap: () {
              dashboard.removeElementConnections(element);
            },
            child: const Text('Remove all connections'),
          ),
          // InkWell(
          //   onTap: () {
          //     dashboard.setElementDraggable(element, !element.isDraggable);
          //   },
          //   child:
          //       Text('Toggle Draggable (${element.isDraggable ? '✔' : '✘'})'),
          // ),
          InkWell(
            onTap: () {
              dashboard.setElementConnectable(element, !element.isConnectable);
            },
            child: Text(
              'Toggle Connectable (${element.isConnectable ? '✔' : '✘'})',
            ),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementResizable(element, !element.isResizable);
            },
            child:
                Text('Toggle Resizable (${element.isResizable ? '✔' : '✘'})'),
          ),
          ElementSettingsMenu(
            element: element,
          ),
        ],
        parentContext: context,
      ),
    );
  }

  /// Display a linear menu for the dashboard
  void _displayDashboardMenu(BuildContext context, Offset position) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          // calculate the offset from the dashboard center
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        parentContext: context,
        items: [
          ActionChip(
            label: const Text('Add diamond'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(80, 80),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.diamond,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add rect'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  // ignore: avoid_redundant_argument_values
                  kind: ElementKind.rectangle,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label:
                const Text('Add rect (draggable, resizable, not connectable)'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  // ignore: avoid_redundant_argument_values
                  kind: ElementKind.rectangle,
                )
                  ..isDraggable = true
                  ..isResizable = true
                  ..isConnectable = false,
              );
            },
          ),
          ActionChip(
            label: const Text('Add oval'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.oval,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add parallelogram'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.parallelogram,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add hexagon'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(150, 100),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.hexagon,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                    Handler.topCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add storage'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 150),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.storage,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add image'),
            onPressed: () async {
              final pickResult = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (pickResult == null) return;
              dashboard.addElement(
                FlowElement(
                  position: position,
                  // size: const Size(200, 200),
                  // text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.image,
                  handlers: [
                    Handler.topCenter,
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                  data: Image.memory(pickResult.files.single.bytes!).image,
                )..isResizable = true,
              );
            },
          ),
          ActionChip(
            label: const Text('Remove all'),
            onPressed: () {
              dashboard.removeAllElements();
            },
          ),
          ActionChip(
            label: const Text('SAVE dashboard'),
            onPressed: () => saveDashboard(dashboard),
          ),
          ActionChip(
            label: const Text('LOAD dashboard'),
            onPressed: () => loadDashboard(dashboard),
          ),
        ],
      ),
    );
  }
}

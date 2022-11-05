# Flutter Flow Chart

A package that let you draw a flow chart diagram with different kind of customizable elements. Dashboards can be saved for later use.

![Image](https://github.com/alnitak/flutter_flow_chart/blob/main/images/flowchart.gif)

See online example [here](https://alnitak.github.io/)

## Features

* *diamond, rectangle, oval, storage, parallelogram* elements
* elements can be customizable with background, border and text color, border thickness, text size and weight.
* interactively connect elements
* save/load dashboard

## Usage

First create a *Dashboard*:
```dart
Dashboard dashboard = Dashboard();
```

then crete the [FlowChart] widget where you can react to the user interactions:
```dart
FlowChart(
    dashboard: dashboard,
    onDashboardTapped: ((context, position) {}),
    onDashboardLongtTapped: ((context, position) {}),
    onElementLongPressed: (context, element) {},
    onElementPressed: (context, element) {},
    onHandlerPressed: (context, position, handler, element) {},
    onHandlerLongPressed: (context, position, handler, element) {},
)
```

then use the *dashboard* variable to add, remove, resize etc. elements or load/save the dashboard.

In the [example](https://github.com/alnitak/flutter_flow_chart/blob/master/example/lib/main.dart), the [StarMenu](https://pub.dev/packages/star_menu) package is used to easily interact with user inputs.

## The Dashboard

The **Dashboard** object contains all the methods described below used to interact with the flow chart.

|**relevant methods**|**description**|
|---|---|
|*setGridBackgroundParams*|set grid background parameters|
|*setHandlerFeedbackOffset*|set the feedback offset to help on mobile device to see the end of arrow and not hiding behind the finger when moving it|
|*setElementResizable*|set the element as resizable. A handle will be displayed on the bottom right and will disappear when finish resizing|
|*addElement*|add a *FlowElement* to the dashboard|
|*removeAllElements*|remove all elements|
|*removeElementConnection*|remove the given handler connection of the given element|
|*removeElementConnections*|remove all the connections from the given element|
|*removeElementById*|remove all the elements with the given id from the dashboard|
|*removeElement*|remove the given element|
|*addNextById*|make a connection from the given sourceElement to the elements with the given id|
|*saveDashboard*|save the dashboard into the given file path|
|*loadDashboard*|clear the dashboard and load the new one|

## The FlowElement

The *FlowElement* defines the element kind with its position, size, colors and so on.

|**properties**|**type**|**description**|
|---|---|---|
|*position*|Offset|The position of the *FlowElement*|
|*size*|Size|The size of the *FlowElement*|
|*text*|String|Element text|
|*textColor*|Color|Text color|
|*textSize*|double|Text size|
|*textIsBold*|bool|Makes text bold if true|
|*kind*|ElementKind|Element shape: enum {rectangle, diamond, storage, oval, parallelogram}|
|*handlers*|List<Handler>|Connection handlers: enum {topCenter, bottomCenter, rightCenter, leftCenter}|
|*handlerSize*|Size|The size of element handlers|
|*backgroundColor*|Size|Background color of the element|
|*borderColor*|Size|Border color of the element|
|*borderThickness*|Size|Border thickness of the element|
|*elevation*|Size|Shadow elevation|
|*next*|List<ConnectionParams>|Shadow elevation|

|**relevant methods**|**description**|
|---|---|
|*setIsResizing*|When setting to true, a handler will disply at the element bottom right to let the user to resize it. When finish it will disappear.|
|*setText*|Set element text|
|*setTextColor*|Set text color|
|*setTextSize*|Set text size|
|*setTextIsBold*|Set text bold|
|*setBackgroundColor*|Set background color|
|*setBorderColor*|Set border color|
|*setBorderThickness*|Set border thickness|
|*setElevation*|Set elevation|
|*changePosition*|Change element position in the dashboard|
|*changeSize*|Change element size|

# Examples

## Add an element to Dashboard
```dart
Dashboard dashboard = Dashboard();

///////////////////////////////////
/// Define 2 elements
FlowElement element1 = FlowElement(
    /// position in the local dashboard coordinates
    position: const Offset(100, 100),
    /// element size
    size: const Size(100, 100),
    /// text to show
    text: 'diamond',
    /// rectangle, diamond, storage, oval or parallelogram element kind
    kind: ElementKind.diamond,
    /// which handler to make active
    handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
    ]);
FlowElement element2 = FlowElement(
    position: const Offset(300, 100),
    size: const Size(100, 150),
    text: 'rect',
    kind: ElementKind.rectangle,
    handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
    ]);
///////////////////////////////////
/// Add the element to Dashboard
dashboard.addElement(element);

///////////////////////////////////
/// Connect right handler of element1 
/// to the left handler of element2
dashboard.addNextById(
    element1,
    element2.id,
    ArrowParams(
        thickness: 1.5,
        color: Colors.Black,
        startArrowPosition: Alignment.centerRight,
        endArrowPosition: Alignment.centerLeft,
    ),
);

///////////////////////////////////
/// Save/load dashboard
Directory appDocDir =
    await path.getApplicationDocumentsDirectory();

dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');

dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
```

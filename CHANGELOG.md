#### 4.1.1
- able to update the elementData and rebuild its FlowElement #51 (thanks to [chaosue](https://github.com/chaosue)).

#### 4.1.0
**(thanks to [Isira Herath](https://github.com/SL-Pirate))**
- Introduce full custom `FlowElement` support using the `customElementBuilder` API

#### 4.0.1
- Restored Web compatibility (replaced `dart:io` imports with conditional imports).

#### 4.0.0
**(thanks to [Isira Herath](https://github.com/SL-Pirate))**
- Added support for FlowElement to hold custom data.
- Refactored FlowChart to be generic, allowing definition of the data type its flow elements can hold.
- Added a `DataSerializer` mixin to enable JSON serialization and deserialization for custom data.

#### 3.2.3
-  Fixed toARGB32() issue #44 from Abdallah-Ehab

#### 3.2.2
- fix type error by ensuring proper double values #43 from ValiantDoge

#### 3.2.1
- fix: 3.2.0 breaks backward compatibility of the JSON format #36

#### 3.2.0
**(thanks to [Maurizio Pinotti](https://github.com/mauriziopinotti))**
- Make elements more flexible with 3 new FlowElement properties:
  - `isDraggable` (default true, no visual feedback): whether they can be dragged around
  - `isResizble` (default false, bottom-right handle when enabled): whether they can be resized
  - `isConnectable` (default true, 4 handlers when enabled): whether they can be connected to other elements. Unlike the handlers param, `isConnectable` can be toggled at runtime
- Example updated.
- Add new FlowElement: ImageWidget
- New feature: addElement() at custom position
- Add an optional delete icon to the bottom-left corner of elements
- Allow in-place text editing for elements

#### 3.1.1
* Added curvature tension between pivot points of segmented arrows

#### 3.1.0
* Implemented styling new arrows (thanks to [Isira Herath](https://github.com/SL-Pirate))

#### 3.0.0
* breaking change: moved onScaleUpdate callback to the FlowChart widget

#### 2.2.1
* Improved scaling gesture responsiveness (thanks to [Isira Herath](https://github.com/SL-Pirate))
* Fixed scaling of arrows when sooming (thanks to [Isira Herath](https://github.com/SL-Pirate))
* Implemented onScaleUpdate method on dashboard (thanks to [Isira Herath](https://github.com/SL-Pirate))

#### 2.2.0
* added support for scaling/zooming (thanks to [Isira Herath](https://github.com/SL-Pirate))

#### 2.1.4
* fix 'type 'int' is not a subtype of type double' error (by ofbozkurt)
* assigned UUID upon adding creating a new instance of FlowElement (by [Isira Herath](https://github.com/SL-Pirate))

#### 2.1.3
* added fontFamily parameter to the flow_element (thanks to [Isira Herath](https://github.com/SL-Pirate))
* added hexagon element (thanks to ofbozkurt)

#### 2.1.2
* added parameter to notify changes or not in dashboard

#### 2.1.1
* fixed online example link

#### 2.1.0+1
*  Implemented some getters to get the connection and element (thanks to [Isira Herath](https://github.com/SL-Pirate))

#### 2.0.0+1
* Implemented Infinite Scrolling for Dashboard to Enhance Diagram Browsing Experience (thanks to [Isira Herath](https://github.com/SL-Pirate))
* Added support for mouse secondary input events on dashboard and elements (thanks to [Isira Herath](https://github.com/SL-Pirate))

#### 1.0.0+1

* Initial release.

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

/// A kind of element
class ImageWidget extends StatefulWidget {
  /// Requires element.data to be an ImageProvider.
  ImageWidget({
    required this.element,
    super.key,
  })  : assert(element.data is ImageProvider,
            'Missing image ("data" parameter should be an ImageProvider)'),
        imageProvider = element.data as ImageProvider;

  ///
  final FlowElement element;

  /// The image to render
  final ImageProvider imageProvider;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ImageInfo? imageInfo;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadImageData();
  }

  void _loadImageData() {
    // Load image
    widget.imageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener(
          (ImageInfo info, _) {
            // Apply size
            if (widget.element.size == Size.zero) {
              widget.element.changeSize(Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              ));
            }
            // Render image
            setState(() => imageInfo = info);
          },
          onError: (exception, stackTrace) {
            debugPrintStack(stackTrace: stackTrace);
            // Ensure we have a size size
            if (widget.element.size == Size.zero) {
              widget.element.changeSize(const Size(200, 150));
            }
            // Show error
            setState(() => error = exception.toString());
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text(error!));
    } else if (imageInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ColoredBox(
      color: Colors.black12,
      child: Image(
        image: widget.imageProvider,
        width: widget.element.size.width,
        height: widget.element.size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}

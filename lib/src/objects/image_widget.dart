import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

/// A kind of element
class ImageWidget extends StatefulWidget {
  /// Requires element.data to be an ImageProvider.
  ImageWidget({
    required this.element,
    super.key,
  })  : assert(
          element.data is ImageProvider ||
              (element.serializedData?.isNotEmpty ?? false),
          'Missing image ("data" parameter should be an ImageProvider)',
        ),
        imageProvider = element.serializedData?.isNotEmpty ?? false
            ? Image.memory(base64Decode(element.serializedData!)).image
            : element.data as ImageProvider;

  ///
  final FlowElement element;

  /// The image to render
  final ImageProvider imageProvider;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ui.Image? _cachedImage;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImage());
  }

  void _loadImage() {
    // Ensure we have a size size
    final adaptSizeToImage = widget.element.size == Size.zero;
    if (adaptSizeToImage) {
      widget.element.changeSize(const Size(200, 150));
    }
    // Load image
    widget.imageProvider.resolve(ImageConfiguration.empty).addListener(
          ImageStreamListener(
            (ImageInfo info, _) async {
              debugPrint('Image info completed: $info');
              // Adjust size
              if (adaptSizeToImage) {
                widget.element.changeSize(Size(
                  info.image.width.toDouble(),
                  info.image.height.toDouble(),
                ));
              }
              // Serialize image to save/load dashboard
              final imageData =
                  await info.image.toByteData(format: ui.ImageByteFormat.png);
              widget.element.serializedData =
                  base64Encode(imageData!.buffer.asUint8List());
              ui.decodeImageFromList(imageData.buffer.asUint8List(), (image) {
                debugPrint('Image decoding completed: $image');
                // Render image
                if (mounted) setState(() => _cachedImage = image);
              });
            },
            onError: (exception, stackTrace) {
              debugPrintStack(stackTrace: stackTrace);
              if (mounted) setState(() => _error = exception.toString());
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rendering ImageWidget of size ${widget.element.size} '
        'from provider ${widget.imageProvider.runtimeType} '
        'and cachedImage $_cachedImage');

    if (_error != null) {
      return Center(child: Text(_error!));
    } else if (_cachedImage == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ColoredBox(
      color: Colors.black12,
      child: RawImage(
        width: widget.element.size.width,
        height: widget.element.size.height,
        image: _cachedImage,
        fit: BoxFit.contain,
      ),
    );
  }
}

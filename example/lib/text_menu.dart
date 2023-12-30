import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:star_menu/star_menu.dart';

/// Popup menu for the 'element params" entry
class TextMenu extends StatelessWidget {
  final FlowElement element;
  final ValueNotifier<double> sliderSize;
  final ValueNotifier<bool> isBold;
  final TextEditingController textController;

  TextMenu({
    super.key,
    required this.element,
  })  : sliderSize = ValueNotifier(element.textSize),
        isBold = ValueNotifier(element.textIsBold),
        textController = TextEditingController(text: element.text);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: StarMenu(
        params: StarMenuParameters.panel(context, columns: 1).copyWith(
          openDurationMs: 60,
          onHoverScale: 1.0,
          centerOffset: const Offset(100, 100),
        ),
        items: _buildEntries(context),
        child: const Text('Set text'),
      ),
    );
  }

  List<Widget> _buildEntries(BuildContext context) {
    return [
      SizedBox(
        width: 250,
        child: TextField(
          controller: textController,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          minLines: null,
          maxLines: null,
          onChanged: (value) => element.setText(value),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// text color
          IconMenu(
            text: 'Color',
            icon: CircleWidget(backgroundColor: element.textColor),
          ).addStarMenu(
            items: [
              SizedBox(
                width: 300,
                child: FittedBox(
                  child: SizedBox(
                    width: 350,
                    height: 400,
                    child: HueRingPicker(
                      onColorChanged: element.setTextColor,
                      pickerColor: element.textColor,
                      portraitOnly: true,
                    ),
                  ),
                ),
              )
            ],
            params:const StarMenuParameters(centerOffset: Offset(-1000, -1000)),
          ),
          const SizedBox(width: 30),

          /// is bold
          ValueListenableBuilder<bool>(
              valueListenable: isBold,
              builder: (_, value, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('bold '),
                    Checkbox(
                      value: value,
                      onChanged: ((value) {
                        isBold.value = value!;
                        element.setTextIsBold(value);
                      }),
                    ),
                  ],
                );
              }),
        ],
      ),

      /// size
      ValueListenableBuilder<double>(
          valueListenable: sliderSize,
          builder: (_, value, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('size: '),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: Slider.adaptive(
                    value: value,
                    min: 6,
                    max: 50,
                    onChanged: (v) {
                      sliderSize.value = v;
                      element.setTextSize(value);
                    },
                  ),
                ),
              ],
            );
          }),
    ];
  }
}

class IconMenu extends StatelessWidget {
  final Widget icon;
  final String text;

  const IconMenu({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 6),
        Text(text),
      ],
    );
  }
}

class CircleWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;

  const CircleWidget({
    super.key,
    this.width = 48,
    this.height = 48,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(width),
        ),
        border: Border.all(
          width: 2,
          color: borderColor,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

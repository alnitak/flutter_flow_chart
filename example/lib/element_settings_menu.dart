// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:star_menu/star_menu.dart';

/// Popup menu for the 'element params" entry
class ElementSettingsMenu extends StatelessWidget {
  ElementSettingsMenu({
    required this.element,
    super.key,
  })  : sliderThickness = ValueNotifier(element.borderThickness),
        sliderElevation = ValueNotifier(element.elevation);

  final FlowElement element;
  final ValueNotifier<double> sliderThickness;
  final ValueNotifier<double> sliderElevation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: StarMenu(
        params: StarMenuParameters.panel(context, columns: 2)
            .copyWith(openDurationMs: 60, onHoverScale: 1),
        items: _buildEntries(context),
        child: const Text('Element params'),
      ),
    );
  }

  List<Widget> _buildEntries(BuildContext context) {
    return [
      IconMenu(
        text: 'Background color',
        icon: CircleWidget(backgroundColor: element.backgroundColor),
      ).addStarMenu(
        items: [
          SizedBox(
            width: 300,
            child: FittedBox(
              child: SizedBox(
                width: 350,
                height: 400,
                child: HueRingPicker(
                  onColorChanged: element.setBackgroundColor,
                  pickerColor: element.backgroundColor,
                  portraitOnly: true,
                ),
              ),
            ),
          ),
        ],
        params: const StarMenuParameters(centerOffset: Offset(-1000, -1000)),
      ),

      /// Thickness
      ValueListenableBuilder<double>(
        valueListenable: sliderThickness,
        builder: (_, value, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('thickness: '),
              SizedBox(
                width: 200,
                height: 50,
                child: Slider.adaptive(
                  value: value,
                  max: 25,
                  onChanged: (v) {
                    sliderThickness.value = v;
                    element.setBorderThickness(value);
                  },
                ),
              ),
            ],
          );
        },
      ),
      IconMenu(
        text: 'Border color',
        icon: CircleWidget(backgroundColor: element.borderColor),
      ).addStarMenu(
        items: [
          SizedBox(
            width: 250,
            child: FittedBox(
              child: SizedBox(
                width: 350,
                height: 500,
                child: HueRingPicker(
                  onColorChanged: element.setBorderColor,
                  pickerColor: element.borderColor,
                  portraitOnly: true,
                ),
              ),
            ),
          ),
        ],
        params: const StarMenuParameters(centerOffset: Offset(-1000, -1000)),
      ),

      /// Elevation
      ValueListenableBuilder<double>(
        valueListenable: sliderElevation,
        builder: (_, value, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('elevation: '),
              SizedBox(
                width: 200,
                height: 50,
                child: Slider.adaptive(
                  value: value,
                  divisions: 16,
                  min: -1,
                  max: 15,
                  onChanged: (v) {
                    sliderElevation.value = v;
                    element.setElevation(value);
                  },
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}

class IconMenu extends StatelessWidget {
  const IconMenu({
    required this.icon,
    required this.text,
    super.key,
  });
  final Widget icon;
  final String text;

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
  const CircleWidget({
    super.key,
    this.width = 48,
    this.height = 48,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black,
  });
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;

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
        ),
      ),
    );
  }
}

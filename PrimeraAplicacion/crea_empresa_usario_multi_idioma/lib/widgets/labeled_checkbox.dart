import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 4),
    this.chekBoxIzqda = true,
    this.textStyle,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool chekBoxIzqda;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Wrap(
          // crossAxisAlignment: ,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: _getWidgets(context),
        ),
      ),
    );
  }

  List<Widget> _getWidgets(BuildContext context) {
    List<Widget> wdgt = [
      Checkbox(
        value: value,
        onChanged: (bool? newValue) {
          onChanged(newValue!);
        },
      ),
      Text(label, style: textStyle),
    ];

    if (chekBoxIzqda) {
      wdgt = wdgt.reversed.toList();
    }
    return wdgt;
  }
}

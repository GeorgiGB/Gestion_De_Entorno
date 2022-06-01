import 'package:crea_empresa_usuario_multi_idioma/colores.dart';
import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox(
      {Key? key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.padding = const EdgeInsets.fromLTRB(4, 4, 4, 4),
      this.chekBoxIzqda = true,
      this.textStyle,
      this.enabled = true})
      : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool chekBoxIzqda;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () {
              onChanged(!value);
            }
          : null,
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
        activeColor: PaletaColores.colorMorado,
        value: value,
        onChanged: enabled
            ? (bool? newValue) {
                onChanged(newValue!);
              }
            : null,
      ),
      Text(label,
          style: textStyle?.copyWith(
              color: enabled
                  ? textStyle!.color
                  : Theme.of(context).disabledColor)),
    ];

    if (chekBoxIzqda) {
      wdgt = wdgt.reversed.toList();
    }
    return wdgt;
  }
}

library dropdownfield;

// tomado de: https://pub.dev/packages/dropdownfield
// modificado por Joan Navarro Ribes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../listado_empresas/empresa_future.dart';

///DropDownField has customized autocomplete text field functionality
///
///Parameters
///
///value - dynamic - Optional value to be set into the Dropdown field by default when this field renders
///
///icon - Widget - Optional icon to be shown to the left of the Dropdown field
///
///hintText - String - Optional Hint text to be shown
///
///hintStyle - TextStyle - Optional styling for Hint text. Default is normal, gray colored font of size 18.0
///
///labelText - String - Optional Label text to be shown
///
///labelStyle - TextStyle - Optional styling for Label text. Default is normal, gray colored font of size 18.0
///
///required - bool - True will validate that this field has a non-null/non-empty value. Default is false
///
///enabled - bool - False will disable the field. You can unset this to use the Dropdown field as a read only form field. Default is true
///
///items - List<DropDownIntericie> - List of items to be shown as suggestions in the Dropdown. Typically a list of String values.
///You can supply a static list of values or pass in a DropDownIntericie list using a FutureBuilder
///
///textStyle - TextStyle - Optional styling for text shown in the Dropdown. Default is bold, black colored font of size 14.0
///
///inputFormatters - List<TextInputFormatter> - Optional list of TextInputFormatter to format the text field
///
///setter - FormFieldSetter<dynamic> - Optional implementation of your setter method. Will be called internally by Form.save() method
///
///onValueChanged - ValueChanged<dynamic> - Optional implementation of code that needs to be executed when the value in the Dropdown
///field is changed
///
///strict - bool - True will validate if the value in this dropdown is amongst those suggestions listed.
///False will let user type in new values as well. Default is true
///
///itemsVisibleInDropdown - int - Number of suggestions to be shown by default in the Dropdown after which the list scrolls. Defaults to 3

// Para utilizar este widget los items que se passen tienen que implementar esta interfície
abstract class DropDownIntericie {
  // El texto que se va a poner en TextFormField
  String string();

  // Sobrescribimos para poder comparar un string con el objeto
  bool operator ==(dynamic other);

  // Obtenemos el Widget para presentar en el LisTile
  Widget get widget;
}

// añadido nullSafety
class DropDownField extends FormField<String> {
  final dynamic value;
  final Widget? icon;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final bool required;
  final bool enabled;
  final List<DropDownIntericie> items;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldSetter<dynamic>? setter;
  final ValueChanged<DropDownIntericie>? onValueChanged;
  final bool strict;
  final int itemsVisibleInDropdown;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController controller;

  // Para enviar el foco en el momento de pulsar limpiar y al desplegar la lista.
  // También utilizado para cerrar la lista en el momento de perder el foco
  final FocusNode focusNode;

  DropDownField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.items,
    this.value,
    this.required = false,
    this.icon,
    this.hintText,
    this.hintStyle = const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 18.0),
    this.labelText,
    this.labelStyle = const TextStyle(
        fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 18.0),
    this.inputFormatters,
    this.textStyle = const TextStyle(
        fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0),
    this.setter,
    this.onValueChanged,
    this.itemsVisibleInDropdown = 3,
    this.enabled = true,
    this.strict = true,
  }) : super(
          key: key,
          autovalidateMode: AutovalidateMode.disabled,
          initialValue: controller
              .text, //controller != null ? controller.text : (value ?? ''),
          onSaved: setter,
          builder: (FormFieldState<String> field) {
            final DropDownFieldState ddfState = field as DropDownFieldState;
            final InputDecoration effectiveDecoration = InputDecoration(
                border: InputBorder.none,
                filled: true,
                icon: icon,
                suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down,
                        size: 30.0, color: Colors.black),
                    onPressed: () {
                      ddfState.toggleDropDownVisibility();
                    }),
                hintStyle: hintStyle,
                labelStyle: labelStyle,
                hintText: hintText,
                labelText: labelText);

            return Focus(
              onFocusChange: (hasFocus) {
                print("foco: " + hasFocus.toString());
                if (hasFocus) {
                  //ddfState.ocultaDropDown();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          controller: ddfState._effectiveController,
                          decoration: effectiveDecoration.copyWith(
                              errorText: field.errorText),
                          style: textStyle,
                          textAlign: TextAlign.start,
                          autofocus: false,
                          focusNode: focusNode,
                          obscureText: false,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLines: 1,
                          validator: (String? newValue) {
                            if (required) {
                              if (newValue == null || newValue.isEmpty) {
                                return 'This field cannot be empty!';
                              }
                            }

                            //Items null check added since there could be an initial brief period of time
                            //when the dropdown items will not have been loaded
                            if (strict &&
                                newValue!.isNotEmpty &&
                                !items.contains(newValue)) {
                              return 'Invalid value in this field!';
                            }

                            return null;
                          },
                          onSaved: setter,
                          enabled: enabled,
                          inputFormatters: inputFormatters,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        // limpiamos el texto del TextFormField
                        onPressed: () {
                          if (!enabled) return;
                          print("jo");
                          ddfState.clearValue();
                        },
                      )
                    ],
                  ),
                  _getContainer(ddfState, itemsVisibleInDropdown),
                ],
              ),
            );
          },
        );

  @override
  DropDownFieldState createState() => DropDownFieldState();

  static Container _getContainer(
      DropDownFieldState ddfState, int itemsVisibleInDropdown) {
    final ScrollController _scrollController = ScrollController();
    return !ddfState._showdropdown
        ? Container()
        : Container(
            alignment: Alignment.topCenter,
            height: itemsVisibleInDropdown *
                48.0, //limit to default 3 items in dropdownlist view and then remaining scrolls
            width: MediaQuery.of(ddfState.context).size.width,
            child: ListView(
              cacheExtent: 0.0,
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 40.0),
              children: ddfState._items.isNotEmpty
                  ? ListTile.divideTiles(
                          context: ddfState.context,
                          tiles: ddfState._getChildren(ddfState._items))
                      .toList()
                  : [],
            ),
          );
  }
}

class DropDownFieldState extends FormFieldState<String> {
  //TextEditingController? _controller;
  bool _showdropdown = false;
  bool _isSearching = true;
  String _searchText = "";

  @override
  DropDownField get widget => super.widget as DropDownField;
  TextEditingController get _effectiveController =>
      widget.controller; //?? _controller;

  List<DropDownIntericie> get _items => widget.items;

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    /*if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    }*/

    _effectiveController.addListener(_handleControllerChanged);

    _searchText = _effectiveController.text;

    widget.focusNode.addListener(() async {
      if (!widget.focusNode.hasFocus) {
        // Esperamos 250 ms i si no ha recuperado el foco Ocultamos el List View
        await Future.delayed(const Duration(milliseconds: 250));
        if (!widget.focusNode.hasFocus) {
          ocultaDropDown();
        }
      }
    });
  }

  void ocultaDropDown() {
    setState(() {
      _showdropdown = false;
    });
  }

  void toggleDropDownVisibility() {
    // Oculta el teclat dels mòbils
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _showdropdown = !_showdropdown;
      if (_showdropdown) {
        // ponemos el foco en TextFormField
        widget.focusNode.requestFocus();
      }
    });
  }

  void clearValue() {
    setState(() {
      _effectiveController.text = '';
      widget.focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(DropDownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);

      /*if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller?.value);
      }
      if (widget.controller != null) {
        setValue(widget.controller?.text);
        if (oldWidget.controller == null) _controller = null;
      }*/
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue!;
    });
  }

  List<ListTile> _getChildren(List<DropDownIntericie> items) {
    List<ListTile> childItems = [];
    for (var item in items) {
      if (_searchText.isNotEmpty) {
        if (item.string().toUpperCase().contains(_searchText.toUpperCase())) {
          childItems.add(_getListTile(item));
        }
      } else {
        childItems.add(_getListTile(item));
      }
    }
    _isSearching ? childItems : [];
    return childItems;
  }

  ListTile _getListTile(DropDownIntericie ddi) {
    return ListTile(
      dense: true,
      title: ddi.widget,
      onTap: () {
        print("Tap");
        setState(() {
          _effectiveController.text = ddi.string();
          _handleControllerChanged();
          _showdropdown = false;
          _isSearching = false;
          if (widget.onValueChanged != null) widget.onValueChanged!(ddi);
        });
      },
    );
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }

    if (_effectiveController.text.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchText = "";
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchText = _effectiveController.text;
        _showdropdown = true;
      });
    }
  }
}

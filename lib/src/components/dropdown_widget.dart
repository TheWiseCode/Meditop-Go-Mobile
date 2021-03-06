import 'package:flutter/material.dart';
import 'package:meditop_go/src/components/text_field_container.dart';

class DropdownWidget extends StatefulWidget {
  String? value;
  int? selectedItem;
  double? width;
  List<String>? items;

  DropdownWidget({Key? key, this.width, required this.items})
      : super(key: key) {
    value = items![0];
    selectedItem = 0;
  }

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();

  int? posValue(String? newValue) {
    for (int i = 0; i < items!.length; i++)
      if (newValue == items![i]) return i;
    return -1;
  }
}

class _DropdownWidgetState extends State<DropdownWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.width == null) widget.width = size.width * 0.8;
    return TextFieldContainer(
        width: widget.width,
        child: DropdownButton<String>(
          value: widget.value,
          isExpanded: true,
          //icon: const Icon(Icons.arrow_downward),
          //iconSize: 24,
          elevation: 16,
          underline: Container(height: 0),
          onChanged: (String? newValue) {
            setState(() {
              widget.selectedItem = widget.posValue(newValue);
              widget.value = newValue!;
            });
          },
          items: widget.items!.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }
}

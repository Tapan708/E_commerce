import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final String labeltext;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final int? digit;
  final int? maxlines;
  final Icon? prefixicon;
  final IconButton? suffixicon;
  final String? Function(String?) validator;


  CustomTextField({
    super.key,
    required this.labeltext,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    required this.textInputType,
    required this.validator,
    this.maxlines,
    this.digit,
    this.prefixicon,
    this.suffixicon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        maxLines: maxlines,
        maxLength: digit,
        validator: validator,
        textInputAction: textInputAction,
        keyboardType: textInputType,
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontSize: 14.4),
          prefixIcon: prefixicon,
            suffixIcon: suffixicon,
            border: OutlineInputBorder(),
            labelText: labeltext
        ),
      ),
    );
  }
}

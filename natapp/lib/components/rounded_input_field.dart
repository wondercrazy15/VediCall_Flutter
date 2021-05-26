import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:natapp/components/text_field_container.dart';
import 'package:natapp/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Function validation;
  final ValueChanged<String> onChanged;
  final TextEditingController inputController;
  final FocusNode focusNode;

  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.validation,
    this.onChanged,
    this.inputController,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: inputController,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        validator: validation,
        onFieldSubmitted: (value){
          focusNode.nextFocus();
        },
        textInputAction:TextInputAction.next,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

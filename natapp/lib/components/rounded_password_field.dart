import 'package:flutter/material.dart';
import 'package:natapp/components/text_field_container.dart';
import 'package:natapp/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final Function validation;
  final TextEditingController inputController;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.validation,
    this.inputController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: inputController,
        obscureText: true,
        onChanged: onChanged,
        validator: validation,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (text.length > 5) {
      text = text.substring(0, 5);
    }

    if (oldValue.text == text) {
      return newValue;
    }

    if (text.length == 3 && !text.endsWith('/')) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

import 'package:flutter/services.dart';

// Format: 077 12 34 56 (9 chiffres, groupes 3-2-2-2)
class GabonPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 9) return oldValue;

    final formatted = formatLocal(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// "077123456" -> "077 12 34 56"
  static String formatLocal(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

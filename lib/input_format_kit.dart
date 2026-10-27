import 'package:flutter/services.dart';

/// Formats numeric input using Indian digit grouping.
///
/// Examples:
/// 1234 -> 1,234
/// 123456 -> 1,23,456
/// 1234567 -> 12,34,567
///
class IndianCurrencyInputFormatter extends TextInputFormatter {
  IndianCurrencyInputFormatter({this.decimalRange = 2})
    : assert(decimalRange >= 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Preserve the number of meaningful characters before the cursor.
    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );

    final meaningfulBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .length;

    // Allow digits and a decimal point only.
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    final dotIndex = raw.indexOf('.');

    final integerPart = (dotIndex == -1 ? raw : raw.substring(0, dotIndex))
        .replaceAll('.', '');

    var decimalPart = dotIndex == -1 ? '' : raw.substring(dotIndex + 1);

    // Keep only one decimal point and the configured precision.
    decimalPart = decimalPart.replaceAll('.', '');

    if (decimalPart.length > decimalRange) {
      decimalPart = decimalPart.substring(0, decimalRange);
    }

    final groupedInteger = _groupIndianDigits(integerPart);

    final hasDecimalPoint = dotIndex != -1 && decimalRange > 0;

    final formatted = groupedInteger + (hasDecimalPoint ? '.$decimalPart' : '');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _cursorOffset(formatted, meaningfulBeforeCursor),
      ),
    );
  }
}

String _groupIndianDigits(String digits) {
  if (digits.length <= 3) return digits;

  final lastThree = digits.substring(digits.length - 3);
  var remaining = digits.substring(0, digits.length - 3);

  final groups = <String>[];

  while (remaining.length > 2) {
    groups.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }

  if (remaining.isNotEmpty) {
    groups.insert(0, remaining);
  }

  return '${groups.join(',')},$lastThree';
}

int _cursorOffset(String text, int meaningfulCount) {
  if (meaningfulCount == 0) return 0;

  var seen = 0;

  for (var i = 0; i < text.length; i++) {
    if (RegExp(r'[0-9.]').hasMatch(text[i])) {
      seen++;

      if (seen >= meaningfulCount) {
        return i + 1;
      }
    }
  }

  return text.length;
}

/// Allows digits only and preserves the cursor position.
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    var seen = 0;
    var newCursor = 0;

    for (var i = 0; i < digits.length; i++) {
      seen++;

      if (seen >= digitsBeforeCursor) {
        newCursor = i + 1;
        break;
      }

      newCursor = i + 1;
    }

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}

/// Allows digits only, with a configurable maximum length.
///
/// By default, limits input to 10 digits. This does not validate
/// whether a phone number is assigned or belongs to a real subscriber.
class IndianPhoneNumberFormatter extends TextInputFormatter {
  IndianPhoneNumberFormatter({this.maxLength = 10}) : assert(maxLength > 0);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    final limited = digits.length > maxLength
        ? digits.substring(0, maxLength)
        : digits;

    final newCursor = digitsBeforeCursor.clamp(0, limited.length);

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}

/// Allows decimal input with configurable precision.
///
/// Examples:
/// DecimalInputFormatter(decimalRange: 2)
/// 123.456 -> 123.45
///
/// This formatter allows only one decimal point.
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimalRange = 2, this.allowNegative = false})
    : assert(decimalRange >= 0);

  final int decimalRange;
  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );

    final beforeCursor = newValue.text.substring(0, cursor);

    final meaningfulBeforeCursor = beforeCursor
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .length;

    var raw = newValue.text.replaceAll(
      RegExp(allowNegative ? r'[^0-9.\-]' : r'[^0-9.]'),
      '',
    );

    var negative = false;

    if (allowNegative && raw.startsWith('-')) {
      negative = true;
    }

    raw = raw.replaceAll('-', '');

    final dotIndex = raw.indexOf('.');
    final integerPart = dotIndex == -1 ? raw : raw.substring(0, dotIndex);

    var decimalPart = dotIndex == -1 ? '' : raw.substring(dotIndex + 1);

    if (decimalPart.length > decimalRange) {
      decimalPart = decimalPart.substring(0, decimalRange);
    }

    final hasDecimalPoint = dotIndex != -1 && decimalRange > 0;

    final formatted =
        '${negative ? '-' : ''}$integerPart'
        '${hasDecimalPoint ? '.$decimalPart' : ''}';

    final meaningfulCount =
        meaningfulBeforeCursor +
        (negative && beforeCursor.startsWith('-') ? 1 : 0);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _decimalCursorOffset(formatted, meaningfulCount),
      ),
    );
  }
}

int _decimalCursorOffset(String text, int meaningfulCount) {
  if (meaningfulCount <= 0) return 0;

  var seen = 0;

  for (var i = 0; i < text.length; i++) {
    if (RegExp(r'[0-9.]').hasMatch(text[i])) {
      seen++;

      if (seen >= meaningfulCount) {
        return i + 1;
      }
    }
  }

  return text.length;
}

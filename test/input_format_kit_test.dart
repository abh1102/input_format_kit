import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:input_format_kit/input_format_kit.dart';

void main() {
  group('IndianCurrencyInputFormatter', () {
    final formatter = IndianCurrencyInputFormatter();

    String format(String input) {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
          text: input,
          selection: TextSelection.collapsed(offset: input.length),
        ),
      );

      return result.text;
    }

    test('formats thousands', () {
      expect(format('1234'), '1,234');
    });

    test('formats lakhs', () {
      expect(format('123456'), '1,23,456');
    });

    test('formats crores', () {
      expect(format('12345678'), '1,23,45,678');
    });

    test('preserves decimal values', () {
      expect(format('1234567.89'), '12,34,567.89');
    });

    test('limits decimal precision', () {
      expect(format('1234.567'), '1,234.56');
    });

    test('handles empty input', () {
      expect(format(''), '');
    });

    test('supports integer-only mode', () {
      final integerFormatter = IndianCurrencyInputFormatter(decimalRange: 0);

      final result = integerFormatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1234.56'),
      );

      expect(result.text, '1,234');
    });
  });

  group('DigitsOnlyFormatter', () {
    final formatter = DigitsOnlyFormatter();

    test('removes letters and special characters', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '12ab-34'),
      );

      expect(result.text, '1234');
    });

    test('preserves an empty input', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: ''),
      );

      expect(result.text, '');
    });
  });
}

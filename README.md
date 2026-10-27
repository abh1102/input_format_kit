# input_format_kit

A Flutter package providing reusable input formatters for Indian currency, decimal values, phone numbers, and numeric input.

## Features

- **Indian currency formatting** — Group digits using the Indian numbering system, such as `12,34,567.89`.
- **Digits-only input** — Remove non-numeric characters.
- **Indian phone number input** — Limit input to a configurable number of digits.
- **Decimal input** — Configure decimal precision and optionally allow negative values.
- **Cursor positioning** — Designed to preserve cursor position during common editing operations.
- **Lightweight API** — Integrates with Flutter's built-in `TextInputFormatter` API.

## Getting started

Add the package to your Flutter project:

```bash
flutter pub add input_format_kit
```

Import it into your Dart file:

```dart
import 'package:input_format_kit/input_format_kit.dart';
```

## Usage

### 1. Indian currency formatter

Formats numbers using Indian digit grouping.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    IndianCurrencyInputFormatter(decimalRange: 2),
  ],
  decoration: const InputDecoration(
    labelText: 'Amount',
    prefixText: '₹ ',
  ),
)
```

Example: `1234567.89` becomes `12,34,567.89`.

The formatter does not insert the currency symbol into the editable value.

### 2. Digits-only formatter

Allows numeric characters only.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    DigitsOnlyFormatter(),
  ],
  decoration: const InputDecoration(
    labelText: 'Numeric value',
  ),
)
```

Example: `12ab34` becomes `1234`.

### 3. Indian phone number formatter

Limits input to 10 digits by default.

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    IndianPhoneNumberFormatter(),
  ],
  decoration: const InputDecoration(
    labelText: 'Mobile number',
  ),
)
```

You can configure a different maximum length:

```dart
IndianPhoneNumberFormatter(maxLength: 6)
```

This formatter limits input length; it does not verify whether a phone number is valid or assigned.

### 4. Decimal input formatter

Limits decimal precision and optionally permits negative values.

```dart
TextField(
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
    signed: true,
  ),
  inputFormatters: [
    DecimalInputFormatter(
      decimalRange: 2,
      allowNegative: true,
    ),
  ],
  decoration: const InputDecoration(
    labelText: 'Decimal value',
  ),
)
```

Example: `123.456` becomes `123.45`.

## Testing

Run the package tests:

```bash
flutter test
```

Analyze the code:

```bash
flutter analyze
```

## Compatibility

This package uses Flutter's `TextInputFormatter` API. Verify behavior on your target platforms and test editing, selection, deletion, and pasted input before relying on it in production.

## Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Open an issue describing the problem or proposed improvement.
2. Fork the repository and create a branch.
3. Add tests for your changes.
4. Run `dart format lib test`, `flutter analyze`, and `flutter test`.
5. Submit a pull request.

## License

This project is distributed under the license included in the `LICENSE` file.

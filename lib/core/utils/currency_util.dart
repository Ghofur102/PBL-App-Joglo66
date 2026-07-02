import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyUtil {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _dotFormatter = NumberFormat('#,##0', 'id_ID');

  static String toRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final int value = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    return _currencyFormatter.format(value);
  }

  static String toDotFormat(dynamic amount) {
    if (amount == null) return '0';
    final int value = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    return _dotFormatter.format(value);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final String cleanString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanString.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final int value = int.parse(cleanString);
    final String formattedText = NumberFormat('#,##0', 'id_ID').format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

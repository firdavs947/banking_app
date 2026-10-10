class CardValidators {
  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter the card holder name';
    }
    return null;
  }

  static String? number(String? value) {
    if ((value ?? '').replaceAll(' ', '').length != 16) {
      return 'Card number must have 16 digits';
    }
    return null;
  }

  static String? expiry(String? value) {
    final text = value ?? '';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(text)) {
      return 'Use MM/YY';
    }
    final month = int.parse(text.substring(0, 2));
    final year = 2000 + int.parse(text.substring(3));
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Card has expired';
    }
    return null;
  }

  static String? cvv(String? value) {
    if ((value ?? '').length != 3) {
      return '3 digits';
    }
    return null;
  }
}
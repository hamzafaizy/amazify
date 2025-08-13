/// Collection of common validation helpers for forms & user input.
class Validator {
  Validator._();

  /// Checks if the field is not empty.
  static String? requiredField(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    const pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
        r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
        r"[a-zA-Z0-9])?)*$";
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates password with min length and optional complexity.
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (requireNumber && !value.contains(RegExp(r'\d'))) {
      return 'Password must contain at least one number';
    }
    if (requireSpecialChar && !value.contains(RegExp(r'[!@#\$&*~]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates a full name (two words minimum).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return 'Enter your full name';
    }
    return null;
  }

  /// Validates a phone number (basic). Can be adapted per locale.
  static String? phoneNumber(String? value, {int minLength = 10}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minLength) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates an international phone number in E.164 format.
  static String? internationalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final regex = RegExp(r'^\+[1-9]\d{6,14}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid international phone number (e.g., +1234567890)';
    }
    return null;
  }

  /// Validates credit card number (Luhn check).
  static String? creditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Enter a valid card number';
    }
    if (!_luhnCheck(digits)) {
      return 'Invalid card number';
    }
    return null;
  }

  /// Validates CVV/CVC code (3 or 4 digits).
  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }
    final regex = RegExp(r'^\d{3,4}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid CVV';
    }
    return null;
  }

  /// Validates postal/ZIP code.
  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    final regex = RegExp(r'^[A-Za-z0-9\- ]{3,10}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  /// Validates a positive price.
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final num? price = num.tryParse(value);
    if (price == null || price <= 0) {
      return 'Enter a valid price';
    }
    return null;
  }

  /// Validates a positive quantity.
  static String? quantity(String? value, {int min = 1}) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final int? qty = int.tryParse(value);
    if (qty == null || qty < min) {
      return 'Quantity must be at least $min';
    }
    return null;
  }

  // ─────────── Internal helpers ───────────

  static bool _luhnCheck(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? plateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Plate number is required';
    if (value.trim().length < 2) return 'Enter a valid plate number';
    return null;
  }

  static String? mileage(String? value) {
    if (value == null || value.isEmpty) return 'Mileage is required';
    final miles = int.tryParse(value);
    if (miles == null || miles < 0) return 'Enter a valid mileage';
    return null;
  }

  static String? cost(String? value) {
    if (value == null || value.isEmpty) return null;
    final amount = double.tryParse(value);
    if (amount == null || amount < 0) return 'Enter a valid amount';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}

class Validators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? minLength(String? value, String label, int min) {
    final requiredError = required(value, label);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) {
      return '$label must be at least $min characters';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) return requiredError;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

    static const List<String> allowedEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  static String? aluEmail(String? value) {
    final baseError = email(value);
    if (baseError != null) return baseError;

    final domain = value!.trim().toLowerCase().split('@').last;
    if (!allowedEmailDomains.contains(domain)) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }
}
import 'package:campus_reporter/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email accepts a valid address', () {
      expect(Validators.email('student@campus.edu'), isNull);
    });

    test('email rejects an invalid address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('password requires at least six characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword detects a mismatch', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('minLength enforces the minimum', () {
      expect(Validators.minLength('abc', 'Title', 5), isNotNull);
      expect(Validators.minLength('abcde', 'Title', 5), isNull);
    });
  });
}
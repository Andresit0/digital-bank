import 'package:digital_bank/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthResponseModel', () {
    test('parses the access token from JSON', () {
      final model = AuthResponseModel.fromJson({'accessToken': 'token-123'});

      expect(model.accessToken, 'token-123');
    });
  });
}

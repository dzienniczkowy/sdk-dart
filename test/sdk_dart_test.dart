import 'package:sdk_dart/src/login/login_helper.dart';
import 'package:test/test.dart';

void main() {
  group('Standard login', () {
    LoginHelper loginHelper;

    setUp(() {
      loginHelper = LoginHelper('https', 'fakelog.cf', 'powiatwulkanowy');
    });

    test('should successfully login', () async {
      final login = await loginHelper.login('jan@fakelog.cf', 'jan123');
      expect(login.length, 3);
    });
  });
}

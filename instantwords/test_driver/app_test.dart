// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('InstantWords App', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final counterTextFinder = find.byValueKey('counter');
    final buttonFinder = find.byValueKey('increment');
    final emailFinder = find.byValueKey('email');
    final passwordFinder = find.byValueKey('password');
    final loginButton = find.byValueKey('login_button');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

	test('starts clear', () async {
		expect(await driver.getText(emailFinder), "");
		expect(await driver.getText(passwordFinder), "");
	});
	

	test('fail login', () async {
		await driver.tap(loginButton);
		await driver.waitFor(find.text('Login Failed'));
		await driver.tap(find.byValueKey('approve_failed'));
	});

    test('fills login', () async {
		await driver.tap(emailFinder);
		await driver.enterText('teste@gmail.com');
		await driver.tap(passwordFinder);
		await driver.enterText('1234567890');
		await driver.tap(loginButton);
		await driver.waitFor(find.text('Conferences'));
    });

  });
}

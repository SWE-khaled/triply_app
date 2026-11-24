import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triply/core/theme/theme_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tourist and guide dark-mode preferences are independent', () async {
    SharedPreferences.setMockInitialValues({'theme_mode_shared-user': true});
    final theme = ThemeCubit();
    addTearDown(theme.close);

    await theme.loadForAccount('shared-user', role: 'guide');
    expect(theme.state, isFalse);

    await theme.setDarkMode(true, role: 'guide');
    await theme.loadForAccount('shared-user', role: 'tourist');
    expect(theme.state, isTrue);

    await theme.setDarkMode(false, role: 'tourist');
    await theme.loadForAccount('shared-user', role: 'guide');
    expect(theme.state, isTrue);
  });
}

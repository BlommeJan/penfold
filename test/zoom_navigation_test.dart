import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/services/zoom_navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ZoomNavigationService.instance.resetForTests();
  });

  group('ZoomNavigationService', () {
    test('defaults to enabled', () async {
      await ZoomNavigationService.instance.load();
      expect(ZoomNavigationService.instance.enabled, isTrue);
    });

    test('save and load roundtrip', () async {
      await ZoomNavigationService.instance.setEnabled(false);
      ZoomNavigationService.instance.resetForTests();
      await ZoomNavigationService.instance.load();
      expect(ZoomNavigationService.instance.enabled, isFalse);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        ZoomNavigationService.prefKey: false,
      });
      ZoomNavigationService.instance.resetForTests();
      await ZoomNavigationService.instance.load();
      expect(ZoomNavigationService.instance.enabled, isFalse);
    });
  });
}

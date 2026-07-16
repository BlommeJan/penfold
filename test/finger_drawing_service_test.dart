import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/services/finger_drawing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FingerDrawingService.instance.resetForTests();
  });

  group('FingerDrawingService', () {
    test('defaults to stylus-only (finger drawing off)', () async {
      await FingerDrawingService.instance.load();
      expect(FingerDrawingService.instance.enabled, isFalse);
      expect(FingerDrawingService.instance.stylusOnly, isTrue);
    });

    test('save and load roundtrip', () async {
      await FingerDrawingService.instance.setEnabled(true);
      FingerDrawingService.instance.resetForTests();
      await FingerDrawingService.instance.load();
      expect(FingerDrawingService.instance.enabled, isTrue);
      expect(FingerDrawingService.instance.stylusOnly, isFalse);
    });

    test('persists disabled state', () async {
      await FingerDrawingService.instance.setEnabled(true);
      await FingerDrawingService.instance.setEnabled(false);
      FingerDrawingService.instance.resetForTests();
      await FingerDrawingService.instance.load();
      expect(FingerDrawingService.instance.enabled, isFalse);
    });
  });
}

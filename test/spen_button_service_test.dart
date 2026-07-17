import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/spen_button_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SpenButtonService.instance.resetForTests();
  });

  group('SpenBarrelAction', () {
    test('eraser maps to ToolType.eraser', () {
      expect(SpenBarrelAction.eraser.toolType, ToolType.eraser);
    });

    test('none maps to null tool', () {
      expect(SpenBarrelAction.none.toolType, isNull);
    });

    test('fromPref defaults to eraser', () {
      expect(SpenBarrelAction.fromPref(null), SpenBarrelAction.eraser);
      expect(SpenBarrelAction.fromPref('unknown'), SpenBarrelAction.eraser);
    });
  });

  group('SpenButtonService', () {
    test('defaults to eraser action', () async {
      await SpenButtonService.instance.load();
      expect(SpenButtonService.instance.action, SpenBarrelAction.eraser);
    });

    test('save and load roundtrip', () async {
      await SpenButtonService.instance.setAction(SpenBarrelAction.lasso);
      SpenButtonService.instance.resetForTests();
      await SpenButtonService.instance.load();
      expect(SpenButtonService.instance.action, SpenBarrelAction.lasso);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        SpenButtonService.prefKey: 'pen',
      });
      SpenButtonService.instance.resetForTests();
      await SpenButtonService.instance.load();
      expect(SpenButtonService.instance.action, SpenBarrelAction.pen);
    });

    test('updateFromPointer release via buttons==0 on non-Android', () {
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0x20,
      );
      expect(SpenButtonService.instance.buttonPressed, isTrue);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0,
      );
      expect(SpenButtonService.instance.buttonPressed, isFalse);
    });

    test('releaseFromPointer clears press state', () {
      SpenButtonService.instance.setButtonPressedForTests(true);
      expect(SpenButtonService.instance.buttonPressed, isTrue);
      SpenButtonService.instance.releaseFromPointer(PointerDeviceKind.stylus);
      expect(SpenButtonService.instance.buttonPressed, isFalse);
    });

    test('updateFromPointer ignores finger input', () {
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.touch,
        0x20,
      );
      expect(SpenButtonService.instance.buttonPressed, isFalse);
    });

    test('updateFromPointer ignores when action is none', () async {
      await SpenButtonService.instance.setAction(SpenBarrelAction.none);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0x20,
      );
      expect(SpenButtonService.instance.buttonPressed, isFalse);
    });

    test('secondary barrel button triggers override', () {
      expect(SpenButtonService.instance.overrideTool, isNull);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0x40,
      );
      expect(SpenButtonService.instance.overrideTool, ToolType.eraser);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0,
      );
      expect(SpenButtonService.instance.overrideTool, isNull);
    });

    test('stylusButtonsPressed detects primary and secondary', () {
      expect(SpenButtonService.stylusButtonsPressed(0), isFalse);
      expect(SpenButtonService.stylusButtonsPressed(0x20), isTrue);
      expect(SpenButtonService.stylusButtonsPressed(0x40), isTrue);
      expect(SpenButtonService.stylusButtonsPressed(0x60), isTrue);
    });
  });
}

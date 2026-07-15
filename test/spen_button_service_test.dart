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

    test('overrideTool follows button state', () {
      expect(SpenButtonService.instance.overrideTool, isNull);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0x20,
      );
      expect(SpenButtonService.instance.overrideTool, ToolType.eraser);
      SpenButtonService.instance.updateFromPointer(
        PointerDeviceKind.stylus,
        0,
      );
      expect(SpenButtonService.instance.overrideTool, isNull);
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
  });
}

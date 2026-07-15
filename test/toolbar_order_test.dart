import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/services/toolbar_order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ToolbarOrderService.instance.resetForTests();
  });

  test('normalizeOrder returns default when saved is null or empty', () {
    expect(
      ToolbarOrderService.normalizeOrder(null),
      ToolbarToolId.defaultOrder,
    );
    expect(
      ToolbarOrderService.normalizeOrder([]),
      ToolbarToolId.defaultOrder,
    );
  });

  test('normalizeOrder appends missing default tools', () {
    final saved = [
      ToolbarToolId.eraser,
      ToolbarToolId.pen,
    ];
    final normalized = ToolbarOrderService.normalizeOrder(saved);
    expect(normalized.indexOf(ToolbarToolId.eraser), 0);
    expect(normalized.indexOf(ToolbarToolId.pen), 1);
    expect(normalized, contains(ToolbarToolId.highlighter));
    expect(normalized.length, ToolbarToolId.defaultOrder.length);
  });

  test('save and load order roundtrip', () async {
    final customOrder = [
      ToolbarToolId.lasso,
      ToolbarToolId.pen,
      ToolbarToolId.eraser,
      ToolbarToolId.highlighter,
      ToolbarToolId.selection,
      ToolbarToolId.shape,
      ToolbarToolId.fill,
      ToolbarToolId.text,
      ToolbarToolId.insertImage,
    ];

    await ToolbarOrderService.instance.saveOrder(customOrder);
    ToolbarOrderService.instance.resetForTests();
    await ToolbarOrderService.instance.load();

    expect(ToolbarOrderService.instance.order, customOrder);
  });

  test('load uses default order when preference is unset', () async {
    await ToolbarOrderService.instance.load();
    expect(
      ToolbarOrderService.instance.order,
      ToolbarToolId.defaultOrder,
    );
  });
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Configurable S Pen barrel-button action (Samsung stylus side button).
enum SpenBarrelAction {
  eraser,
  lasso,
  pen,
  none;

  String get label => switch (this) {
        SpenBarrelAction.eraser => 'Eraser',
        SpenBarrelAction.lasso => 'Lasso',
        SpenBarrelAction.pen => 'Pen',
        SpenBarrelAction.none => 'None',
      };

  String get prefValue => name;

  ToolType? get toolType => switch (this) {
        SpenBarrelAction.eraser => ToolType.eraser,
        SpenBarrelAction.lasso => ToolType.lasso,
        SpenBarrelAction.pen => ToolType.pen,
        SpenBarrelAction.none => null,
      };

  static SpenBarrelAction fromPref(String? value) {
    return SpenBarrelAction.values.firstWhere(
      (a) => a.name == value,
      orElse: () => SpenBarrelAction.eraser,
    );
  }
}

/// Persists S Pen barrel action and streams button press state from Android.
class SpenButtonService extends ChangeNotifier {
  SpenButtonService._();
  static final SpenButtonService instance = SpenButtonService._();

  static const channelName = 'com.itsbryce.penfold/spen_button';
  static const prefKey = 'spen_barrel_action';

  SpenBarrelAction _action = SpenBarrelAction.eraser;
  bool _buttonPressed = false;
  bool _loaded = false;
  StreamSubscription<dynamic>? _channelSub;

  SpenBarrelAction get action => _action;
  bool get buttonPressed => _buttonPressed;
  bool get isLoaded => _loaded;

  ToolType? get overrideTool =>
      _buttonPressed ? _action.toolType : null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _action = SpenBarrelAction.fromPref(prefs.getString(prefKey));
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAction(SpenBarrelAction value) async {
    _action = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, value.prefValue);
    notifyListeners();
  }

  /// Subscribe to native S Pen button events (Android only).
  Future<void> startListening() async {
    if (!Platform.isAndroid || _channelSub != null) return;
    const channel = EventChannel(channelName);
    _channelSub = channel.receiveBroadcastStream().listen(
      (event) {
        final pressed = event == true;
        if (_buttonPressed != pressed) {
          _buttonPressed = pressed;
          notifyListeners();
        }
      },
      onError: (_) {},
    );
  }

  void stopListening() {
    unawaited(_channelSub?.cancel());
    _channelSub = null;
    if (_buttonPressed) {
      _buttonPressed = false;
      notifyListeners();
    }
  }

  /// Pointer-event fallback when native channel is unavailable.
  void updateFromPointer(PointerDeviceKind kind, int buttons) {
    if (kind != PointerDeviceKind.stylus) return;
    if (_action == SpenBarrelAction.none) return;
    const stylusButton = 0x20; // kStylusButton
    final pressed = (buttons & stylusButton) != 0;
    if (_buttonPressed != pressed) {
      _buttonPressed = pressed;
      notifyListeners();
    }
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _action = SpenBarrelAction.eraser;
    _buttonPressed = false;
    _loaded = false;
    stopListening();
  }
}

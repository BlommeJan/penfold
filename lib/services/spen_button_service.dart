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
  bool _stylusDown = false;
  ToolType? _latchedOverride;
  bool _loaded = false;
  StreamSubscription<dynamic>? _channelSub;

  SpenBarrelAction get action => _action;
  bool get buttonPressed => _buttonPressed;
  bool get isLoaded => _loaded;

  /// Active while the barrel is held, or latched until stylus pointer-up after
  /// barrel release mid-stroke.
  ToolType? get overrideTool {
    if (_latchedOverride != null) return _latchedOverride;
    return _buttonPressed ? _action.toolType : null;
  }

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
        _applyButtonPressed(event == true);
      },
      onError: (_) {},
    );
  }

  void stopListening() {
    unawaited(_channelSub?.cancel());
    _channelSub = null;
    if (_buttonPressed || _latchedOverride != null) {
      _buttonPressed = false;
      _latchedOverride = null;
      notifyListeners();
    }
  }

  /// Primary (0x20) and secondary (0x40) Samsung stylus barrel buttons.
  static bool stylusButtonsPressed(int buttons) {
    const primary = 0x20; // kStylusButton
    const secondary = 0x40; // kSecondaryStylusButton
    return (buttons & primary) != 0 || (buttons & secondary) != 0;
  }

  /// Pointer-event fallback when native channel is unavailable, and to detect
  /// press from [PointerEvent.buttons] (0x20 primary, 0x40 secondary).
  ///
  /// On Android, Flutter often omits barrel-button bits while the button is
  /// held — the native [EventChannel] keeps press state. Do not clear press
  /// on `buttons == 0` when the channel is active; use [releaseFromPointer].
  void updateFromPointer(PointerDeviceKind kind, int buttons) {
    if (kind != PointerDeviceKind.stylus) return;
    if (_action == SpenBarrelAction.none) return;
    final pressed = stylusButtonsPressed(buttons);
    if (pressed) {
      _applyButtonPressed(true);
      return;
    }
    // Non-Android / tests: pointer stream is the only source — allow release.
    if (!Platform.isAndroid || _channelSub == null) {
      _applyButtonPressed(false);
    }
  }

  /// Stylus touched the screen — enables latch-until-lift after barrel release.
  void notifyStylusPointerDown() {
    _stylusDown = true;
  }

  /// Stylus lifted — clears barrel latch and pointer fallback press state.
  void releaseFromPointer(PointerDeviceKind kind, {int buttons = 0}) {
    if (kind != PointerDeviceKind.stylus) return;
    _stylusDown = false;
    final hadLatch = _latchedOverride != null;
    _latchedOverride = null;
    if (stylusButtonsPressed(buttons)) {
      if (hadLatch) notifyListeners();
      return;
    }
    if (Platform.isAndroid && _channelSub != null) {
      if (hadLatch) notifyListeners();
      return;
    }
    _applyButtonPressed(false);
  }

  void _applyButtonPressed(bool pressed) {
    if (_buttonPressed == pressed) return;
    _buttonPressed = pressed;
    if (pressed) {
      _latchedOverride = null;
    } else if (_stylusDown && _action.toolType != null) {
      _latchedOverride = _action.toolType;
    } else {
      _latchedOverride = null;
    }
    notifyListeners();
  }

  /// Native channel or tests: set press state explicitly.
  @visibleForTesting
  void setButtonPressedForTests(bool pressed) {
    _applyButtonPressed(pressed);
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _action = SpenBarrelAction.eraser;
    _buttonPressed = false;
    _stylusDown = false;
    _latchedOverride = null;
    _loaded = false;
    stopListening();
  }

  @visibleForTesting
  void notifyStylusPointerDownForTests() => notifyStylusPointerDown();
}

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
      if (!_buttonPressed) {
        _buttonPressed = true;
        notifyListeners();
      }
      return;
    }
    // Non-Android / tests: pointer stream is the only source — allow release.
    if (!Platform.isAndroid || _channelSub == null) {
      if (_buttonPressed) {
        _buttonPressed = false;
        notifyListeners();
      }
    }
  }

  /// Clear press state when the stylus pointer lifts on platforms without a
  /// native channel. On Android, [EventChannel] + `MotionEvent` button release
  /// is authoritative — pointer-up must not clear while the barrel is held.
  void releaseFromPointer(PointerDeviceKind kind, {int buttons = 0}) {
    if (kind != PointerDeviceKind.stylus) return;
    if (stylusButtonsPressed(buttons)) return;
    if (Platform.isAndroid && _channelSub != null) return;
    if (_buttonPressed) {
      _buttonPressed = false;
      notifyListeners();
    }
  }

  /// Native channel or tests: set press state explicitly.
  @visibleForTesting
  void setButtonPressedForTests(bool pressed) {
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

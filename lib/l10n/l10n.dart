import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';
export 'labels.dart';

/// Shorthand for `AppLocalizations.of(context)!`.
extension PenfoldL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

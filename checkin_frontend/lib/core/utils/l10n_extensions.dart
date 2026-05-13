import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Extension on [BuildContext] to provide shorthand access to localization strings.
extension AppLocalizationsX on BuildContext {
  /// Returns the [AppLocalizations] instance for the current context.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
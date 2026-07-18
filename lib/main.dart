import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';



import 'l10n/app_localizations.dart';

import 'screens/app_home.dart';

import 'services/gesture_ink_service.dart';

import 'services/locale_settings_service.dart';

import 'services/notebook_defaults_service.dart';

import 'services/spen_button_service.dart';

import 'services/stroke_smoothing_service.dart';

import 'services/theme_settings_service.dart';

import 'services/toolbar_order_service.dart';

import 'services/zoom_navigation_service.dart';

import 'theme/penfold_theme.dart';



void main() {

  WidgetsFlutterBinding.ensureInitialized();

  ToolbarOrderService.instance.load();

  StrokeSmoothingService.instance.load();

  GestureInkService.instance.load();

  ZoomNavigationService.instance.load();

  SpenButtonService.instance.load();

  LocaleSettingsService.instance.load();

  NotebookDefaultsService.instance.load();

  ThemeSettingsService.instance.load();

  runApp(const PenfoldApp());

}



class PenfoldApp extends StatelessWidget {

  const PenfoldApp({super.key});



  static final Listenable _appSettings = Listenable.merge([

    LocaleSettingsService.instance,

    ThemeSettingsService.instance,

  ]);



  @override

  Widget build(BuildContext context) {

    return AnimatedBuilder(

      animation: _appSettings,

      builder: (context, _) {

        return MaterialApp(

          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,

          debugShowCheckedModeBanner: false,

          locale: LocaleSettingsService.instance.locale,

          localizationsDelegates: const [

            AppLocalizations.delegate,

            GlobalMaterialLocalizations.delegate,

            GlobalWidgetsLocalizations.delegate,

            GlobalCupertinoLocalizations.delegate,

          ],

          supportedLocales: AppLocalizations.supportedLocales,

          theme: PenfoldTheme.light,

          darkTheme: PenfoldTheme.dark,

          themeMode: ThemeSettingsService.instance.themeMode,

          home: const AppHome(),

        );

      },

    );

  }

}


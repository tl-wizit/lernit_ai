import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/app_localizations.dart';
import 'screens/scenario_list_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const LernitAIApp());
}

class LernitAIApp extends StatefulWidget {
  const LernitAIApp({Key? key}) : super(key: key);

  @override
  State<LernitAIApp> createState() => _LernitAIAppState();
}

class _LernitAIAppState extends State<LernitAIApp> {
  Locale _locale = const Locale('fr');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lernit AI',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: ScenarioListScreen(onLocaleChanged: setLocale),
      routes: {
        '/settings': (context) => SettingsScreen(onLocaleChanged: setLocale),
      },
    );
  }
}

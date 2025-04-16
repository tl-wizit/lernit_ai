import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Scénario Formation',
      'scenario_list': 'Liste des scénarios',
      'settings': 'Paramètres',
      'next_scene': 'Scène Suivante',
      'finish_scenario': 'Terminer le scénario',
      'return_to_scene': 'Retour à la Scène',
      'no_scenarios': 'Aucun scénario disponible.',
      'change_language': 'Changer la langue',
      'saving_scenario': 'Enregistrement du scénario...',
    },
    'en': {
      'app_title': 'Scenario Training',
      'scenario_list': 'Scenario List',
      'settings': 'Settings',
      'next_scene': 'Next Scene',
      'finish_scenario': 'Finish Scenario',
      'return_to_scene': 'Return to Scene',
      'no_scenarios': 'No scenarios available.',
      'change_language': 'Change Language',
      'saving_scenario': 'Saving scenario...',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMMd(locale.languageCode).format(date);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import '../data/translations.dart';

//New Material 3 version

class ThemeComponents {
  Brightness brightness;
  Color color;

  ThemeComponents({
    required this.brightness,
    required this.color,
  });
}

class Translation {
  String langCode;
  String langName;
  String country;
  String language;
  String enterName;
  String about;
  String stationOffline;
  String oK;
  String cancel;

  Translation({
    required this.langCode,
    required this.langName,
    required this.country,
    required this.language,
    required this.enterName,
    required this.about,
    required this.stationOffline,
    required this.oK,
    required this.cancel,
  });
}

class ThemeModel extends ChangeNotifier {
  List<Translation> translations = appTranslations;
  ThemeComponents? userTheme;
  ThemeData? currentTheme;
  Locale? userLocale;

  Future<void> setupTheme() async {
    // if theme exists load it
    late Brightness brightness;
    Box userPrefsBox = await Hive.openBox('userPrefs');
    String? brightnessAsString = userPrefsBox.get('brightness');

    ThemeComponents defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);

    if (brightnessAsString == null) {
      //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
      setTheme(
          brightness: defaultTheme.brightness,
          color: defaultTheme.color,
          refresh: false);
    } else {
      if (brightnessAsString == "Brightness.dark") {
        brightness = Brightness.dark;
      } else {
        brightness = Brightness.light;
      }
      setTheme(
          brightness: brightness, color: defaultTheme.color, refresh: false);
    }
  }

  void setTheme({Brightness? brightness, Color? color, bool? refresh}) {
    //Set incoming theme

    userTheme = ThemeComponents(
        brightness: brightness ?? userTheme!.brightness,
        color: color ?? userTheme!.color);

    currentTheme = ThemeData(
        brightness: brightness ?? userTheme!.brightness,
        colorSchemeSeed: color ?? userTheme!.color,
        fontFamily: 'Lato');
    //send it for storage
    saveThemeToDisk(userTheme!.brightness.toString());
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  Future<void> saveThemeToDisk(String brightness) async {
    Box userPrefsBox = await Hive.openBox('userPrefs');
    userPrefsBox.put('brightness', brightness);
  }
}

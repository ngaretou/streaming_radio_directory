import 'package:flutter/material.dart';
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

  String? _currentTranslation;

  Translation get currentTranslation {
    return translations
        .where((element) => element.langCode == _currentTranslation)
        .first;
  }

  String? get currentLang => _currentTranslation;

  set setUserLang(String lang) {
    _currentTranslation = lang;
    notifyListeners();
  }

  Future<void> setupTheme() async {
    //TODO if theme exists load it
    ThemeComponents defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);
    print('setupTheme');

    //get the prefs
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
    // if (!prefs.containsKey('userTheme')) {
    setTheme(
        brightness: defaultTheme.brightness,
        color: defaultTheme.color,
        refresh: false);
    // } else {
    //   final List<String>? _savedTheme = prefs.getStringList('userTheme');
    //   late Brightness _brightness;
    //   //Try this out - if there's a version problem where the variable doesn't fit,
    //   //the default theme is used
    //   try {
    //     switch (_savedTheme?[0]) {
    //       case "Brightness.light":
    //         {
    //           _brightness = Brightness.light;
    //           break;
    //         }

    //       case "Brightness.dark":
    //         {
    //           _brightness = Brightness.dark;
    //           break;
    //         }
    //     }
    //     //We save the color this way so have to convert it to Color:
    //     int _colorValue = int.parse(_savedTheme![1]);
    //     Color color = Color(_colorValue).withOpacity(1);

    //     ThemeComponents _componentsToSet =
    //         ThemeComponents(brightness: _brightness, color: color);

    //     setTheme(_componentsToSet, refresh: false);
    //   } catch (e) {
    //     //If something goes wrong, set default theme
    //     setTheme(_defaultTheme, refresh: false);
    //   }
    // }

    // print('end of setup theme');
    // return;
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
    // saveThemeToDisk(theme);
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  Future<void> setTranslation(String lang) async {}

  Future<void> saveThemeToDisk(ThemeComponents theme) async {
    //TODO save theme to disk

    //get prefs from disk
    // final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    // final _userTheme = json.encode(theme);

    // await prefs.setStringList('userTheme',
    //     <String>[theme.brightness.toString(), theme.color.value.toString()]);
  }
}

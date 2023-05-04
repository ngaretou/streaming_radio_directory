import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/channels.dart';
import '../providers/theme.dart';

Map<String, String> languageAbbreviations = {
  "auto": "Auto",
  "en": "English",
  "es": "Español",
  "fr": "Français",
  "sw": "Swahili"
};

//This is available to check the status of the user's language selection
//It can be explicit - use what the user has chosen
//It can be null - user has never made a choice
//It can be auto - user has made a choice but gone back to auto
Future<Translation> getTranslation(BuildContext context) async {
  late Translation returnMe;

  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  Channel currentChannel =
      Provider.of<Channels>(context, listen: false).currentChannel;
  String? selectedInterfaceLang = await getUsersChosenInterfaceLanguage();
  if (selectedInterfaceLang != null && selectedInterfaceLang != 'auto') {
    //user has selected a lang; the lang is not automatic
    returnMe = themeModel.translations
        .where((element) => element.langCode == selectedInterfaceLang)
        .first;
  } else {
    ////user has selected a lang; the lang is the currentChannel's
    returnMe = themeModel.translations
        .where((element) => element.langCode == currentChannel.language)
        .first;
  }

  return returnMe;
}

Future<String?> getUsersChosenInterfaceLanguage() async {
  Box userPrefsBox = await Hive.openBox('userPrefs');

  //if the user has explicitly selected a lang
  String? returnMe = userPrefsBox.get('selectedLanguage');

  return returnMe;
}

Future<void> setUsersChosenInterfaceLanguage(String? lang) async {
  Box userPrefsBox = await Hive.openBox('userPrefs');

  //store the user's pref - it may be "auto" or may be a language code
  userPrefsBox.put('selectedLanguage', lang);
}
